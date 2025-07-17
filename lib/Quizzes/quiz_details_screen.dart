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
import '../l10n/app_localizations.dart';
import '../widgets/coptic_text_field.dart';
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
    final bool isRecordingQuiz = quiz.isRecord == true;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isRecordingQuiz ? Colors.green.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isRecordingQuiz ? Colors.green.shade200 : Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isRecordingQuiz ? Colors.green.withOpacity(0.1) : AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isRecordingQuiz ? Icons.mic : Icons.quiz,
                  color: isRecordingQuiz ? Colors.green : AppTheme.primaryColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: CopticText(quiz.name, style: AppTheme.headingLarge),
                        ),
                        if (isRecordingQuiz)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.tasmi3,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.school, size: 20, color: AppTheme.textSecondaryColor),
                        const SizedBox(width: 8),
                        Text(
                          '${quiz.subject['name']} (${quiz.subject['code']})',
                          style: AppTheme.bodyLarge,
                        ),
                      ],
                    ),
                    if (isRecordingQuiz) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.mic, size: 16, color: Colors.green.shade600),
                          const SizedBox(width: 4),
                          Text(
                            AppLocalizations.of(context)!.audioRecordingAssessment,
                            style: TextStyle(
                              color: Colors.green.shade600,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
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
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.redo, color: Colors.white),
                  label: Text(AppLocalizations.of(context)!.addRedo),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => _showAddRedoDialog(quiz),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.list_alt, color: Colors.white),
                  label: Text(AppLocalizations.of(context)!.viewSubmissions),
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
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCards(QuizDetails quiz) {
    final bool isRecordingQuiz = quiz.isRecord == true;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth > 768;
        final cards = <Widget>[
          _buildInfoCard(
            AppLocalizations.of(context)!.type,
            quiz.type.toUpperCase(),
            isRecordingQuiz ? Icons.mic : Icons.quiz,
            isRecordingQuiz ? Colors.green : AppTheme.primaryColor,
            isRecordingQuiz,
          ),
          _buildInfoCard(
            AppLocalizations.of(context)!.grade,
            '${quiz.grade} ${AppLocalizations.of(context)!.points}',
            Icons.grade,
            Colors.orange,
            isRecordingQuiz,
          ),
          _buildInfoCard(
            AppLocalizations.of(context)!.attempts,
            '${quiz.numberOfAttempts}',
            Icons.repeat,
            isRecordingQuiz ? Colors.green : Colors.blue,
            isRecordingQuiz,
          ),
          // Show subcategory if available
          if (quiz.subCategory != null)
            _buildInfoCard(
              'Subcategory',
              quiz.subCategory!.name ?? 'Unnamed',
              Icons.category,
              Colors.purple,
              isRecordingQuiz,
            ),
          // Only show time limit if it's not null (not a recording quiz)
          if (quiz.timeLimit != null)
            _buildInfoCard(
              AppLocalizations.of(context)!.timeLimit,
              '${quiz.timeLimit} ${AppLocalizations.of(context)!.min}',
              Icons.timer,
              Colors.blue,
              isRecordingQuiz,
            ),
          // Show special info for recording quizzes
          if (isRecordingQuiz)
            _buildInfoCard(
              AppLocalizations.of(context)!.format,
              AppLocalizations.of(context)!.audioRecording,
              Icons.audiotrack,
              Colors.green,
              isRecordingQuiz,
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

  Widget _buildInfoCard(String title, String value, IconData icon, Color color, [bool isRecordingQuiz = false]) {
    return Card(
      margin: const EdgeInsets.all(8),
      color: isRecordingQuiz ? Colors.green.shade50 : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isRecordingQuiz ? Colors.green.shade200 : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppTheme.headingMedium.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionsList(QuizDetails quiz) {
    final bool isRecordingQuiz = quiz.isRecord == true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              isRecordingQuiz ? Icons.mic : Icons.quiz,
              color: isRecordingQuiz ? Colors.green : AppTheme.primaryColor,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              isRecordingQuiz ? AppLocalizations.of(context)!.recordingQuestions : AppLocalizations.of(context)!.questions,
              style: AppTheme.headingMedium,
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: quiz.content.length,
          itemBuilder: (context, index) {
            final question = quiz.content[index];
            final bool isRecordQuestion = question.type == QuestionType.record;

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              color: isRecordQuestion ? Colors.green.shade50 : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isRecordQuestion ? Colors.green.shade200 : Colors.grey.shade200,
                  width: 1,
                ),
              ),
              child: ExpansionTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isRecordQuestion
                        ? Colors.green.withOpacity(0.1)
                        : AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isRecordQuestion ? Icons.mic : Icons.quiz,
                    color: isRecordQuestion ? Colors.green : AppTheme.primaryColor,
                    size: 20,
                  ),
                ),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Question ${index + 1}',
                        style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (isRecordQuestion)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.audio,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                subtitle: Text(
                  'Type: ${question.type.toString().split('.').last.toUpperCase()} - ${question.grade.toInt()} points',
                  style: AppTheme.bodyMedium.copyWith(
                    color: isRecordQuestion ? Colors.green.shade700 : AppTheme.textSecondaryColor,
                  ),
                ),
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isRecordQuestion ? Colors.white : Colors.grey.shade50,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isRecordQuestion ? Colors.green.shade50 : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isRecordQuestion ? Colors.green.shade200 : Colors.grey.shade300,
                            ),
                          ),
                          child: CopticText(
                            question.question,
                            style: AppTheme.bodyLarge,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (question.type == QuestionType.mcq) ...[
                          Text(
                            AppLocalizations.of(context)!.answerOptions,
                            style: AppTheme.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textSecondaryColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...question.answers!.map((answer) => Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: answer.id == question.correctAnswerId
                                      ? Colors.green.shade50
                                      : Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: answer.id == question.correctAnswerId
                                        ? Colors.green
                                        : Colors.grey.shade300,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      answer.id == question.correctAnswerId
                                          ? Icons.check_circle
                                          : Icons.radio_button_unchecked,
                                      color: answer.id == question.correctAnswerId
                                          ? Colors.green
                                          : Colors.grey,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: CopticText(
                                        answer.text,
                                        style: AppTheme.bodyMedium.copyWith(
                                          fontWeight: answer.id == question.correctAnswerId
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                    if (answer.id == question.correctAnswerId)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          AppLocalizations.of(context)!.correct,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              )),
                        ] else if (question.type == QuestionType.text &&
                            question.correctAnswer != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green.shade200),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle, color: Colors.green, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  '${AppLocalizations.of(context)!.correctAnswer}: ',
                                  style: AppTheme.bodyMedium.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                                Expanded(
                                  child: CopticText(
                                    question.correctAnswer!,
                                    style: AppTheme.bodyMedium.copyWith(
                                      color: Colors.green.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ] else if (question.type == QuestionType.record) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green.shade300),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.audiotrack, color: Colors.green, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      AppLocalizations.of(context)!.audioRecordingQuestion,
                                      style: AppTheme.bodyMedium.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                                if (question.maxDuration != null) ...[
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.timer, color: Colors.green, size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${AppLocalizations.of(context)!.maxDuration}: ${question.maxDuration} ${AppLocalizations.of(context)!.seconds}',
                                        style: AppTheme.bodyMedium.copyWith(
                                          color: Colors.green.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ] else ...[
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.all_inclusive, color: Colors.green, size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        AppLocalizations.of(context)!.noTimeLimitForRecording,
                                        style: AppTheme.bodyMedium.copyWith(
                                          color: Colors.green.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
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
          title: AppLocalizations.of(context)!.selectStudentForRedo,
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
          title: Text(AppLocalizations.of(context)!.selectSemester),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${AppLocalizations.of(context)!.selectSemester}:'),
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
              child: Text(AppLocalizations.of(context)!.cancel),
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
                  Text(AppLocalizations.of(context)!.addingRedo.replaceAll('{studentName}', student.name)),
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



