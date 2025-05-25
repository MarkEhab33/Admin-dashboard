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
  final int? semesterId;
  const QuizAnswersListScreen({
    Key? key,
    required this.quizId,
    required this.quizName,
    this.semesterId
  }) : super(key: key);

  @override
  _QuizAnswersListScreenState createState() => _QuizAnswersListScreenState();
}

class _QuizAnswersListScreenState extends State<QuizAnswersListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Map<int, TextEditingController> _gradeControllers = {};

  // Filter parameters
  int? _selectedLessonId;
  int? _selectedSubjectId;
  int? _selectedWeekId;
  String _gradingFilter = 'all'; // 'all', 'graded', 'not_graded'

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Schedule the data loading after the build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadQuizAnswers();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    // Dispose all controllers
    _gradeControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  void _loadQuizAnswers() {
    print('semester ${widget.semesterId}');
    Provider.of<QuizAnswerProvider>(context, listen: false)
        .fetchQuizAnswersSummary(
          quizId: widget.quizId,
          semesterId: widget.semesterId,
          lessonId: _selectedLessonId,
          subjectId: _selectedSubjectId,
          weekId: _selectedWeekId,
        );
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
            _buildSummaryStats(),
            const SizedBox(height: 16),
            _buildFilterOptions(),
            const SizedBox(height: 16),
            _buildQuizAnswersList()
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryStats() {
    return Consumer<QuizAnswerProvider>(
      builder: (context, provider, _) {
        final summary = provider.quizAnswersSummary;
        if (summary == null || summary.data.isEmpty) {
          return const SizedBox.shrink();
        }

        final totalSubmissions = summary.data.length;
        final gradedSubmissions = summary.data.where((item) => item.grade != null).length;
        final autoGradedSubmissions = summary.data.where((item) => item.autoGraded).length;
        final averageGrade = summary.data
            .where((item) => item.grade != null)
            .map((item) => item.grade!)
            .fold(0, (sum, grade) => sum + grade) /
            (gradedSubmissions > 0 ? gradedSubmissions : 1);

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Submissions',
                    totalSubmissions.toString(),
                    Icons.assignment,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Graded',
                    '$gradedSubmissions / $totalSubmissions',
                    Icons.grade,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Auto Graded',
                    autoGradedSubmissions.toString(),
                    Icons.auto_awesome,
                    Colors.purple,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Average Grade',
                    gradedSubmissions > 0 ? averageGrade.toStringAsFixed(1) : 'N/A',
                    Icons.trending_up,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTheme.headingMedium.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondaryColor,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }


  Widget _buildQuizAnswersList() {
    return Consumer<QuizAnswerProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Expanded(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (provider.error.isNotEmpty) {
          return Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Error loading quiz submissions',
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.error,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadQuizAnswers,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        final quizAnswersSummary = provider.quizAnswersSummary;
        if (quizAnswersSummary == null || quizAnswersSummary.data.isEmpty) {
          return Expanded(
            child: Center(
              child: Text('No submissions found for this quiz', style: AppTheme.bodyLarge),
            ),
          );
        }

        // Apply filtering based on grading status
        var filteredAnswers = quizAnswersSummary.data;
        if (_gradingFilter == 'graded') {
          filteredAnswers = filteredAnswers.where((answer) => answer.grade != null).toList();
        } else if (_gradingFilter == 'not_graded') {
          filteredAnswers = filteredAnswers.where((answer) => answer.grade == null).toList();
        }

        if (filteredAnswers.isEmpty) {
          return Expanded(
            child: Center(
              child: Text(
                'No ${_gradingFilter == "graded" ? "graded" : "ungraded"} submissions found',
                style: AppTheme.bodyLarge
              ),
            ),
          );
        }

        return Expanded(
          child: _buildQuizAnswersListView(filteredAnswers),
        );
      },
    );
  }



  Widget _buildQuizAnswersListView(List<QuizAnswerSummaryItem> answers) {
    return Column(
      children: [
        _buildTableHeader(),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.separated(
            itemCount: answers.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) => _buildQuizAnswerListItem(answers[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withAlpha(25),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.primaryColor.withAlpha(50)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              'Student',
              style: AppTheme.headingMedium.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Quiz',
              style: AppTheme.headingMedium.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Time Taken',
              style: AppTheme.headingMedium.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Grade',
              style: AppTheme.headingMedium.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Status',
              style: AppTheme.headingMedium.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Submitted',
              style: AppTheme.headingMedium.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizAnswerListItem(QuizAnswerSummaryItem answer) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 2),
      elevation: 1,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuizGradingScreen(
                quizAnswerId: answer.id,
                quizId: widget.quizId,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Student Info (flex: 3)
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      answer.studentName,
                      style: AppTheme.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Code: ${answer.studentCode}',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textSecondaryColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              // Quiz Name (flex: 2)
              Expanded(
                flex: 2,
                child: Text(
                  answer.quizName,
                  style: AppTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Time Taken (flex: 2)
              Expanded(
                flex: 2,
                child: Container(
                  alignment: Alignment.center,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withAlpha(25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      answer.formattedTimeTaken,
                      style: AppTheme.bodyMedium.copyWith(
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),

              // Grade (flex: 2)
              Expanded(
                flex: 2,
                child: Container(
                  alignment: Alignment.center,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: answer.grade != null
                          ? Colors.green.withAlpha(25)
                          : Colors.red.withAlpha(25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      answer.grade != null
                          ? '${answer.grade}/${answer.finalGrade}'
                          : 'Not Graded',
                      style: AppTheme.bodyMedium.copyWith(
                        color: answer.grade != null ? Colors.green[700] : Colors.red[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),

              // Status (flex: 2)
              Expanded(
                flex: 2,
                child: Container(
                  alignment: Alignment.center,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: answer.autoGraded
                          ? Colors.purple.withAlpha(25)
                          : Colors.orange.withAlpha(25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      answer.autoGraded ? 'Auto' : 'Manual',
                      style: AppTheme.bodyMedium.copyWith(
                        color: answer.autoGraded ? Colors.purple[700] : Colors.orange[700],
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),

              // Submitted Date (flex: 2)
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat('MMM d').format(answer.createdAt),
                      style: AppTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      DateFormat('HH:mm').format(answer.createdAt),
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textSecondaryColor,
                        fontSize: 11,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterOptions() {
    return Row(
      children: [
        Text('Filter: ', style: AppTheme.bodyLarge),
        const SizedBox(width: 8),
        _buildFilterChip('All', 'all'),
        const SizedBox(width: 8),
        _buildFilterChip('Graded', 'graded'),
        const SizedBox(width: 8),
        _buildFilterChip('Not Graded', 'not_graded'),
      ],
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _gradingFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppTheme.primaryColor.withOpacity(0.2),
      checkmarkColor: AppTheme.primaryColor,
      backgroundColor: Colors.grey.withOpacity(0.1),
      onSelected: (selected) {
        setState(() {
          _gradingFilter = value;
        });
      },
    );
  }
}





