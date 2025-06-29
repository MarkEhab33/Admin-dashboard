import 'package:admin_dashboard/Quizzes/quiz_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Theme.dart';
import 'create_quiz_screen.dart';
import '../provider/quiz_provider.dart' as quiz_provider;
import '../l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class QuizzesTab extends StatefulWidget {
  @override
  _QuizzesTabState createState() => _QuizzesTabState();
}

class _UniqueItem {
  final int id;
  final String name;

  _UniqueItem(this.id, this.name);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _UniqueItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}

class _QuizzesTabState extends State<QuizzesTab> {
  int? selectedSubjectId;
  String selectedQuizFilter = 'all'; // 'all', 'regular', 'recording'

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
      Provider.of<quiz_provider.QuizProvider>(context, listen: false).fetchQuizzes()
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        _buildFilters(),
        const SizedBox(height: 24),
        Expanded(
          child: _buildQuizzesList(),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return Consumer<quiz_provider.QuizProvider>(
      builder: (context, provider, _) {
        final uniqueSubjects = provider.quizzes
            .map((quiz) => _UniqueItem(
                  quiz.subject['id'] as int,
                  quiz.subject['name'] as String,
                ))
            .toSet()
            .toList()
          ..sort((a, b) => a.name.compareTo(b.name));

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    decoration: AppTheme.inputDecoration(AppLocalizations.of(context)!.subjects),
                    value: selectedSubjectId,
                    items: [
                      DropdownMenuItem<int>(
                        value: null,
                        child: Text('${AppLocalizations.of(context)!.allQuizzes} ${AppLocalizations.of(context)!.subjects}'),
                      ),
                      ...uniqueSubjects.map((subject) => DropdownMenuItem<int>(
                            value: subject.id,
                            child: Text(subject.name),
                          )),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedSubjectId = value;
                      });
                      provider.fetchQuizzes(
                        subjectId: value,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: AppTheme.inputDecoration(AppLocalizations.of(context)!.quizType),
                    value: selectedQuizFilter,
                    items: [
                      DropdownMenuItem<String>(
                        value: 'all',
                        child: Text(AppLocalizations.of(context)!.allQuizzes),
                      ),
                      DropdownMenuItem<String>(
                        value: 'regular',
                        child: Text(AppLocalizations.of(context)!.regularQuizzes),
                      ),
                      DropdownMenuItem<String>(
                        value: 'recording',
                        child: Text(AppLocalizations.of(context)!.recordingQuizzesTasmi3),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedQuizFilter = value ?? 'all';
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuizzesList() {
    return Consumer<quiz_provider.QuizProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        if (provider.error.isNotEmpty) {
          return Center(
            child: Text(provider.error, style: TextStyle(color: Colors.red)),
          );
        }

        if (provider.quizzes.isEmpty) {
          return Center(
            child: Text(AppLocalizations.of(context)!.noDataAvailable, style: AppTheme.bodyLarge),
          );
        }

        // Apply filter
        List<quiz_provider.QuizGet> filteredQuizzes = provider.quizzes.where((quiz) {
          switch (selectedQuizFilter) {
            case 'regular':
              return quiz.isRecord != true;
            case 'recording':
              return quiz.isRecord == true;
            default:
              return true;
          }
        }).toList();

        return _buildQuizzesListView(filteredQuizzes);
      },
    );
  }



  Widget _buildQuizzesListView(List<quiz_provider.QuizGet> quizzes) {
    return ListView.separated(
      itemCount: quizzes.length,
      separatorBuilder: (context, index) => Divider(),
      itemBuilder: (context, index) => _buildQuizListItem(quizzes[index]),
    );
  }


  Widget _buildQuizListItem(quiz_provider.QuizGet quiz) {
    final bool isRecordingQuiz = quiz.isRecord == true;
    final Color cardColor = isRecordingQuiz ? Colors.green.shade50 : Colors.white;
    final Color borderColor = isRecordingQuiz ? Colors.green.shade200 : Colors.grey.shade200;
    final Color typeColor = isRecordingQuiz ? Colors.green : AppTheme.primaryColor;
    final Color typeBackgroundColor = isRecordingQuiz ? Colors.green.withOpacity(0.1) : AppTheme.primaryColor.withOpacity(0.1);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor, width: 1),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: typeBackgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isRecordingQuiz ? Icons.mic : Icons.quiz,
            color: typeColor,
            size: 24,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(quiz.name, style: AppTheme.headingMedium),
            ),
            if (isRecordingQuiz)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  AppLocalizations.of(context)!.tasmi3,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('${AppLocalizations.of(context)!.subjects}: ${quiz.subject['name']}'),
            if (isRecordingQuiz)
              Row(
                children: [
                  Icon(Icons.mic, size: 14, color: Colors.green.shade600),
                  const SizedBox(width: 4),
                  Text(
                    AppLocalizations.of(context)!.audioRecordingAssessment,
                    style: TextStyle(
                      color: Colors.green.shade600,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: typeBackgroundColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            quiz.type,
            style: TextStyle(color: typeColor, fontWeight: FontWeight.w500),
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuizDetailsScreen(quizId: quiz.id),
            ),
          );
        },
      ),
    );
  }
}


















