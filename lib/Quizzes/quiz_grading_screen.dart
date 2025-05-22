import 'package:admin_dashboard/Models/quiz_answer.dart';
import 'package:admin_dashboard/Models/quiz.dart';
import 'package:admin_dashboard/Theme.dart';
import 'package:admin_dashboard/provider/quiz_answer_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Models/question.dart';

class QuizGradingScreen extends StatefulWidget {
  final int quizAnswerId;
  final int quizId;

  const QuizGradingScreen({Key? key, required this.quizAnswerId,required this.quizId}) : super(key: key);

  @override
  _QuizGradingScreenState createState() => _QuizGradingScreenState();
}

class _QuizGradingScreenState extends State<QuizGradingScreen> {
  final TextEditingController _gradeController = TextEditingController();
  int? _maxGrade;

  @override
  void initState() {
    super.initState();
    // Use a safer approach to avoid BuildContext across async gaps
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<QuizAnswerProvider>(context, listen: false)
            .fetchQuizAnswersByQuizId(widget.quizAnswerId);
      }
    });
  }

  @override
  void dispose() {
    _gradeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Grade Quiz Submission'),
      ),
      body: Consumer<QuizAnswerProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (provider.error.isNotEmpty) {
            return Center(child: Text(provider.error));
          }

          final quizAnswer = provider.currentQuizAnswer;
          if (quizAnswer == null) {
            return Center(child: Text('Quiz submission not found'));
          }

          // Set max grade from quiz data
          if (_maxGrade == null && quizAnswer.quiz != null) {
            _maxGrade = quizAnswer.quiz!['grade'] as int;
            // Pre-fill with existing grade if available
            if (quizAnswer.grade != null) {
              _gradeController.text = quizAnswer.grade.toString();
            }
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(quizAnswer),
                  SizedBox(height: 24),
                  _buildGradingSection(quizAnswer, provider),
                  SizedBox(height: 32),
                  _buildAnswersList(quizAnswer),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(QuizAnswer quizAnswer) {
    final studentName = quizAnswer.student?['user']?['name'] ?? 'Unknown Student';
    final studentCode = quizAnswer.student?['studentCode'] ?? '';
    final quizName = quizAnswer.quiz?['name'] ?? 'Unknown Quiz';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Student: $studentName ($studentCode)', style: AppTheme.headingMedium),
            SizedBox(height: 8),
            Text('Quiz: $quizName', style: AppTheme.bodyLarge),
            SizedBox(height: 8),
            Text(
              'Submitted: ${quizAnswer.createdAt.toLocal().toString().split('.')[0]}',
              style: AppTheme.bodyMedium,
            ),
            if (quizAnswer.grade != null) ...[
              SizedBox(height: 8),
              Text(
                'Current Grade: ${quizAnswer.grade} / ${quizAnswer.quiz?['grade'] ?? 100}',
                style: AppTheme.bodyLarge.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGradingSection(QuizAnswer quizAnswer, QuizAnswerProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Assign Grade', style: AppTheme.headingMedium),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _gradeController,
                    decoration: AppTheme.inputDecoration('Grade (out of ${_maxGrade ?? 100})'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a grade';
                      }
                      final grade = int.tryParse(value);
                      if (grade == null) {
                        return 'Please enter a valid number';
                      }
                      if (grade < 0) {
                        return 'Grade cannot be negative';
                      }
                      if (_maxGrade != null && grade > _maxGrade!) {
                        return 'Grade cannot exceed $_maxGrade';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () async {
                    if (_gradeController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please enter a grade')),
                      );
                      return;
                    }

                    final grade = int.tryParse(_gradeController.text);
                    if (grade == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please enter a valid number')),
                      );
                      return;
                    }

                    if (grade < 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Grade cannot be negative')),
                      );
                      return;
                    }

                    if (_maxGrade != null && grade > _maxGrade!) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Grade cannot exceed $_maxGrade')),
                      );
                      return;
                    }

                    try {
                      await provider.gradeQuizAnswer(quizAnswer.id, grade);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Quiz graded successfully')),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error grading quiz: $e')),
                        );
                      }
                    }
                  },
                  style: AppTheme.primaryButtonStyle,
                  child: Text('Submit Grade'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswersList(QuizAnswer quizAnswer) {
    if (quizAnswer.combinedData == null || quizAnswer.combinedData!.isEmpty) {
      return Center(child: Text('No answers available'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Student Answers', style: AppTheme.headingMedium),
        SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: quizAnswer.combinedData!.length,
          itemBuilder: (context, index) {
            final item = quizAnswer.combinedData![index];
            return Card(
              margin: EdgeInsets.only(bottom: 16),
              child: ExpansionTile(
                title: Text(
                  'Question ${index + 1}',
                  style: AppTheme.bodyLarge,
                ),
                subtitle: Text(
                  'Type: ${item.question.type.toString().split('.').last.toUpperCase()} - ${item.question.grade} points',
                  style: AppTheme.bodyMedium,
                ),
                children: [
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Question:', style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                        Text(item.question.question, style: AppTheme.bodyLarge),
                        SizedBox(height: 16),
                        Text('Student Answer:', style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        _buildStudentAnswer(item),
                        SizedBox(height: 16),
                        _buildCorrectAnswer(item.question),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStudentAnswer(CombinedQuestionAnswer item) {
    switch (item.question.type) {
      case QuestionType.mcq:
        final selectedAnswerId = item.studentAnswer.selectedAnswerId;
        final selectedAnswer = item.question.answers?.firstWhere(
          (a) => a.id == selectedAnswerId,
          orElse: () => MCQAnswer(id: -1, text: 'No answer selected'),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Selected: ${selectedAnswer?.text ?? 'None'}'),
            if (selectedAnswerId != null && item.question.correctAnswerId != null)
              Icon(
                selectedAnswerId == item.question.correctAnswerId
                    ? Icons.check_circle
                    : Icons.cancel,
                color: selectedAnswerId == item.question.correctAnswerId
                    ? Colors.green
                    : Colors.red,
              ),
          ],
        );

      case QuestionType.text:
        return Text(item.studentAnswer.text ?? 'No answer provided');

      case QuestionType.record:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Audio Recording:'),
            if (item.studentAnswer.recordingUrl != null)
              TextButton.icon(
                icon: Icon(Icons.play_arrow),
                label: Text('Play Recording'),
                onPressed: () {
                  // Implement audio playback functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Audio playback not implemented')),
                  );
                },
              )
            else
              Text('No recording provided'),
          ],
        );

    }
  }

  Widget _buildCorrectAnswer(Question question) {
    switch (question.type) {
      case QuestionType.mcq:
        final correctAnswerId = question.correctAnswerId;
        final correctAnswer = question.answers?.firstWhere(
          (a) => a.id == correctAnswerId,
          orElse: () => MCQAnswer(id: -1, text: 'No correct answer defined'),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Correct Answer:', style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
            Text(correctAnswer?.text ?? 'None'),
          ],
        );

      case QuestionType.text:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Correct Answer:', style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
            Text(question.correctAnswer ?? 'No correct answer defined'),
          ],
        );

      case QuestionType.record:
        return SizedBox(); // No correct answer for recordings

    }
  }
}
