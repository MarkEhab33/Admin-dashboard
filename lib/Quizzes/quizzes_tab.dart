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

class _QuizzesTabState extends State<QuizzesTab> {
  int? selectedSemesterId;
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
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Manage Quizzes',
                  style: AppTheme.headingLarge,
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text('Create New Quiz'),
                  style: AppTheme.primaryButtonStyle,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CreateQuizScreen()),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildFilters(),
            const SizedBox(height: 24),
            Expanded(
              child: _buildQuizzesList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<int>(
            decoration: AppTheme.inputDecoration('Select Semester'),
            value: selectedSemesterId,
            items: [
              DropdownMenuItem<int>(
                value: null,
                child: Text('All Semesters'),
              ),
              // Add your semester items here
            ],
            onChanged: (value) {
              setState(() {
                selectedSemesterId = value;
              });
              Provider.of<QuizProvider>(context, listen: false)
                  .fetchQuizzes(semesterId: value, subjectId: selectedSubjectId);
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: DropdownButtonFormField<int>(
            decoration: AppTheme.inputDecoration('Select Subject'),
            value: selectedSubjectId,
            items: [
              DropdownMenuItem<int>(
                value: null,
                child: Text('All Subjects'),
              ),
              // Add your subject items here
            ],
            onChanged: (value) {
              setState(() {
                selectedSubjectId = value;
              });
              Provider.of<QuizProvider>(context, listen: false)
                  .fetchQuizzes(semesterId: selectedSemesterId, subjectId: value);
            },
          ),
        ),
      ],
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

        return LayoutBuilder(
          builder: (context, constraints) {
            final isWideScreen = constraints.maxWidth > 900;
            return isWideScreen
                ? _buildQuizzesGrid(provider.quizzes)
                : _buildQuizzesListView(provider.quizzes);
          },
        );
      },
    );
  }

  Widget _buildQuizzesGrid(List<QuizGet> quizzes) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: quizzes.length,
      itemBuilder: (context, index) => _buildQuizCard(quizzes[index]),
    );
  }

  Widget _buildQuizzesListView(List<QuizGet> quizzes) {
    return ListView.separated(
      itemCount: quizzes.length,
      separatorBuilder: (context, index) => Divider(),
      itemBuilder: (context, index) => _buildQuizListItem(quizzes[index]),
    );
  }

  Widget _buildQuizCard(QuizGet quiz) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuizDetailsScreen(quizId: quiz.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      quiz.name,
                      style: AppTheme.headingMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'edit') {
                        // Fetch full quiz details before editing
                        await Provider.of<QuizProvider>(context, listen: false)
                            .fetchQuizById(quiz.id);
                        final quizDetails = Provider.of<QuizProvider>(context, listen: false).currentQuiz;
                        if (quizDetails != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CreateQuizScreen(quizToEdit: quizDetails),
                            ),
                          );
                        }
                      } else if (value == 'delete') {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Delete Quiz'),
                            content: Text('Are you sure you want to delete this quiz?'),
                            actions: [
                              TextButton(
                                child: Text('Cancel'),
                                onPressed: () => Navigator.pop(context),
                              ),
                              TextButton(
                                child: Text('Delete'),
                                onPressed: () async {
                                  try {
                                    await Provider.of<QuizProvider>(context, listen: false)
                                        .deleteQuiz(quiz.id);
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Quiz deleted successfully')),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(e.toString()),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Subject: ${quiz.subject['name']}',
                style: AppTheme.bodyMedium,
              ),
              Text(
                'Semester: ${quiz.semester['name']}',
                style: AppTheme.bodyMedium,
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('MMM d, y').format(quiz.createdAt),
                    style: AppTheme.bodyMedium,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      quiz.type,
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuizListItem(QuizGet quiz) {
    return ListTile(
      title: Text(quiz.name, style: AppTheme.headingMedium),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Subject: ${quiz.subject['name']}'),
          Text('Semester: ${quiz.semester['name']}'),
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




