import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Models/question.dart';
import '../Models/quiz.dart';
import '../Models/Subject_Template.dart';
import '../provider/quiz_provider.dart';
import '../provider/subcategory_provider.dart';
import '../widgets/subcategory_selector.dart';
import '../widgets/coptic_text_field.dart';
import '../Theme.dart';

class CreateTasmi3Screen extends StatefulWidget {
  final int initialSubjectId;
  final int initialLessonId;
  final String subjectName;
  final String lessonName;

  const CreateTasmi3Screen({
    Key? key,
    required this.initialSubjectId,
    required this.initialLessonId,
    required this.subjectName,
    required this.lessonName,
  }) : super(key: key);

  @override
  State<CreateTasmi3Screen> createState() => _CreateTasmi3ScreenState();
}

class _CreateTasmi3ScreenState extends State<CreateTasmi3Screen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _gradeController = TextEditingController();
  final _attemptsController = TextEditingController();
  final _typeController = TextEditingController();
  Question? _recordQuestion;
  SubCategory? selectedSubcategory;

  @override
  void initState() {
    super.initState();
    // Set default values
    _nameController.text = 'Tasmi3 - ${widget.lessonName}';
    _gradeController.text = '10';
    _attemptsController.text = '1';
    _typeController.text = 'Week'; // Default to Week
  }

  @override
  void dispose() {
    _nameController.dispose();
    _gradeController.dispose();
    _attemptsController.dispose();
    _typeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Tasmi3'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildBasicInfoCard(),
                const SizedBox(height: 24),
                _buildQuestionCard(),
                const SizedBox(height: 32),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.mic,
                  color: Colors.green,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create Tasmi3',
                      style: AppTheme.headingLarge.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Audio recording assessment for ${widget.subjectName}',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.green, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tasmi3 allows students to record audio responses. Only one recording question is allowed per Tasmi3, with no time limit.',
                    style: AppTheme.bodyMedium.copyWith(
                      color: Colors.green.shade700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Basic Information',
            style: AppTheme.headingMedium.copyWith(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nameController,
            decoration: AppTheme.inputDecoration('Tasmi3 Name'),
            validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _gradeController,
                  decoration: AppTheme.inputDecoration('Total Grade'),
                  keyboardType: TextInputType.number,
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
                child: DropdownButtonFormField<String>(
                  value: _typeController.text.isNotEmpty ? _typeController.text : 'Week',
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
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  initialValue: widget.lessonName,
                  decoration: AppTheme.inputDecoration('Lesson'),
                  enabled: false,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Subcategory Selector
          ChangeNotifierProvider(
            create: (context) => SubcategoryProvider(),
            child: SubcategorySelector(
              subjectId: widget.initialSubjectId,
              selectedSubcategory: selectedSubcategory,
              onSubcategoryChanged: (subcategory) {
                setState(() {
                  selectedSubcategory = subcategory;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recording Question',
                style: AppTheme.headingMedium.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_recordQuestion == null)
                ElevatedButton.icon(
                  onPressed: _addRecordQuestion,
                  icon: const Icon(Icons.mic_outlined, size: 18),
                  label: const Text('Add Question'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (_recordQuestion == null)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.mic_none,
                    size: 48,
                    color: Colors.grey.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No recording question added yet',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add a question for students to record their audio response',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textSecondaryColor,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            _buildQuestionDisplay(),
        ],
      ),
    );
  }

  Widget _buildQuestionDisplay() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.mic, color: Colors.green, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recording Question',
                      style: AppTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                    Text(
                      'Grade: ${_recordQuestion!.grade.toInt()} points',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textSecondaryColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                    onPressed: _editRecordQuestion,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                    onPressed: _removeRecordQuestion,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _recordQuestion!.question,
              style: AppTheme.bodyMedium,
            ),
          ),
          if (_recordQuestion!.maxDuration != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.timer, color: Colors.green, size: 16),
                const SizedBox(width: 4),
                Text(
                  'Max Duration: ${_recordQuestion!.maxDuration} seconds',
                  style: AppTheme.bodyMedium.copyWith(
                    color: Colors.green.shade700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: AppTheme.primaryColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Cancel',
              style: AppTheme.bodyLarge.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _recordQuestion != null ? _saveTasmi3 : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Create Tasmi3',
              style: AppTheme.bodyLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _addRecordQuestion() {
    showDialog(
      context: context,
      builder: (context) => TasmiQuestionDialog(
        onSave: (question) {
          setState(() {
            _recordQuestion = question;
          });
        },
        grade: double.parse(_gradeController.text),
      ),
    );
  }

  void _editRecordQuestion() {
    if (_recordQuestion != null) {
      showDialog(
        context: context,
        builder: (context) => TasmiQuestionDialog(
          onSave: (question) {
            setState(() {
              _recordQuestion = question;
            });
          },
          grade: double.parse(_gradeController.text),
          existingQuestion: _recordQuestion,
        ),
      );
    }
  }

  void _removeRecordQuestion() {
    setState(() {
      _recordQuestion = null;
    });
  }

  void _saveTasmi3() async {
    if (_formKey.currentState!.validate() && _recordQuestion != null) {
      try {
        final quiz = Quiz(
          name: _nameController.text,
          subjectId: widget.initialSubjectId,
          lessonId: widget.initialLessonId,
          grade: int.parse(_gradeController.text),
          type: _typeController.text, // Use selected quiz type (Week or Final)
          numberOfAttempts: int.parse(_attemptsController.text),
          isRecord: true, // Mark as recording quiz for Tasmi3
          subCategory: selectedSubcategory,
          content: [_recordQuestion!],
        );

        final quizProvider = Provider.of<QuizProvider>(context, listen: false);
        await quizProvider.createQuiz(quiz);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tasmi3 created successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error creating Tasmi3: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

class TasmiQuestionDialog extends StatefulWidget {
  final Function(Question) onSave;
  final double grade;
  final Question? existingQuestion;

  const TasmiQuestionDialog({
    Key? key,
    required this.onSave,
    required this.grade,
    this.existingQuestion,
  }) : super(key: key);

  @override
  State<TasmiQuestionDialog> createState() => _TasmiQuestionDialogState();
}

class _TasmiQuestionDialogState extends State<TasmiQuestionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final _maxDurationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.existingQuestion != null) {
      _questionController.text = widget.existingQuestion!.question;
      _maxDurationController.text = widget.existingQuestion!.maxDuration?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    _maxDurationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.mic, color: Colors.green),
          const SizedBox(width: 8),
          Text(widget.existingQuestion != null ? 'Edit Recording Question' : 'Add Recording Question'),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              QuizCopticTextField(
                controller: _questionController,
                labelText: 'Question',
                maxLines: 3,
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _maxDurationController,
                decoration: AppTheme.inputDecoration('Max Duration (seconds) - Optional'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Students will record audio responses to this question.',
                        style: AppTheme.bodyMedium.copyWith(
                          color: Colors.green.shade700,
                          fontSize: 12,
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
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveQuestion,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _saveQuestion() {
    if (_formKey.currentState!.validate()) {
      final question = Question(
        question: _questionController.text,
        type: QuestionType.record,
        grade: widget.grade,
        maxDuration: _maxDurationController.text.isNotEmpty
            ? int.parse(_maxDurationController.text)
            : null,
      );
      widget.onSave(question);
      Navigator.pop(context);
    }
  }
}
