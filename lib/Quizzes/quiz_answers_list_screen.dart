import 'package:admin_dashboard/Models/quiz_answer.dart';
import 'package:admin_dashboard/Quizzes/quiz_grading_screen.dart';
import 'package:admin_dashboard/Theme.dart';
import 'package:admin_dashboard/provider/quiz_answer_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class QuizAnswersListScreen extends StatefulWidget {
  final int quizId;
  final String quizName;

  const QuizAnswersListScreen({
    Key? key,
    required this.quizId,
    required this.quizName,
  }) : super(key: key);

  @override
  _QuizAnswersListScreenState createState() => _QuizAnswersListScreenState();
}

class _QuizAnswersListScreenState extends State<QuizAnswersListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Map<int, TextEditingController> _gradeControllers = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadQuizAnswers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    // Dispose all controllers
    _gradeControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  void _loadQuizAnswers() {
    Provider.of<QuizAnswerProvider>(context, listen: false)
        .fetchQuizAnswersList(widget.quizId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz Submissions: ${widget.quizName}'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Student Submissions',
              style: AppTheme.headingLarge,
            ),
            const SizedBox(height: 16),
            TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: 'Table View'),
                Tab(text: 'Card View'),
              ],
              labelColor: AppTheme.primaryColor,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppTheme.primaryColor,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildQuizAnswersTable(),
                  _buildQuizAnswersList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizAnswersTable() {
    return Consumer<QuizAnswerProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        if (provider.error.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Error loading quiz submissions',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  provider.error,
                  style: TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadQuizAnswers,
                  child: Text('Retry'),
                ),
              ],
            ),
          );
        }

        final quizAnswersList = provider.quizAnswersList;
        if (quizAnswersList == null || quizAnswersList.answers.isEmpty) {
          return Center(
            child: Text('No submissions found for this quiz', style: AppTheme.bodyLarge),
          );
        }

        // Initialize controllers for each answer if not already created
        for (var answer in quizAnswersList.answers) {
          if (!_gradeControllers.containsKey(answer.id)) {
            _gradeControllers[answer.id] = TextEditingController(
              text: answer.grade?.toString() ?? '',
            );
          } else if (answer.grade != null && _gradeControllers[answer.id]!.text.isEmpty) {
            // Update controller if grade exists but controller is empty
            _gradeControllers[answer.id]!.text = answer.grade.toString();
          }
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Submissions: ${quizAnswersList.totalSubmissions}',
                  style: AppTheme.headingMedium,
                ),
                SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: [
                          DataColumn(label: Text('Student')),
                          DataColumn(label: Text('Student Code')),
                          DataColumn(label: Text('Attempt')),
                          DataColumn(label: Text('Submission Date')),
                          DataColumn(label: Text('Status')),
                          DataColumn(label: Text('Grade')),
                          DataColumn(label: Text('Actions')),
                        ],
                        rows: quizAnswersList.answers.map((answer) {
                          final submissionDate = DateFormat('MMM d, y HH:mm').format(answer.submissionDate);
                          final status = answer.grade != null ? 'Graded' : 'Not Graded';

                          return DataRow(
                            cells: [
                              DataCell(Text(answer.studentName)),
                              DataCell(Text(answer.studentCode)),
                              DataCell(Text('Attempt ${answer.attemptNumber}')),
                              DataCell(Text(submissionDate)),
                              DataCell(
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: answer.grade != null
                                        ? Colors.green.withAlpha(25)
                                        : Colors.orange.withAlpha(25),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    status,
                                    style: TextStyle(
                                      color: answer.grade != null ? Colors.green : Colors.orange,
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 80,
                                      child: TextField(
                                        controller: _gradeControllers[answer.id],
                                        decoration: InputDecoration(
                                          hintText: 'Grade',
                                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                          border: OutlineInputBorder(),
                                        ),
                                        keyboardType: TextInputType.number,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: () async {
                                        final gradeText = _gradeControllers[answer.id]!.text;
                                        if (gradeText.isEmpty) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Please enter a grade')),
                                          );
                                          return;
                                        }

                                        final grade = int.tryParse(gradeText);
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

                                        // Store context before async gap
                                        final scaffoldMessenger = ScaffoldMessenger.of(context);

                                        try {
                                          await Provider.of<QuizAnswerProvider>(context, listen: false)
                                              .gradeQuizAnswer(answer.id, grade);
                                          if (mounted) {
                                            scaffoldMessenger.showSnackBar(
                                              SnackBar(content: Text('Quiz graded successfully')),
                                            );
                                            // Reload the answers list
                                            _loadQuizAnswers();
                                          }
                                        } catch (e) {
                                          if (mounted) {
                                            scaffoldMessenger.showSnackBar(
                                              SnackBar(content: Text('Error grading quiz: $e')),
                                            );
                                          }
                                        }
                                      },
                                      child: Text('Save'),
                                    ),
                                  ],
                                ),
                              ),
                              DataCell(
                                ElevatedButton.icon(
                                  icon: Icon(Icons.visibility),
                                  label: Text('View Details'),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => QuizGradingScreen(quizAnswerId: answer.id,quizId: quizAnswersList.quizId,),
                                      ),
                                    ).then((_) {
                                      // Refresh the list when returning from grading screen
                                      _loadQuizAnswers();
                                    });
                                  },
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuizAnswersList() {
    return Consumer<QuizAnswerProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        if (provider.error.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Error loading quiz submissions',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  provider.error,
                  style: TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadQuizAnswers,
                  child: Text('Retry'),
                ),
              ],
            ),
          );
        }

        final quizAnswersList = provider.quizAnswersList;
        if (quizAnswersList == null || quizAnswersList.answers.isEmpty) {
          return Center(
            child: Text('No submissions found for this quiz', style: AppTheme.bodyLarge),
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final isWideScreen = constraints.maxWidth > 900;
            return _buildQuizAnswersListView(quizAnswersList.answers);
          },
        );
      },
    );
  }



  Widget _buildQuizAnswersListView(List<QuizAnswerSummary> answers) {
    return ListView.separated(
      itemCount: answers.length,
      separatorBuilder: (context, index) => Divider(),
      itemBuilder: (context, index) => _buildQuizAnswerListItem(answers[index]),
    );
  }



  Widget _buildQuizAnswerListItem(QuizAnswerSummary answer) {
    return ListTile(
      title: Text(answer.studentName, style: AppTheme.headingMedium),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Student Code: ${answer.studentCode}'),
          Text('Attempt: ${answer.attemptNumber}'),
          Text('Submitted: ${DateFormat('MMM d, y HH:mm').format(answer.submissionDate)}'),
        ],
      ),
      trailing: Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: answer.grade != null
              ? Colors.green.withAlpha(25)
              : Colors.orange.withAlpha(25),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          answer.grade != null ? 'Graded: ${answer.grade}' : 'Not Graded',
          style: TextStyle(
            color: answer.grade != null ? Colors.green : Colors.orange,
          ),
        ),
      ),

    );
  }
}