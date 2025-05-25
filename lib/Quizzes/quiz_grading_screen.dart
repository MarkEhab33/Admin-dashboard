import 'package:admin_dashboard/Models/quiz_answer.dart';
import 'package:admin_dashboard/Models/quiz.dart';
import 'package:admin_dashboard/Theme.dart';
import 'package:admin_dashboard/provider/quiz_answer_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Models/question.dart';
import '../Models/quiz_answer_details.dart';

class QuizGradingScreen extends StatefulWidget {
  final int quizAnswerId;
  final int quizId;

  const QuizGradingScreen({Key? key, required this.quizAnswerId,required this.quizId}) : super(key: key);

  @override
  _QuizGradingScreenState createState() => _QuizGradingScreenState();
}

class _QuizGradingScreenState extends State<QuizGradingScreen> {
  final TextEditingController _gradeController = TextEditingController();
  // Map to store individual question grades
  final Map<int, TextEditingController> _questionGradeControllers = {};
  int? _maxGrade;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<QuizAnswerProvider>(context, listen: false)
            .fetchQuizAnswerDetails(widget.quizAnswerId);
      }
    });
  }

  @override
  void dispose() {
    _gradeController.dispose();
    _questionGradeControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz Submission'),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
      ),
      body: Consumer<QuizAnswerProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (provider.error.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60, color: Colors.red.shade300),
                  SizedBox(height: 16),
                  Text(
                    'Failed to load submission',
                    style: AppTheme.headingMedium.copyWith(color: Colors.red.shade700),
                  ),
                  SizedBox(height: 8),
                  Text(provider.error, style: AppTheme.bodyMedium),
                  SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      provider.fetchQuizAnswerDetails(widget.quizAnswerId);
                    },
                    icon: Icon(Icons.refresh),
                    label: Text('Try Again'),
                  ),
                ],
              ),
            );
          }

          final quizAnswer = provider.currentQuizAnswer;
          if (quizAnswer == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 60, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Submission not found', style: AppTheme.headingMedium),
                ],
              ),
            );
          }

          // Pre-fill with existing grade if available
          if (quizAnswer.grade != null && _gradeController.text.isEmpty) {
            _gradeController.text = quizAnswer.grade.toString();
          }

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _buildStudentHeader(quizAnswer),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _buildQuizInfoCards(quizAnswer),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildGradingSection(quizAnswer, provider),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Student Answers',
                    style: AppTheme.headingMedium,
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: _buildAnswerCard(quizAnswer.answers[index], index),
                    );
                  },
                  childCount: quizAnswer.answers.length,
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(height: 24),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStudentHeader(QuizAnswerDetails quizAnswer) {
    return Container(
      padding: EdgeInsets.only(top: 16, bottom: 24, left: 16, right: 16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white,
                radius: 30,
                child: Text(
                  quizAnswer.studentName.isNotEmpty ? quizAnswer.studentName[0].toUpperCase() : '?',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quizAnswer.studentName,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'ID: ${quizAnswer.studentCode}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      quizAnswer.studentEmail,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quizAnswer.quizName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${quizAnswer.subjectName} • Week ${quizAnswer.weekNumber}',
                      style: TextStyle(
                        color: AppTheme.textSecondaryColor,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: quizAnswer.grade != null ? Colors.green.shade50 : Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: quizAnswer.grade != null ? Colors.green.shade300 : Colors.orange.shade300,
                    ),
                  ),
                  child: Text(
                    quizAnswer.grade != null ? 'Graded' : 'Pending',
                    style: TextStyle(
                      color: quizAnswer.grade != null ? Colors.green.shade700 : Colors.orange.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
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

  Widget _buildQuizInfoCards(QuizAnswerDetails quizAnswer) {
    // Format time taken in minutes and seconds
    final minutes = quizAnswer.timeTaken ~/ 60;
    final seconds = quizAnswer.timeTaken % 60;
    final formattedTimeTaken = '$minutes min ${seconds} sec';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 24),
        Text('Quiz Information', style: AppTheme.headingMedium),
        SizedBox(height: 16),
        Container(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildInfoCard('Time Taken', formattedTimeTaken, Icons.timer, Colors.blue),
              _buildInfoCard('Attempt', '${quizAnswer.attemptNumber}/${quizAnswer.maxAttempts}', Icons.repeat, Colors.purple),
              _buildInfoCard('Max Grade', '${quizAnswer.finalGrade} points', Icons.grade, Colors.amber),
              _buildInfoCard('Submitted', _formatDate(quizAnswer.submissionDate), Icons.calendar_today, Colors.teal),
              _buildInfoCard('Type', quizAnswer.quizType, Icons.category, Colors.indigo),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildInfoCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: 150,
      margin: EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: AppTheme.textSecondaryColor,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradingSection(QuizAnswerDetails quizAnswer, QuizAnswerProvider provider) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Grade Submission',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'The total grade is calculated based on individual question grades. For MCQ questions, full points are awarded for correct answers and zero for incorrect ones. For text questions, please assign appropriate grades.',
              style: TextStyle(
                color: AppTheme.textSecondaryColor,
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: TextFormField(
                      controller: _gradeController,
                      decoration: InputDecoration(
                        labelText: 'Total Grade',
                        hintText: 'Out of ${quizAnswer.finalGrade}',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        labelStyle: TextStyle(color: AppTheme.primaryColor),
                      ),
                      keyboardType: TextInputType.number,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      readOnly: true,
                    ),
                  ),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _isSubmitting 
                      ? null 
                      : () => _submitGrades(quizAnswer, provider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Submit',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _calculateTotalGrade(quizAnswer),
              icon: Icon(Icons.calculate),
              label: Text('Calculate Total Grade'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade200,
                foregroundColor: AppTheme.textPrimaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _calculateTotalGrade(QuizAnswerDetails quizAnswer) {
    int totalGrade = 0;
    bool allQuestionsGraded = true;
    List<String> errors = [];

    for (int i = 0; i < quizAnswer.answers.length; i++) {
      final answer = quizAnswer.answers[i];
      final controller = _questionGradeControllers[i];
      
      if (controller == null || controller.text.isEmpty) {
        allQuestionsGraded = false;
        errors.add('Question ${i+1} is not graded');
        continue;
      }
      
      try {
        final grade = int.parse(controller.text);
        if (grade < 0) {
          errors.add('Question ${i+1}: Grade cannot be negative');
          continue;
        }
        if (grade > answer.questionGrade) {
          errors.add('Question ${i+1}: Grade exceeds maximum (${answer.questionGrade})');
          continue;
        }
        totalGrade += grade;
      } catch (e) {
        errors.add('Question ${i+1}: Invalid grade format');
      }
    }

    if (errors.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Please fix the following issues:'),
              ...errors.map((e) => Text('• $e')).toList(),
            ],
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _gradeController.text = totalGrade.toString();
    });

    if (!allQuestionsGraded) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Some questions are not graded. Please grade all questions.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _submitGrades(QuizAnswerDetails quizAnswer, QuizAnswerProvider provider) async {
    _calculateTotalGrade(quizAnswer);
    
    if (_gradeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please calculate the total grade first')),
      );
      return;
    }

    final totalGrade = int.parse(_gradeController.text);
    
    // Prepare question grades for submission
    List<Map<String, dynamic>> questionGrades = [];
    for (int i = 0; i < quizAnswer.answers.length; i++) {
      final controller = _questionGradeControllers[i];
      if (controller == null || controller.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please grade all questions')),
        );
        return;
      }
      
      questionGrades.add({
        'questionIndex': i,
        'grade': int.parse(controller.text),
      });
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await provider.gradeQuizAnswerWithQuestions(
        quizAnswer.id, 
        totalGrade,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Quiz graded successfully'),
            backgroundColor: Colors.green,
          ),
        );

      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error grading quiz: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildAnswerCard(QuizAnswerItem answer, int index) {
    final bool isMCQ = answer.type.toLowerCase() == 'mcq';
    final Color cardColor = isMCQ
        ? (answer.isCorrect == true ? Colors.green.shade50 : Colors.red.shade50)
        : Colors.blue.shade50;
    final Color borderColor = isMCQ
        ? (answer.isCorrect == true ? Colors.green.shade200 : Colors.red.shade200)
        : Colors.blue.shade200;
    final IconData statusIcon = isMCQ
        ? (answer.isCorrect == true ? Icons.check_circle : Icons.cancel)
        : Icons.text_fields;
    final Color iconColor = isMCQ
        ? (answer.isCorrect == true ? Colors.green : Colors.red)
        : Colors.blue;
    
    // Create a controller for this question if it doesn't exist
    if (!_questionGradeControllers.containsKey(index)) {
      // For MCQ, pre-fill with max grade if correct, 0 if incorrect
      if (isMCQ) {
        _questionGradeControllers[index] = TextEditingController(
          text: answer.isCorrect == true ? answer.questionGrade.toString() : "0"
        );
      } else {
        _questionGradeControllers[index] = TextEditingController();
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: cardColor,
          child: Icon(statusIcon, color: iconColor, size: 20),
        ),
        title: Text(
          'Question ${index + 1}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimaryColor,
          ),
        ),
        subtitle: Text(
          '${answer.type.toUpperCase()} • ${answer.questionGrade} points',
          style: TextStyle(
            color: AppTheme.textSecondaryColor,
            fontSize: 12,
          ),
        ),
        trailing: Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          child: Text(
            isMCQ
                ? (answer.isCorrect == true ? 'Correct' : 'Incorrect')
                : 'Text Answer',
            style: TextStyle(
              color: iconColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Question:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  answer.question,
                  style: TextStyle(
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Student Answer:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  answer.userAnswer,
                  style: TextStyle(
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
                SizedBox(height: 16),
                if (!isMCQ) ...[
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _questionGradeControllers[index],
                          decoration: InputDecoration(
                            labelText: 'Grade (max: ${answer.questionGrade})',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            try {
                              final grade = int.parse(value);
                              if (grade < 0) return 'Must be positive';
                              if (grade > answer.questionGrade) return 'Exceeds max grade';
                            } catch (e) {
                              return 'Invalid number';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _questionGradeControllers[index],
                          decoration: InputDecoration(
                            labelText: 'Grade (max: ${answer.questionGrade})',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          enabled: false,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
