import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Models/question.dart';
import '../Models/quiz.dart';
import '../Models/subject.dart';
import '../Models/Subject_Template.dart';
import '../Theme.dart';
import '../provider/quiz_provider.dart';
import '../provider/subcategory_provider.dart';
import '../widgets/subcategory_selector.dart';
import '../widgets/coptic_text_field.dart';

class CreateQuizScreen extends StatefulWidget {
  final QuizDetails? quizToEdit;
  final int? initialSubjectId;
  final int? initialLessonId;
  final String subjectName;
  final String lessonName;

  const CreateQuizScreen({
    Key? key,
    this.quizToEdit,
    this.initialSubjectId,
    this.initialLessonId,

     required this.subjectName,
    required this.lessonName,
  }) : super(key: key);

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
  final _easyQuestionsController = TextEditingController(text: '1'); // Default easy questions
  final _mediumQuestionsController = TextEditingController(text: '1'); // Default medium questions
  final _hardQuestionsController = TextEditingController(text: '1'); // Default hard questions

  int? selectedSubjectId;
  int? selectedLessonId;
  SubCategory? selectedSubcategory;
  List<Map<String, dynamic>> availableSubjects = [];
  List<Lesson> availableLessons = [];
  bool _isInitialized = false;
  bool _isSubmitting = false; // Track submission state

  // Question category counters
  int _easyQuestionsCount = 0;
  int _mediumQuestionsCount = 0;
  int _hardQuestionsCount = 0;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _easyQuestionsController.addListener(_updateQuestionCounts);
    _mediumQuestionsController.addListener(_updateQuestionCounts);
    _hardQuestionsController.addListener(_updateQuestionCounts);

    // Set default values for new quizzes
    if (widget.quizToEdit == null) {
      _typeController.text = 'Week';  // Changed from 'Quiz' to 'Week' to match dropdown options
      _attemptsController.text = '2';
      _timeLimitController.text = '30';
      _easyQuestionsController.text = '1';
      _mediumQuestionsController.text = '1';
      _hardQuestionsController.text = '1';
    }
  }

  int _calculateTotalGrade() {
    try {
      final easy = int.parse(_easyQuestionsController.text.isEmpty ? '0' : _easyQuestionsController.text);
      final medium = int.parse(_mediumQuestionsController.text.isEmpty ? '0' : _mediumQuestionsController.text);
      final hard = int.parse(_hardQuestionsController.text.isEmpty ? '0' : _hardQuestionsController.text);
      return easy * 1 + medium * 3 + hard * 5;
    } catch (e) {
      return 0;
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
    if (widget.quizToEdit != null && !_isInitialized) {
      final quiz = widget.quizToEdit!;
      _nameController.text = quiz.name;

      // Ensure the quiz type is one of our valid options
      if (quiz.type == 'Week' || quiz.type == 'Final') {
        _typeController.text = quiz.type;
      } else {
        // Default to 'Week' if the type is not valid
        _typeController.text = 'Week';
      }

      _attemptsController.text = quiz.numberOfAttempts.toString();
      _timeLimitController.text = quiz.timeLimit.toString();
      _easyQuestionsController.text = quiz.easyQuestions.toString();
      _mediumQuestionsController.text = quiz.mediumQuestions.toString();
      _hardQuestionsController.text = quiz.hardQuestions.toString();
      selectedSubcategory = quiz.subCategory;
      _questions.addAll(quiz.content);
      _updateQuestionCounts();

    }
  }


  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _attemptsController.dispose();
    _timeLimitController.dispose();
    _easyQuestionsController.dispose();
    _mediumQuestionsController.dispose();
    _hardQuestionsController.dispose();
    super.dispose();
  }



  String _getDisplayLessonName() {
    // First check if we have a name passed directly
    if (widget.lessonName != null && widget.lessonName!.isNotEmpty) {
      return widget.lessonName!;
    }

    // If editing a quiz, get the name from the quiz
    if (widget.quizToEdit != null && widget.quizToEdit!.lesson != null) {
      return widget.quizToEdit!.lesson!['name'] as String? ?? 'Unknown Lesson';
    }

    // If we have an ID but no name, show the ID
    if (widget.initialLessonId != null) {
      return 'Lesson ${widget.initialLessonId}';
    }

    return 'No lesson selected';
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
    // Get the IDs from the widget parameters or from the quiz being edited
    int? subjectId = widget.initialSubjectId;
    int? lessonId = widget.initialLessonId;

    if (widget.quizToEdit != null) {
      subjectId = widget.quizToEdit!.subject['id'];
      if (widget.quizToEdit!.lesson != null) {
        lessonId = widget.quizToEdit!.lesson!['id'];
      }
    }

    // Get required question counts from controllers
    int requiredEasy = int.tryParse(_easyQuestionsController.text) ?? 0;
    int requiredMedium = int.tryParse(_mediumQuestionsController.text) ?? 0;
    int requiredHard = int.tryParse(_hardQuestionsController.text) ?? 0;

    return _formKey.currentState?.validate() == true &&
           subjectId != null &&
           lessonId != null &&
           _questions.isNotEmpty &&
           _easyQuestionsCount >= requiredEasy &&
           _mediumQuestionsCount >= requiredMedium &&
           _hardQuestionsCount >= requiredHard;
  }

  Future<void> _submitQuiz() async {
    if (_canSubmitQuiz()) {
      // Show loading indicator
      setState(() {
        _isSubmitting = true;
      });

      try {
        final totalGrade = _calculateTotalGrade();
        final easyQuestions = int.parse(_easyQuestionsController.text);
        final mediumQuestions = int.parse(_mediumQuestionsController.text);
        final hardQuestions = int.parse(_hardQuestionsController.text);

        // Get the IDs from the widget parameters or from the quiz being edited
        int? subjectId = widget.initialSubjectId;
        int? lessonId = widget.initialLessonId;

        if (widget.quizToEdit != null) {
          subjectId = widget.quizToEdit!.subject['id'];
          if (widget.quizToEdit!.lesson != null) {
            lessonId = widget.quizToEdit!.lesson!['id'];
          }
        }

        // Validate that required fields are not null
        if (subjectId == null) {
          throw Exception('Subject ID is missing');
        }

        if (lessonId == null) {
          throw Exception('Lesson ID is missing');
        }

        final quiz = Quiz(
          name: _nameController.text,
          subjectId: subjectId,
          lessonId: lessonId,
          grade: totalGrade,
          type: _typeController.text,
          numberOfAttempts: int.parse(_attemptsController.text),
          timeLimit: int.parse(_timeLimitController.text),
          isRecord: false, // Regular quizzes are not recording quizzes
          subCategory: selectedSubcategory,
          content: _questions,
          easyQuestions: easyQuestions,
          mediumQuestions: mediumQuestions,
          hardQuestions: hardQuestions,
        );

        if (widget.quizToEdit != null) {
          // Make sure we have the quiz ID for updating
          final quizId = widget.quizToEdit!.id;

          // Debug information
          print('Updating quiz with ID: $quizId');
          print('Quiz data: ${quiz.toJson()}');

          try {
            // Show a longer loading message for update
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 16),
                    Text('Updating quiz...'),
                  ],
                ),
                duration: Duration(seconds: 2),
                backgroundColor: Colors.blue,
              ),
            );

            await Provider.of<QuizProvider>(context, listen: false)
                .updateQuiz(quizId, quiz);

            if (!mounted) return;

            // Clear any existing snackbars
            ScaffoldMessenger.of(context).clearSnackBars();

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Quiz updated successfully'),
                backgroundColor: Colors.green,
              ),
            );

            // Add a small delay before navigating back to ensure the update is complete
            await Future.delayed(Duration(milliseconds: 500));

            if (!mounted) return;
            Navigator.pop(context, true); // Return true to indicate successful update
          } catch (e) {
            print('Error updating quiz: $e');
            if (!mounted) return;

            // Clear any existing snackbars
            ScaffoldMessenger.of(context).clearSnackBars();

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error updating quiz: $e'),
                backgroundColor: Colors.red,
              ),
            );
            // Re-throw to be caught by the outer try-catch
            rethrow;
          }
        } else {
          try {
            // Show a loading message for create
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 16),
                    Text('Creating quiz...'),
                  ],
                ),
                duration: Duration(seconds: 2),
                backgroundColor: Colors.blue,
              ),
            );

            await Provider.of<QuizProvider>(context, listen: false).createQuiz(quiz);

            if (!mounted) return;

            // Clear any existing snackbars
            ScaffoldMessenger.of(context).clearSnackBars();

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Quiz created successfully'),
                backgroundColor: Colors.green,
              ),
            );

            // Add a small delay before navigating back
            await Future.delayed(Duration(milliseconds: 500));

            if (!mounted) return;
            Navigator.pop(context, true); // Return true to indicate successful creation
          } catch (e) {
            print('Error creating quiz: $e');
            if (!mounted) return;

            // Clear any existing snackbars
            ScaffoldMessenger.of(context).clearSnackBars();

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error creating quiz: $e'),
                backgroundColor: Colors.red,
              ),
            );
            // Re-throw to be caught by the outer try-catch
            rethrow;
          }
        }
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      } finally {
        // Hide loading indicator
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
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
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              readOnly: true,
                              initialValue: widget.subjectName,
                              decoration: AppTheme.inputDecoration('Subject'),
                              enabled: false,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        readOnly: true,
                        initialValue: _getDisplayLessonName(),
                        decoration: AppTheme.inputDecoration('Lesson'),
                        enabled: false,
                      ),
                      const SizedBox(height: 16),
                      // Subcategory Selector
                      if (widget.initialSubjectId != null || (widget.quizToEdit != null && widget.quizToEdit!.subject['id'] != null))
                        ChangeNotifierProvider(
                          create: (context) => SubcategoryProvider(),
                          child: SubcategorySelector(
                            subjectId: widget.initialSubjectId ?? widget.quizToEdit!.subject['id'],
                            selectedSubcategory: selectedSubcategory,
                            onSubcategoryChanged: (subcategory) {
                              setState(() {
                                selectedSubcategory = subcategory;
                              });
                            },
                          ),
                        ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Builder(
                              builder: (context) {
                                // Ensure the value is one of the valid options
                                String currentValue = _typeController.text;
                                if (currentValue.isEmpty) {
                                  currentValue = 'Week';
                                  _typeController.text = 'Week';
                                } else if (currentValue != 'Week' && currentValue != 'Final') {
                                  // If the value is not one of our options, default to 'Week'
                                  currentValue = 'Week';
                                  _typeController.text = 'Week';
                                }

                                return DropdownButtonFormField<String>(
                                  value: currentValue,
                                  decoration: AppTheme.inputDecoration('Quiz Type'),
                                  items: const [
                                    DropdownMenuItem<String>(
                                      value: 'Week',
                                      child: Text('Week'),
                                    ),
                                    DropdownMenuItem<String>(
                                      value: 'Final',
                                      child: Text('Final'),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() {
                                        _typeController.text = value;
                                      });
                                    }
                                  },
                                  validator: (value) => value == null ? 'Required' : null,
                                );
                              }
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
                      TextFormField(
                        controller: _timeLimitController,
                        decoration: AppTheme.inputDecoration('Time Limit (minutes)'),
                        keyboardType: TextInputType.number,
                        validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      Text('Question Requirements', style: AppTheme.headingMedium),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _easyQuestionsController,
                              decoration: AppTheme.inputDecoration('Easy Questions (1 pt each)'),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value?.isEmpty ?? true) return 'Required';
                                try {
                                  final count = int.parse(value!);
                                  if (count < 0) return 'Must be non-negative';
                                } catch (e) {
                                  return 'Invalid number';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _mediumQuestionsController,
                              decoration: AppTheme.inputDecoration('Medium Questions (3 pts each)'),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value?.isEmpty ?? true) return 'Required';
                                try {
                                  final count = int.parse(value!);
                                  if (count < 0) return 'Must be non-negative';
                                } catch (e) {
                                  return 'Invalid number';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _hardQuestionsController,
                              decoration: AppTheme.inputDecoration('Hard Questions (5 pts each)'),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value?.isEmpty ?? true) return 'Required';
                                try {
                                  final count = int.parse(value!);
                                  if (count < 0) return 'Must be non-negative';
                                } catch (e) {
                                  return 'Invalid number';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Total Grade: ${_calculateTotalGrade()} points',
                                style: AppTheme.bodyMedium.copyWith(
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
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
                      Text('Questions Progress', style: AppTheme.headingMedium),
                      const SizedBox(height: 16),
                      Text(
                        'Add questions to meet the requirements specified above:',
                        style: AppTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      _buildQuestionCategoryProgress(
                        'Easy Questions (1 point each)',
                        _easyQuestionsCount,
                        int.tryParse(_easyQuestionsController.text) ?? 0,
                        Colors.green,
                      ),
                      const SizedBox(height: 8),
                      _buildQuestionCategoryProgress(
                        'Medium Questions (3 points each)',
                        _mediumQuestionsCount,
                        int.tryParse(_mediumQuestionsController.text) ?? 0,
                        Colors.orange,
                      ),
                      const SizedBox(height: 8),
                      _buildQuestionCategoryProgress(
                        'Hard Questions (5 points each)',
                        _hardQuestionsCount,
                        int.tryParse(_hardQuestionsController.text) ?? 0,
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
                            'Current Total: ${_calculateTotalGrade()} points',
                            style: AppTheme.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
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
                              color: _getDifficultyColor(question.grade).withAlpha(25),
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
                  onPressed: (_canSubmitQuiz() && !_isSubmitting) ? _submitQuiz : null,
                  style: (_canSubmitQuiz() && !_isSubmitting)
                      ? AppTheme.primaryButtonStyle
                      : ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0),
                    child: _isSubmitting
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                isEditing ? 'Updating...' : 'Creating...',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          )
                        : Text(
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
    super.key,
    required this.onSave,
    this.predefinedGrade = 1.0,
  });

  @override
  State<QuestionDialog> createState() => _QuestionDialogState();
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
              QuizCopticTextField(
                controller: _questionController,
                labelText: 'Question',
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                maxLines: 3,
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
                QuizCopticTextField(
                  controller: _correctAnswerController,
                  labelText: 'Correct Answer (Optional)',
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
              child: QuizCopticTextField(
                controller: TextEditingController(text: _answers[index].text),
                labelText: 'Option ${index + 1}',
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










