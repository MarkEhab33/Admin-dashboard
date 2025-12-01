import 'package:admin_dashboard/Models/quiz_answer.dart';
import 'package:admin_dashboard/Quizzes/quiz_grading_screen.dart';
import 'package:admin_dashboard/Theme.dart';
import 'package:admin_dashboard/provider/quiz_answer_provider.dart' show QuizAnswerProvider, BulkGradeResult;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../widgets/coptic_text_field.dart';
import '../l10n/app_localizations.dart';

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
  final TextEditingController _searchController = TextEditingController();

  // Filter parameters
  int? _selectedLessonId;
  int? _selectedSubjectId;
  int? _selectedWeekId;
  String _gradingFilter = 'all'; // 'all', 'graded', 'not_graded'
  String _searchQuery = '';

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
    _searchController.dispose();
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
        actions: [
          // Bulk Grade Button
          Tooltip(
            message: AppLocalizations.of(context)!.addBulkGrades,
            child: IconButton(
              icon: Icon(Icons.add_chart),
              onPressed: () => _showBulkGradeDialog(),
            ),
          ),
        ],
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
            _buildSearchBar(),
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

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
          });
        },
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context)!.searchByStudentName,
          prefixIcon: Icon(
            Icons.search,
            color: AppTheme.primaryColor,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: Colors.grey[600],
                  ),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
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

        // Apply search filtering by student name
        if (_searchQuery.isNotEmpty) {
          filteredAnswers = filteredAnswers.where((answer) {
            return answer.studentName.toLowerCase().contains(_searchQuery);
          }).toList();
        }

        if (filteredAnswers.isEmpty) {
          String emptyMessage;
          if (_searchQuery.isNotEmpty) {
            emptyMessage = 'No submissions found for "${_searchQuery}"';
          } else if (_gradingFilter == 'graded') {
            emptyMessage = 'No graded submissions found';
          } else if (_gradingFilter == 'not_graded') {
            emptyMessage = 'No ungraded submissions found';
          } else {
            emptyMessage = 'No submissions found';
          }

          return Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _searchQuery.isNotEmpty ? Icons.search_off : Icons.assignment_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    emptyMessage,
                    style: AppTheme.bodyLarge.copyWith(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  if (_searchQuery.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                      child: Text('Clear search'),
                    ),
                  ],
                ],
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
        // Search results indicator
        if (_searchQuery.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.primaryColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.search,
                  size: 16,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Showing ${answers.length} result${answers.length != 1 ? 's' : ''} for "$_searchQuery"',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Clear',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
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
          final uri = Uri(
            path: '/quiz-answer/${answer.id}',
            queryParameters: {
              'quizId': widget.quizId.toString(),
            },
          );

          context.go(uri.toString());
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
                child: CopticText(
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

              // Actions (Delete Button)
              Container(
                width: 40,
                child: IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    color: Colors.red[600],
                    size: 20,
                  ),
                  onPressed: () => _showDeleteConfirmationDialog(answer),
                  tooltip: AppLocalizations.of(context)!.deleteQuizAnswer,
                  padding: EdgeInsets.all(8),
                  constraints: BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
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

  void _showDeleteConfirmationDialog(QuizAnswerSummaryItem answer) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            AppLocalizations.of(context)!.deleteQuizAnswerTitle,
            style: AppTheme.headingMedium.copyWith(color: Colors.red[700]),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.deleteQuizAnswerConfirmation,
                style: AppTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Student: ${answer.studentName}',
                      style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Code: ${answer.studentCode}',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textSecondaryColor,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Quiz: ${answer.quizName}',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textSecondaryColor,
                        fontSize: 12,
                      ),
                    ),
                    if (answer.grade != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Grade: ${answer.grade}/${answer.finalGrade}',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.textSecondaryColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                AppLocalizations.of(context)!.actionCannotBeUndone,
                style: AppTheme.bodyMedium.copyWith(
                  color: Colors.red[600],
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                AppLocalizations.of(context)!.cancel,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: () => _deleteQuizAnswer(answer),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(AppLocalizations.of(context)!.delete),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteQuizAnswer(QuizAnswerSummaryItem answer) async {
    try {
      // Store context references before async operations
      final navigator = Navigator.of(context);
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      final successMessage = AppLocalizations.of(context)!.quizAnswerDeletedSuccessfully;
      final errorMessage = AppLocalizations.of(context)!.errorDeletingQuizAnswer;

      // Close the confirmation dialog
      navigator.pop();

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                const SizedBox(width: 16),
                Text('Deleting quiz answer...'),
              ],
            ),
          );
        },
      );

      // Delete the quiz answer
      await Provider.of<QuizAnswerProvider>(context, listen: false)
          .deleteQuizAnswer(answer.id);

      // Close loading dialog
      if (mounted) {
        navigator.pop();

        // Show success message
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(successMessage),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );

        // Refresh the list
        _loadQuizAnswers();
      }
    } catch (e) {
      if (mounted) {
        // Close loading dialog if it's still open
        Navigator.of(context).pop();

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.errorDeletingQuizAnswer}: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  void _showBulkGradeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _BulkGradeDialog(
          quizId: widget.quizId,
          quizName: widget.quizName,
          semesterId: widget.semesterId,
          onSuccess: () {
            // Refresh the list after bulk grading
            _loadQuizAnswers();
          },
        );
      },
    );
  }
}

/// Dialog for adding bulk grades to all students for a quiz
class _BulkGradeDialog extends StatefulWidget {
  final int quizId;
  final String quizName;
  final int? semesterId;
  final VoidCallback onSuccess;

  const _BulkGradeDialog({
    Key? key,
    required this.quizId,
    required this.quizName,
    this.semesterId,
    required this.onSuccess,
  }) : super(key: key);

  @override
  _BulkGradeDialogState createState() => _BulkGradeDialogState();
}

class _BulkGradeDialogState extends State<_BulkGradeDialog> {
  final TextEditingController _gradeController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _gradeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.add_chart, color: AppTheme.primaryColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.addBulkGrades,
              style: AppTheme.headingMedium.copyWith(
                color: AppTheme.primaryColor,
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info section
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)!.bulkGradeInfo,
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.bulkGradeDescription,
                    style: TextStyle(
                      color: Colors.blue.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Quiz info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${AppLocalizations.of(context)!.quiz}: ${widget.quizName}',
                    style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                  ),
                  if (widget.semesterId != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${AppLocalizations.of(context)!.semester} ID: ${widget.semesterId}',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textSecondaryColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Grade input
            Text(
              AppLocalizations.of(context)!.gradesToAdd,
              style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _gradeController,
              keyboardType: TextInputType.numberWithOptions(signed: true),
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.enterGradesToAdd,
                helperText: AppLocalizations.of(context)!.gradeRangeHelper,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: Icon(Icons.exposure, color: AppTheme.primaryColor),
                suffixText: AppLocalizations.of(context)!.points,
                errorText: _errorMessage,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.bulkGradeNote,
              style: TextStyle(
                color: Colors.orange.shade700,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              AppLocalizations.of(context)!.bulkGradeNegativeNote,
              style: TextStyle(
                color: Colors.blue.shade700,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: Text(
            AppLocalizations.of(context)!.cancel,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submitBulkGrade,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
          ),
          child: _isSubmitting
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(AppLocalizations.of(context)!.addGrades),
        ),
      ],
    );
  }

  Future<void> _submitBulkGrade() async {
    // Validate input
    final gradeText = _gradeController.text.trim();
    if (gradeText.isEmpty) {
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.pleaseEnterGrade;
      });
      return;
    }

    int? gradesToAdd;
    try {
      gradesToAdd = int.parse(gradeText);
    } catch (e) {
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.invalidGradeFormat;
      });
      return;
    }

    if (gradesToAdd == 0) {
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.gradeCannotBeZero;
      });
      return;
    }

    if (gradesToAdd < -100 || gradesToAdd > 100) {
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.gradeMustBeBetweenRange;
      });
      return;
    }

    // Check if semester ID is available
    if (widget.semesterId == null) {
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.semesterIdRequired;
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final provider = Provider.of<QuizAnswerProvider>(context, listen: false);
      final result = await provider.addBulkGrades(
        semesterId: widget.semesterId!,
        quizId: widget.quizId,
        gradesToAdd: gradesToAdd,
      );

      if (mounted) {
        Navigator.of(context).pop();

        // Show success dialog with results
        _showBulkGradeResultDialog(result);

        // Call the success callback to refresh the list
        widget.onSuccess();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  void _showBulkGradeResultDialog(BulkGradeResult result) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.bulkGradeSuccess,
                style: AppTheme.headingMedium.copyWith(color: Colors.green),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.message,
                  style: AppTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${AppLocalizations.of(context)!.studentsUpdated}: ${result.updatedCount}',
                        style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '${AppLocalizations.of(context)!.gradesAdded}: +${result.gradesToAdd}',
                        style: AppTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                if (result.updatedStudents.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.updatedStudentsList,
                    style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    constraints: BoxConstraints(maxHeight: 200),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: result.updatedStudents.length,
                      itemBuilder: (context, index) {
                        final student = result.updatedStudents[index];
                        return ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            radius: 16,
                            backgroundColor: AppTheme.primaryColor.withAlpha(50),
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                          title: Text(
                            student.studentName,
                            style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(
                            'Code: ${student.studentCode}',
                            style: TextStyle(fontSize: 11),
                          ),
                          trailing: Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${student.newGrade}',
                              style: TextStyle(
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: Text(AppLocalizations.of(context)!.ok),
            ),
          ],
        );
      },
    );
  }
}





