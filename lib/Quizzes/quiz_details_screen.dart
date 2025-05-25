import 'package:admin_dashboard/Models/quiz.dart';
import 'package:admin_dashboard/Quizzes/quiz_answers_list_screen.dart';
import 'package:admin_dashboard/Quizzes/simple_student_selection_dialog.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../Models/question.dart';
import '../Models/simple_student.dart';
import '../Theme.dart';
import '../provider/quiz_provider.dart';
import '../provider/semesters_provider.dart';
import '../Constants/globals.dart';
import 'package:provider/provider.dart';

class QuizDetailsScreen extends StatefulWidget {
  final int quizId;
  final int? semesterId;
  const QuizDetailsScreen({Key? key, required this.quizId, this.semesterId}) : super(key: key);

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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(quiz.name, style: AppTheme.headingLarge),
            ),
            Row(
              children: [
                ElevatedButton.icon(
                  icon: Icon(Icons.redo, color: Colors.white),
                  label: Text('Add Redo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => _showAddRedoDialog(quiz),
                ),
                SizedBox(width: 12),
                ElevatedButton.icon(
                  icon: Icon(Icons.list_alt, color: Colors.white),
                  label: Text('View Submissions'),
                  style: AppTheme.primaryButtonStyle,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuizAnswersListScreen(
                          quizId: quiz.id,
                          quizName: quiz.name,
                          semesterId: widget.semesterId,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
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

  Future<void> _showAddRedoDialog(QuizDetails quiz) async {
    try {
      final semesterProvider = Provider.of<SemestersProvider>(context, listen: false);

      // If semesterId is not provided, try to get current semester or let user select
      int? targetSemesterId = widget.semesterId;

      if (targetSemesterId == null) {
        targetSemesterId = await _getSemesterIdForRedo(semesterProvider);
        if (targetSemesterId == null) {
          return; // User cancelled or no semester available
        }
      }

      // Get students from the dedicated endpoint
      final students = await _fetchStudentsInSemester(targetSemesterId);

      if (!mounted) return;

      if (students.isEmpty) {
        _showErrorSnackBar('No students found in this semester');
        return;
      }

      // Show student selection dialog
      final selectedStudent = await showDialog<SimpleStudent>(
        context: context,
        builder: (context) => SimpleStudentSelectionDialog(
          students: students,
          title: 'Select Student for Redo',
        ),
      );

      if (mounted && selectedStudent != null) {
        await _addRedoForStudent(selectedStudent, quiz);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error loading students: $e');
      }
    }
  }

  Future<int?> _getSemesterIdForRedo(SemestersProvider semesterProvider) async {
    try {
      // Fetch all semesters
      await semesterProvider.fetchSemesters();

      if (!mounted) return null;

      final semesters = semesterProvider.semesters;

      if (semesters.isEmpty) {
        _showErrorSnackBar('No semesters available');
        return null;
      }

      // If there's only one semester, use it
      if (semesters.length == 1) {
        return semesters.first.id;
      }

      // Check if there's a current semester
      final currentSemester = semesters.where((s) => s.isCurrent).firstOrNull;
      if (currentSemester != null) {
        return currentSemester.id;
      }

      // Show semester selection dialog
      final selectedSemester = await showDialog<int>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Select Semester'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Please select a semester to add redo for:'),
              SizedBox(height: 16),
              ...semesters.map((semester) => ListTile(
                title: Text(semester.name),
                subtitle: Text('${semester.students.length} students'),
                onTap: () => Navigator.of(context).pop(semester.id),
              )),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
          ],
        ),
      );

      return selectedSemester;
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error loading semesters: $e');
      }
      return null;
    }
  }

  Future<List<SimpleStudent>> _fetchStudentsInSemester(int semesterId) async {
    try {
      final response = await http.get(
        Uri.parse('${Globals.baseUrl}/semester/$semesterId/students'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> studentsData = jsonResponse['data']['students'] as List<dynamic>;

        return studentsData
            .map((studentJson) => SimpleStudent.fromJson(studentJson))
            .toList();
      } else {
        throw Exception('Failed to fetch students: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching students: $e');
    }
  }

  Future<void> _addRedoForStudent(SimpleStudent student, QuizDetails quiz) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Adding redo for ${student.name}...'),
                ],
              ),
            ),
          ),
        ),
      );

      final quizProvider = Provider.of<QuizProvider>(context, listen: false);
      final result = await quizProvider.addQuizRedo(student.id, quiz.id);

      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();

        if (result['success']) {
          _showSuccessSnackBar(result['message']);
        } else {
          _showErrorSnackBar(result['message']);
        }
      }
    } catch (e) {
      // Close loading dialog if still open
      if (mounted) {
        Navigator.of(context).pop();
        _showErrorSnackBar('Error adding redo: $e');
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 4),
      ),
    );
  }
}



