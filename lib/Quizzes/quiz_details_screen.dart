import 'package:admin_dashboard/Models/quiz.dart';
import 'package:flutter/material.dart';
import '../Theme.dart';
import '../provider/quiz_provider.dart';
import 'package:provider/provider.dart';

class QuizDetailsScreen extends StatefulWidget {
  final int quizId;

  const QuizDetailsScreen({Key? key, required this.quizId}) : super(key: key);

  @override
  _QuizDetailsScreenState createState() => _QuizDetailsScreenState();
}

class _QuizDetailsScreenState extends State<QuizDetailsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<QuizProvider>(context, listen: false).fetchQuizById(widget.quizId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz Details'),
      ),
      body: Consumer<QuizProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (provider.error.isNotEmpty) {
            return Center(child: Text(provider.error));
          }

          final quiz = provider.currentQuiz;
          if (quiz == null) {
            return Center(child: Text('Quiz not found'));
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(quiz),
                  SizedBox(height: 32),
                  _buildInfoCards(quiz),
                  SizedBox(height: 32),
                  _buildQuestionsList(quiz),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(QuizDetails quiz) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(quiz.name, style: AppTheme.headingLarge),
        SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.school, size: 20, color: AppTheme.textSecondaryColor),
            SizedBox(width: 8),
            Text(
              '${quiz.subject['name']} (${quiz.subject['code']})',
              style: AppTheme.bodyLarge,
            ),
          ],
        ),
        Row(
          children: [
            Icon(Icons.calendar_today, size: 20, color: AppTheme.textSecondaryColor),
            SizedBox(width: 8),
            Text(
              quiz.semester['name'],
              style: AppTheme.bodyLarge,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoCards(QuizDetails quiz) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth > 768;
        final cards = [
          _buildInfoCard(
            'Type',
            quiz.type.toUpperCase(),
            Icons.quiz,
            AppTheme.primaryColor,
          ),
          _buildInfoCard(
            'Grade',
            '${quiz.grade} points',
            Icons.grade,
            Colors.orange,
          ),
          _buildInfoCard(
            'Attempts',
            '${quiz.numberOfAttempts}',
            Icons.repeat,
            Colors.green,
          ),
          _buildInfoCard(
            'Time Limit',
            '${quiz.timeLimit} min',
            Icons.timer,
            Colors.blue,
          ),
        ];

        return isWideScreen
            ? Row(
                children: cards.map((card) => Expanded(child: card)).toList(),
              )
            : Column(
                children: cards,
              );
      },
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon, Color color) {
    return Card(
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            SizedBox(height: 8),
            Text(title, style: AppTheme.bodyMedium),
            SizedBox(height: 4),
            Text(
              value,
              style: AppTheme.headingMedium.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionsList(QuizDetails quiz) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Questions', style: AppTheme.headingMedium),
        SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: quiz.content.length,
          itemBuilder: (context, index) {
            final question = quiz.content[index];
            return Card(
              margin: EdgeInsets.only(bottom: 16),
              child: ExpansionTile(
                title: Text(
                  'Question ${index + 1}',
                  style: AppTheme.bodyLarge,
                ),
                subtitle: Text(
                  'Type: ${question.type.toString().split('.').last.toUpperCase()} - ${question.grade} points',
                  style: AppTheme.bodyMedium,
                ),
                children: [
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(question.question, style: AppTheme.bodyLarge),
                        SizedBox(height: 8),
                        if (question.type == QuestionType.mcq) ...[
                          ...question.answers!.map((answer) => ListTile(
                                leading: Icon(
                                  answer.id == question.correctAnswerId
                                      ? Icons.check_circle
                                      : Icons.radio_button_unchecked,
                                  color: answer.id == question.correctAnswerId
                                      ? Colors.green
                                      : null,
                                ),
                                title: Text(answer.text),
                              )),
                        ] else if (question.type == QuestionType.text &&
                            question.correctAnswer != null) ...[
                          Text(
                            'Correct Answer: ${question.correctAnswer}',
                            style: AppTheme.bodyMedium,
                          ),
                        ] else if (question.type == QuestionType.record &&
                            question.maxDuration != null) ...[
                          Text(
                            'Max Duration: ${question.maxDuration} seconds',
                            style: AppTheme.bodyMedium,
                          ),
                        ],
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
}



