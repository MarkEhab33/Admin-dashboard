import 'package:admin_dashboard/Quizzes/quiz_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Theme.dart';
import 'create_quiz_screen.dart';
import '../provider/quiz_provider.dart';
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

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
      Provider.of<QuizProvider>(context, listen: false).fetchQuizzes()
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
    return Consumer<QuizProvider>(
      builder: (context, provider, _) {
        final uniqueSubjects = provider.quizzes
            .map((quiz) => _UniqueItem(
                  quiz.subject['id'] as int,
                  quiz.subject['name'] as String,
                ))
            .toSet()
            .toList()
          ..sort((a, b) => a.name.compareTo(b.name));

        return Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<int>(
                decoration: AppTheme.inputDecoration('Select Subject'),
                value: selectedSubjectId,
                items: [
                  const DropdownMenuItem<int>(
                    value: null,
                    child: Text('All Subjects'),
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
          ],
        );
      },
    );
  }

  Widget _buildQuizzesList() {
    return Consumer<QuizProvider>(
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
            child: Text('No quizzes found', style: AppTheme.bodyLarge),
          );
        }

        return _buildQuizzesListView(provider.quizzes);
      },
    );
  }



  Widget _buildQuizzesListView(List<QuizGet> quizzes) {
    return ListView.separated(
      itemCount: quizzes.length,
      separatorBuilder: (context, index) => Divider(),
      itemBuilder: (context, index) => _buildQuizListItem(quizzes[index]),
    );
  }


  Widget _buildQuizListItem(QuizGet quiz) {
    return ListTile(
      title: Text(quiz.name, style: AppTheme.headingMedium),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Subject: ${quiz.subject['name']}'),
        ],
      ),
      trailing: Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          quiz.type,
          style: TextStyle(color: AppTheme.primaryColor),
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
    );
  }
}


















