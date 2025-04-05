import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  int? selectedSemesterId;
  int? selectedSubjectId;
  List<Map<String, dynamic>> availableSubjects = [];

  @override
  void initState() {
    super.initState();
    _loadSemestersList();
    if (widget.quizToEdit != null) {
      final quiz = widget.quizToEdit!;
      _nameController.text = quiz.name;
      selectedSemesterId = quiz.semester['id'];
      selectedSubjectId = quiz.subject['id'];
      _typeController.text = quiz.type;
      _attemptsController.text = quiz.numberOfAttempts.toString();
      _timeLimitController.text = quiz.timeLimit.toString();
      _questions.addAll(quiz.content);
    }
  }

  Future<void> _loadSemestersList() async {
    await Provider.of<QuizProvider>(context, listen: false).fetchSemestersList();
  }

  void _updateAvailableSubjects(List<Map<String, dynamic>> subjects) {
    setState(() {
      availableSubjects = subjects;
      selectedSubjectId = null; // Reset subject selection when semester changes
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _attemptsController.dispose();
    _timeLimitController.dispose();
    super.dispose();
  }

  double _calculateTotalGrade() {
    return _questions.fold(0.0, (sum, question) => sum + question.grade);
  }

  void _addQuestion() {
    showDialog(
      context: context,
      builder: (context) => QuestionDialog(
        onSave: (question) {
          setState(() {
            _questions.add(question);
          });
        },
      ),
    );
  }

  Future<void> _submitQuiz() async {
    if (_formKey.currentState!.validate() && _questions.isNotEmpty) {
      try {
        final quiz = Quiz(
          name: _nameController.text,
          subjectId: selectedSubjectId!,
          semesterId: selectedSemesterId!,
          grade: _calculateTotalGrade().toInt(),
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
              TextFormField(
                controller: _nameController,
                decoration: AppTheme.inputDecoration('Quiz Name'),
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              Consumer<QuizProvider>(
                builder: (context, quizProvider, child) {
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
                              // Find and update available subjects for selected semester
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
                ],
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  'Total Grade: ${_calculateTotalGrade()}',
                  style: AppTheme.headingMedium,
                ),
              ),
              const SizedBox(height: 24),
              Text('Questions', style: AppTheme.headingMedium),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _questions.length,
                itemBuilder: (context, index) {
                  final question = _questions[index];
                  return Card(
                    margin: EdgeInsets.only(bottom: 16),
                    child: ListTile(
                      title: Text(question.question),
                      subtitle: Text('Type: ${question.type.toString().split('.').last}'),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            _questions.removeAt(index);
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton.icon(
                  icon: Icon(Icons.add, color: Colors.white),  // Make icon white
                  label: Text('Add Question'),
                  style: AppTheme.primaryButtonStyle,
                  onPressed: _addQuestion,
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: _submitQuiz,
                  style: AppTheme.primaryButtonStyle,
                  child: Text(isEditing ? 'Update Quiz' : 'Create Quiz'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QuestionDialog extends StatefulWidget {
  final Function(Question) onSave;

  const QuestionDialog({required this.onSave});

  @override
  _QuestionDialogState createState() => _QuestionDialogState();
}

class _QuestionDialogState extends State<QuestionDialog> {
  final _formKey = GlobalKey<FormState>();
  QuestionType _selectedType = QuestionType.mcq;
  final _questionController = TextEditingController();
  final _gradeController = TextEditingController();
  final List<MCQAnswer> _answers = [];
  int? _correctAnswerId;
  final _correctAnswerController = TextEditingController();
  final _maxDurationController = TextEditingController();

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






