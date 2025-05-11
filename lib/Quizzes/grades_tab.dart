import 'package:admin_dashboard/Models/quiz_answer.dart';
import 'package:admin_dashboard/Quizzes/quiz_grading_screen.dart';
import 'package:admin_dashboard/Theme.dart';
import 'package:admin_dashboard/provider/quiz_answer_provider.dart';
import 'package:admin_dashboard/provider/quiz_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

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
    _loadQuizzes();
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildQuizSelector(),
        const SizedBox(height: 24),
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
    );
  }

  Widget _buildQuizSelector() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return DropdownButtonFormField<int>(
      decoration: AppTheme.inputDecoration('Select Quiz'),
      value: selectedQuizId,
      items: [
        const DropdownMenuItem<int>(
          value: null,
          child: Text('Select a quiz'),
        ),
        ...quizzes.map((quiz) => DropdownMenuItem<int>(
              value: quiz.id,
              child: Text('${quiz.name} (${quiz.type})'),
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

        if (provider.quizAnswers.isEmpty) {
          return Center(
            child: Text('No submissions found for this quiz', style: AppTheme.bodyLarge),
          );
        }

        // Initialize controllers for each answer if not already created
        for (var answer in provider.quizAnswers) {
          if (!_gradeControllers.containsKey(answer.id)) {
            _gradeControllers[answer.id] = TextEditingController(
              text: answer.grade?.toString() ?? '',
            );
          } else if (answer.grade != null && _gradeControllers[answer.id]!.text.isEmpty) {
            // Update controller if grade exists but controller is empty
            _gradeControllers[answer.id]!.text = answer.grade.toString();
          }
        }

        // Get the max grade for this quiz
        final maxGrade = provider.quizAnswers.isNotEmpty && provider.quizAnswers[0].quiz != null
            ? provider.quizAnswers[0].quiz!['grade'] ?? 100
            : 100;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                        columns: [
                          DataColumn(label: Text('Student')),
                          DataColumn(label: Text('Student Code')),
                          DataColumn(label: Text('Submission Date')),
                          DataColumn(label: Text('Status')),
                          DataColumn(label: Text('Grade')),
                          DataColumn(label: Text('Actions')),
                        ],
                        rows: provider.quizAnswers.map((answer) {
                          final studentName = answer.student?['user']?['name'] ?? 'Unknown Student';
                          final studentCode = answer.student?['studentCode'] ?? '';
                          final submissionDate = DateFormat('MMM d, y').format(answer.createdAt);
                          final status = answer.grade != null ? 'Graded' : 'Not Graded';

                          return DataRow(
                            cells: [
                              DataCell(Text(studentName)),
                              DataCell(Text(studentCode)),
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
                                          suffixText: '/$maxGrade',
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

                                        if (grade > maxGrade) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Grade cannot exceed $maxGrade')),
                                          );
                                          return;
                                        }

                                        // Store context before async gap
                                        final scaffoldMessenger = ScaffoldMessenger.of(context);

                                        try {
                                          await provider.gradeQuizAnswer(answer.id, grade);
                                          if (mounted) {
                                            scaffoldMessenger.showSnackBar(
                                              SnackBar(content: Text('Quiz graded successfully')),
                                            );
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
                                        builder: (context) => QuizGradingScreen(quizAnswerId: answer.id),
                                      ),
                                    ).then((_) {
                                      // Refresh the list when returning from grading screen
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

        if (provider.quizAnswers.isEmpty) {
          return Center(
            child: Text('No submissions found for this quiz', style: AppTheme.bodyLarge),
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final isWideScreen = constraints.maxWidth > 900;
            return isWideScreen
                ? _buildQuizAnswersGrid(provider.quizAnswers)
                : _buildQuizAnswersListView(provider.quizAnswers);
          },
        );
      },
    );
  }

  Widget _buildQuizAnswersGrid(List<QuizAnswer> answers) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: answers.length,
      itemBuilder: (context, index) => _buildQuizAnswerCard(answers[index]),
    );
  }

  Widget _buildQuizAnswersListView(List<QuizAnswer> answers) {
    return ListView.separated(
      itemCount: answers.length,
      separatorBuilder: (context, index) => Divider(),
      itemBuilder: (context, index) => _buildQuizAnswerListItem(answers[index]),
    );
  }

  Widget _buildQuizAnswerCard(QuizAnswer answer) {
    final studentName = answer.student?['user']?['name'] ?? 'Unknown Student';
    final studentCode = answer.student?['studentCode'] ?? '';
    final quizName = answer.quiz?['name'] ?? 'Unknown Quiz';
    final maxGrade = answer.quiz?['grade'] ?? 100;

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuizGradingScreen(quizAnswerId: answer.id),
            ),
          ).then((_) {
            // Refresh the list when returning from grading screen
            if (selectedQuizId != null) {
              _loadQuizAnswers();
            }
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                studentName,
                style: AppTheme.headingMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4),
              Text(
                'Student Code: $studentCode',
                style: AppTheme.bodyMedium,
              ),
              SizedBox(height: 8),
              Text(
                'Quiz: $quizName',
                style: AppTheme.bodyMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('MMM d, y').format(answer.createdAt),
                    style: AppTheme.bodyMedium,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: answer.grade != null
                          ? Colors.green.withAlpha(25)
                          : Colors.orange.withAlpha(25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      answer.grade != null
                          ? 'Graded: ${answer.grade}/$maxGrade'
                          : 'Not Graded',
                      style: AppTheme.bodyMedium.copyWith(
                        color: answer.grade != null ? Colors.green : Colors.orange,
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

  Widget _buildQuizAnswerListItem(QuizAnswer answer) {
    final studentName = answer.student?['user']?['name'] ?? 'Unknown Student';
    final studentCode = answer.student?['studentCode'] ?? '';
    final quizName = answer.quiz?['name'] ?? 'Unknown Quiz';
    final maxGrade = answer.quiz?['grade'] ?? 100;

    return ListTile(
      title: Text(studentName, style: AppTheme.headingMedium),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Student Code: $studentCode'),
          Text('Quiz: $quizName'),
          Text('Submitted: ${DateFormat('MMM d, y').format(answer.createdAt)}'),
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
          answer.grade != null ? 'Graded: ${answer.grade}/$maxGrade' : 'Not Graded',
          style: TextStyle(
            color: answer.grade != null ? Colors.green : Colors.orange,
          ),
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuizGradingScreen(quizAnswerId: answer.id),
          ),
        ).then((_) {
          // Refresh the list when returning from grading screen
          if (selectedQuizId != null) {
            _loadQuizAnswers();
          }
        });
      },
    );
  }
}
