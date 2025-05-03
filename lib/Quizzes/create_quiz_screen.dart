import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../Models/quiz.dart';
import '../Theme.dart';
import '../provider/quiz_provider.dart';

class CreateQuizScreen extends StatefulWidget {
  final QuizDetails? quizToEdit;

  const CreateQuizScreen({this.quizToEdit});

  @override
  _CreateQuizScreenState createState() => _CreateQuizScreenState();
}

class _CreateQuizScreenState extends State<CreateQuizScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<Question> _questions = [];
  
  final _nameController = TextEditingController();
  final _typeController = TextEditingController();
  final _attemptsController = TextEditingController();
  final _timeLimitController = TextEditingController();
  final _totalGradeController = TextEditingController(text: '40'); // Default total grade

  int? selectedSemesterId;
  int? selectedSubjectId;
  List<Map<String, dynamic>> availableSubjects = [];
  bool _isInitialized = false;

  // Question category counters
  int _easyQuestionsCount = 0;
  int _mediumQuestionsCount = 0;
  int _hardQuestionsCount = 0;

  // Required questions per category
  int _requiredQuestionsPerCategory = 0;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _totalGradeController.addListener(_updateRequiredQuestions);
  }

  void _updateRequiredQuestions() {
    if (_totalGradeController.text.isNotEmpty) {
      try {
        final totalGrade = int.parse(_totalGradeController.text);
        setState(() {
          _requiredQuestionsPerCategory = (totalGrade / 9).ceil();
        });
        _updateQuestionCounts();
      } catch (e) {
        // Handle parsing error
      }
    }
  }

  void _updateQuestionCounts() {
    int easyCount = 0;
    int mediumCount = 0;
    int hardCount = 0;

    for (var question in _questions) {
      if (question.grade == 1) {
        easyCount++;
      } else if (question.grade == 3) {
        mediumCount++;
      } else if (question.grade == 5) {
        hardCount++;
      }
    }

    setState(() {
      _easyQuestionsCount = easyCount;
      _mediumQuestionsCount = mediumCount;
      _hardQuestionsCount = hardCount;
    });
  }

  Future<void> _loadInitialData() async {
    await _loadSemestersList();
    
    if (widget.quizToEdit != null && !_isInitialized) {
      final quiz = widget.quizToEdit!;
      _nameController.text = quiz.name;
      _typeController.text = quiz.type;
      _attemptsController.text = quiz.numberOfAttempts.toString();
      _timeLimitController.text = quiz.timeLimit.toString();
      _totalGradeController.text = quiz.grade.toString();
      _questions.addAll(quiz.content);
      _updateQuestionCounts();

      // Wait for semesters list to be loaded
      final quizProvider = Provider.of<QuizProvider>(context, listen: false);
      if (quizProvider.semestersList.isNotEmpty) {
        setState(() {
          selectedSemesterId = quiz.semester['id'];
          // Find and update available subjects for selected semester
          final semester = quizProvider.semestersList
              .firstWhere((s) => s['id'] == selectedSemesterId);
          availableSubjects = List<Map<String, dynamic>>.from(semester['subjects']);
          selectedSubjectId = quiz.subject['id'];
          _isInitialized = true;
        });
      }
    }
  }

  Future<void> _loadSemestersList() async {
    await Provider.of<QuizProvider>(context, listen: false).fetchSemestersList();
  }

  void _updateAvailableSubjects(List<Map<String, dynamic>> subjects) {
    setState(() {
      availableSubjects = subjects;
      // Only reset subject selection if not editing or if semester changed
      if (!_isInitialized || widget.quizToEdit?.semester['id'] != selectedSemesterId) {
        selectedSubjectId = null;
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _attemptsController.dispose();
    _timeLimitController.dispose();
    _totalGradeController.dispose();
    super.dispose();
  }

  double _calculateTotalGrade() {
    return _questions.fold(0.0, (sum, question) => sum + question.grade);
  }

  void _addQuestion(double difficulty) {
    showDialog(
      context: context,
      builder: (context) => QuestionDialog(
        onSave: (question) {
          setState(() {
            // Override the grade based on difficulty
            final updatedQuestion = Question(
              question: question.question,
              type: question.type,
              grade: difficulty, // Set grade based on difficulty
              answers: question.answers,
              correctAnswerId: question.correctAnswerId,
              correctAnswer: question.correctAnswer,
              maxDuration: question.maxDuration,
            );
            _questions.add(updatedQuestion);
            _updateQuestionCounts();
          });
        },
        predefinedGrade: difficulty,
      ),
    );
  }

  bool _canSubmitQuiz() {
    return _formKey.currentState?.validate() == true && 
           _questions.isNotEmpty &&
           _easyQuestionsCount >= _requiredQuestionsPerCategory &&
           _mediumQuestionsCount >= _requiredQuestionsPerCategory &&
           _hardQuestionsCount >= _requiredQuestionsPerCategory;
  }

  Future<void> _submitQuiz() async {
    if (_canSubmitQuiz()) {
      try {
        final totalGrade = int.parse(_totalGradeController.text);
        
        final quiz = Quiz(
          name: _nameController.text,
          subjectId: selectedSubjectId!,
          semesterId: selectedSemesterId!,
          grade: totalGrade,
          type: _typeController.text,
          numberOfAttempts: int.parse(_attemptsController.text),
          timeLimit: int.parse(_timeLimitController.text),
          content: _questions,
        );

        if (widget.quizToEdit != null) {
          await Provider.of<QuizProvider>(context, listen: false)
              .updateQuiz(widget.quizToEdit!.id, quiz);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Quiz updated successfully')),
          );
        } else {
          await Provider.of<QuizProvider>(context, listen: false).createQuiz(quiz);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Quiz created successfully')),
          );
        }

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please add the required number of questions for each difficulty level'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.quizToEdit != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Quiz' : 'Create New Quiz'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Quiz Information', style: AppTheme.headingMedium),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        decoration: AppTheme.inputDecoration('Quiz Name'),
                        validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      Consumer<QuizProvider>(
                        builder: (context, quizProvider, child) {
                          // Ensure lists are not empty before building dropdowns
                          if (quizProvider.semestersList.isEmpty) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          return Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<int>(
                                  value: selectedSemesterId,
                                  decoration: AppTheme.inputDecoration('Select Semester'),
                                  items: [
                                    const DropdownMenuItem<int>(
                                      value: null,
                                      child: Text('Select Semester'),
                                    ),
                                    ...quizProvider.semestersList.map((semester) {
                                      return DropdownMenuItem<int>(
                                        value: semester['id'] as int,
                                        child: Text(semester['name'] as String),
                                      );
                                    }).toList(),
                                  ],
                                  validator: (value) => value == null ? 'Required' : null,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedSemesterId = value;
                                      if (value != null) {
                                        final semester = quizProvider.semestersList
                                            .firstWhere((s) => s['id'] == value);
                                        _updateAvailableSubjects(
                                            List<Map<String, dynamic>>.from(semester['subjects']));
                                      } else {
                                        _updateAvailableSubjects([]);
                                      }
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: DropdownButtonFormField<int>(
                                  value: selectedSubjectId,
                                  decoration: AppTheme.inputDecoration('Select Subject'),
                                  items: [
                                    const DropdownMenuItem<int>(
                                      value: null,
                                      child: Text('Select Subject'),
                                    ),
                                    ...availableSubjects.map((subject) {
                                      return DropdownMenuItem<int>(
                                        value: subject['id'] as int,
                                        child: Text(subject['name'] as String),
                                      );
                                    }).toList(),
                                  ],
                                  validator: (value) => value == null ? 'Required' : null,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedSubjectId = value;
                                    });
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _typeController,
                              decoration: AppTheme.inputDecoration('Quiz Type'),
                              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _attemptsController,
                              decoration: AppTheme.inputDecoration('Number of Attempts'),
                              keyboardType: TextInputType.number,
                              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _timeLimitController,
                              decoration: AppTheme.inputDecoration('Time Limit (minutes)'),
                              keyboardType: TextInputType.number,
                              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _totalGradeController,
                              decoration: AppTheme.inputDecoration('Total Grade'),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value?.isEmpty ?? true) return 'Required';
                                try {
                                  final grade = int.parse(value!);
                                  if (grade <= 0) return 'Must be positive';
                                } catch (e) {
                                  return 'Invalid number';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Questions Requirements', style: AppTheme.headingMedium),
                      const SizedBox(height: 16),
                      Text(
                        'Based on the total grade of ${_totalGradeController.text}, you need to add at least $_requiredQuestionsPerCategory questions of each difficulty:',
                        style: AppTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      _buildQuestionCategoryProgress(
                        'Easy Questions (1 point each)', 
                        _easyQuestionsCount, 
                        _requiredQuestionsPerCategory,
                        Colors.green,
                      ),
                      const SizedBox(height: 8),
                      _buildQuestionCategoryProgress(
                        'Medium Questions (3 points each)', 
                        _mediumQuestionsCount, 
                        _requiredQuestionsPerCategory,
                        Colors.orange,
                      ),
                      const SizedBox(height: 8),
                      _buildQuestionCategoryProgress(
                        'Hard Questions (5 points each)', 
                        _hardQuestionsCount, 
                        _requiredQuestionsPerCategory,
                        Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildAddQuestionButton('Add Easy', Colors.green, 1.0),
                          _buildAddQuestionButton('Add Medium', Colors.orange, 3.0),
                          _buildAddQuestionButton('Add Hard', Colors.red, 5.0),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Questions (${_questions.length})', style: AppTheme.headingMedium),
                          Text(
                            'Current Total: ${_calculateTotalGrade()} / ${_totalGradeController.text.isEmpty ? "0" : _totalGradeController.text}',
                            style: AppTheme.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _calculateTotalGrade() > (int.tryParse(_totalGradeController.text) ?? 0) 
                                  ? Colors.red 
                                  : AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_questions.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'No questions added yet. Add questions using the buttons above.',
                              style: AppTheme.bodyMedium.copyWith(color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: _questions.length,
                          itemBuilder: (context, index) {
                            final question = _questions[index];
                            return Card(
                              margin: EdgeInsets.only(bottom: 8),
                              color: _getDifficultyColor(question.grade).withOpacity(0.1),
                              child: ListTile(
                                title: Text(question.question),
                                subtitle: Text(
                                  'Type: ${question.type.toString().split('.').last.toUpperCase()} • Grade: ${question.grade.toInt()} points',
                                ),
                                leading: CircleAvatar(
                                  backgroundColor: _getDifficultyColor(question.grade),
                                  child: Text(
                                    _getDifficultyLabel(question.grade),
                                    style: TextStyle(color: Colors.white, fontSize: 12),
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    setState(() {
                                      _questions.removeAt(index);
                                      _updateQuestionCounts();
                                    });
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              Center(
                child: ElevatedButton(
                  onPressed: _canSubmitQuiz() ? _submitQuiz : null,
                  style: _canSubmitQuiz() 
                      ? AppTheme.primaryButtonStyle 
                      : AppTheme.primaryButtonStyle.copyWith(
                          backgroundColor: MaterialStateProperty.all(Colors.grey),
                        ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0),
                    child: Text(
                      isEditing ? 'Update Quiz' : 'Create Quiz',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionCategoryProgress(String title, int current, int required, Color color) {
    final double progress = required > 0 ? (current / required).clamp(0.0, 1.0) : 1.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: AppTheme.bodyMedium),
            Text('$current/$required', style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildAddQuestionButton(String label, Color color, double difficulty) {
    return ElevatedButton.icon(
      icon: Icon(Icons.add, color: Colors.white, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      onPressed: () => _addQuestion(difficulty),
    );
  }

  Color _getDifficultyColor(double grade) {
    if (grade == 1.0) return Colors.green;
    if (grade == 3.0) return Colors.orange;
    if (grade == 5.0) return Colors.red;
    return Colors.blue;
  }

  String _getDifficultyLabel(double grade) {
    if (grade == 1.0) return 'E';
    if (grade == 3.0) return 'M';
    if (grade == 5.0) return 'H';
    return '?';
  }
}

class QuestionDialog extends StatefulWidget {
  final Function(Question) onSave;
  final double predefinedGrade;

  const QuestionDialog({
    required this.onSave,
    this.predefinedGrade = 1.0,
  });

  @override
  _QuestionDialogState createState() => _QuestionDialogState();
}

class _QuestionDialogState extends State<QuestionDialog> {
  final _formKey = GlobalKey<FormState>();
  QuestionType _selectedType = QuestionType.mcq;
  final _questionController = TextEditingController();
  final List<MCQAnswer> _answers = [];
  int? _correctAnswerId;
  final _correctAnswerController = TextEditingController();
  final _maxDurationController = TextEditingController();
  // Add the missing grade controller
  final _gradeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Add two default empty answers for MCQ
    if (_answers.isEmpty) {
      _answers.add(MCQAnswer(id: 0, text: ''));
      _answers.add(MCQAnswer(id: 1, text: ''));
    }
    
    // Set the predefined grade
    _gradeController.text = widget.predefinedGrade.toString();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Question'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<QuestionType>(
                value: _selectedType,
                decoration: AppTheme.inputDecoration('Question Type'),
                items: QuestionType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.toString().split('.').last.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _questionController,
                decoration: AppTheme.inputDecoration('Question'),
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _gradeController,
                decoration: AppTheme.inputDecoration('Grade'),
                keyboardType: TextInputType.number,
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              if (_selectedType == QuestionType.mcq) ...[
                ..._buildMCQSection(),
              ] else if (_selectedType == QuestionType.text) ...[
                TextFormField(
                  controller: _correctAnswerController,
                  decoration: AppTheme.inputDecoration('Correct Answer (Optional)'),
                  // Remove validator to make it optional
                ),
              ] else if (_selectedType == QuestionType.record) ...[
                TextFormField(
                  controller: _maxDurationController,
                  decoration: AppTheme.inputDecoration('Max Duration (seconds)'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveQuestion,
          style: AppTheme.primaryButtonStyle,
          child: Text('Save'),
        ),
      ],
    );
  }

  List<Widget> _buildMCQSection() {
    return [
      ...List.generate(_answers.length, (index) {
        return Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: _answers[index].text,
                decoration: AppTheme.inputDecoration('Option ${index + 1}'),
                onChanged: (value) {
                  _answers[index] = MCQAnswer(id: index, text: value);
                },
              ),
            ),
            Radio<int>(
              value: index,
              groupValue: _correctAnswerId,
              onChanged: (value) {
                setState(() {
                  _correctAnswerId = value;
                });
              },
            ),
          ],
        );
      }),
      TextButton(
        onPressed: () {
          setState(() {
            _answers.add(MCQAnswer(id: _answers.length, text: ''));
          });
        },
        child: Text('Add Option'),
      ),
    ];
  }

  void _saveQuestion() {
    if (_formKey.currentState!.validate()) {
      final question = Question(
        question: _questionController.text,
        type: _selectedType,
        grade: double.parse(_gradeController.text),
        answers: _selectedType == QuestionType.mcq ? _answers : null,
        correctAnswerId: _selectedType == QuestionType.mcq ? _correctAnswerId : null,
        correctAnswer: _selectedType == QuestionType.text ? _correctAnswerController.text.isEmpty ? null : _correctAnswerController.text : null,
        maxDuration: _selectedType == QuestionType.record && _maxDurationController.text.isNotEmpty
            ? int.parse(_maxDurationController.text)
            : null,
      );
      widget.onSave(question);
      Navigator.pop(context);
    }
  }
}









