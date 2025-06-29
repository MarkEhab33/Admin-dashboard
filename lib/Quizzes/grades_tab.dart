import 'package:admin_dashboard/Models/quiz_answer.dart';
import 'package:admin_dashboard/Quizzes/quiz_grading_screen.dart';
import 'package:admin_dashboard/Theme.dart';
import 'package:admin_dashboard/provider/quiz_answer_provider.dart';
import 'package:admin_dashboard/provider/quiz_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';

class GradesTab extends StatefulWidget {
  @override
  _GradesTabState createState() => _GradesTabState();
}

class _GradesTabState extends State<GradesTab> with SingleTickerProviderStateMixin {
  int? selectedQuizId;
  List<QuizGet> quizzes = [];
  bool isLoading = true;
  final Map<int, TextEditingController> _gradeControllers = {};
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Use Future.microtask to schedule the loading after the current build is complete
    Future.microtask(() => _loadQuizzes());
  }

  @override
  void dispose() {
    _tabController.dispose();
    // Dispose all controllers
    _gradeControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _loadQuizzes() async {
    try {
      final quizProvider = Provider.of<QuizProvider>(context, listen: false);
      await quizProvider.fetchQuizzes();
      if (mounted) {
        setState(() {
          quizzes = quizProvider.quizzes;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading quizzes: $e')),
        );
      }
    }
  }

  void _loadQuizAnswers() {
    if (selectedQuizId != null) {
      Provider.of<QuizAnswerProvider>(context, listen: false)
          .fetchQuizAnswersByQuizId(selectedQuizId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildQuizSelector(),
        const SizedBox(height: 24),

        Expanded(
          child:
              _buildQuizAnswersTable(),


        ),
      ],
    );
  }

  Widget _buildQuizSelector() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return DropdownButtonFormField<int>(
      decoration: AppTheme.inputDecoration(AppLocalizations.of(context)!.quizDetails),
      value: selectedQuizId,
      items: [
        DropdownMenuItem<int>(
          value: null,
          child: Text(AppLocalizations.of(context)!.selectOption),
        ),
        ...quizzes.map((quiz) => DropdownMenuItem<int>(
              value: quiz.id,
              child: Row(
                children: [
                  if (quiz.isRecord == true) ...[
                    Icon(Icons.mic, size: 16, color: Colors.green),
                    const SizedBox(width: 8),
                  ] else ...[
                    Icon(Icons.quiz, size: 16, color: AppTheme.primaryColor),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Text('${quiz.name} (${quiz.type})'),
                  ),
                  if (quiz.isRecord == true)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.tasmi3,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            )),
      ],
      onChanged: (value) {
        setState(() {
          selectedQuizId = value;
          // Clear existing controllers
          _gradeControllers.forEach((_, controller) => controller.dispose());
          _gradeControllers.clear();
        });
        if (value != null) {
          _loadQuizAnswers();
        }
      },
    );
  }

  Widget _buildQuizAnswersTable() {
    if (selectedQuizId == null) {
      return Center(
        child: Text('Select a quiz to view submissions', style: AppTheme.bodyLarge),
      );
    }

    return Consumer<QuizAnswerProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        if (provider.error.isNotEmpty) {
          return Column(
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

        // Get the max grade for this quiz (we'll need to get this from the quiz provider or set a default)
        final maxGrade = 100; // Default value, you might want to get this from the quiz details

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Student Submissions',
                  style: AppTheme.headingMedium,
                ),
                SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columnSpacing: 120,
                        columns: [
                          DataColumn(label: Text('Student')),
                          DataColumn(label: Text('Student Code')),
                          DataColumn(label: Text('Submission Date')),
                          DataColumn(label: Text('Status')),
                          DataColumn(label: Text('Actions')),
                        ],
                        rows: quizAnswersList.answers.map((answer) {
                          final submissionDate = DateFormat('MMM d, y HH:mm').format(answer.submissionDate);

                          return DataRow(
                            cells: [
                              DataCell(Text(answer.studentName)),
                              DataCell(Text(answer.studentCode)),
                              DataCell(Text(submissionDate)),
                              DataCell(
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: answer.grade != null
                                        ? Colors.green.withAlpha(25)
                                        : Colors.orange.withAlpha(25),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: answer.grade != null ? Colors.green : Colors.orange,
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    answer.grade != null
                                        ? 'Graded: ${answer.grade}/$maxGrade'
                                        : 'Not Graded',
                                    style: TextStyle(
                                      color: answer.grade != null ? Colors.green : Colors.orange,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                ElevatedButton.icon(
                                  icon: Icon(Icons.visibility),
                                  label: Text('View Details'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryColor,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => QuizGradingScreen(
                                          quizAnswerId: answer.id,
                                          quizId: quizAnswersList.quizId
                                        ),
                                      ),
                                    ).then((_) {
                                      // Refresh the list when returning from details screen
                                      if (selectedQuizId != null) {
                                        _loadQuizAnswers();
                                      }
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
    if (selectedQuizId == null) {
      return Center(
        child: Text('Select a quiz to view submissions', style: AppTheme.bodyLarge),
      );
    }

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
    final maxGrade = 100; // Default value

    return Card(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
          child: Text(
            answer.studentName.isNotEmpty ? answer.studentName[0].toUpperCase() : '?',
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(answer.studentName, style: AppTheme.headingMedium),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Student Code: ${answer.studentCode}'),
            Text('Attempt: ${answer.attemptNumber}'),
            Text('Submitted: ${DateFormat('MMM d, y').format(answer.submissionDate)}'),
          ],
        ),
        trailing: Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: answer.grade != null
                ? Colors.green.withAlpha(25)
                : Colors.orange.withAlpha(25),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: answer.grade != null ? Colors.green : Colors.orange,
              width: 1,
            ),
          ),
          child: Text(
            answer.grade != null ? 'Graded: ${answer.grade}/$maxGrade' : 'Not Graded',
            style: TextStyle(
              color: answer.grade != null ? Colors.green : Colors.orange,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuizGradingScreen(
                quizAnswerId: answer.id,
                 quizId: selectedQuizId!,
              ),
            ),
          ).then((_) {
            if (selectedQuizId != null) {
              _loadQuizAnswers();
            }
          });
        },
      ),
    );
  }
}
