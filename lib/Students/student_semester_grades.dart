import 'package:admin_dashboard/Models/quiz_grade.dart';
import 'package:flutter/material.dart';
import '../Models/student.dart';
import '../Models/semester.dart';
import '../Models/subject_grades.dart';
import '../Theme.dart';
import 'package:provider/provider.dart';
import '../provider/grades_provider.dart';
import 'package:intl/intl.dart';

import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter_animate/flutter_animate.dart';

class StudentSemesterGrades extends StatefulWidget {
  final Student student;
  final Semester semester;

  const StudentSemesterGrades({
    Key? key,
    required this.student,
    required this.semester,
  }) : super(key: key);

  @override
  _StudentSemesterGradesState createState() => _StudentSemesterGradesState();
}

class _StudentSemesterGradesState extends State<StudentSemesterGrades> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadStudentGrades();
      }
    });
  }

  @override
  void dispose() {
    // Clear grades when leaving the screen
    Provider.of<GradesProvider>(context, listen: false).clearGrades();
    super.dispose();
  }

  Future<void> _loadStudentGrades() async {
    final gradesProvider = Provider.of<GradesProvider>(context, listen: false);
    await gradesProvider.fetchStudentSemesterGrades(
      widget.semester.id,
      widget.student.id,
    );
  }

  // Calculate overall semester statistics with weighted grading
  Map<String, dynamic> _calculateSemesterStats(List<SubjectGrades> subjects) {
    double totalWeightedScore = 0.0;
    int completedSubjects = 0;
    int totalSubjects = subjects.length;
    int passedSubjects = 0;

    for (var subject in subjects) {
      final subjectStats = _calculateSubjectStats(subject);
      if (subjectStats['hasGrades']) {
        totalWeightedScore += subjectStats['weightedPercentage'];
        completedSubjects++;
        if (subjectStats['weightedPercentage'] >= 60.0) {
          passedSubjects++;
        }
      }
    }

    final averagePercentage = completedSubjects > 0 ? (totalWeightedScore / completedSubjects) : 0.0;
    final completionRate = totalSubjects > 0 ? (completedSubjects / totalSubjects * 100) : 0.0;
    final passRate = completedSubjects > 0 ? (passedSubjects / completedSubjects * 100) : 0.0;

    return {
      'averagePercentage': averagePercentage,
      'completedSubjects': completedSubjects,
      'totalSubjects': totalSubjects,
      'passedSubjects': passedSubjects,
      'completionRate': completionRate,
      'passRate': passRate,
    };
  }

  // Calculate subject total grades with weighted system (40% weekly, 60% final)
  Map<String, dynamic> _calculateSubjectStats(SubjectGrades subject) {
    // Separate weekly and final quizzes
    final weeklyQuizzes = subject.quizzes.where((quiz) =>
        quiz.name.toLowerCase() == 'week quizzes').toList();
    final finalQuizzes = subject.quizzes.where((quiz) =>
        quiz.name.toLowerCase() != 'week quizzes').toList();

    // Calculate weekly quiz stats
    int weeklyUserGrade = 0;
    int weeklyMaxGrade = 0;
    bool hasWeeklyGrades = false;

    for (var quiz in weeklyQuizzes) {
      weeklyMaxGrade += quiz.finalGrade;
      if (quiz.userGrade != null) {
        weeklyUserGrade += quiz.userGrade!;
        hasWeeklyGrades = true;
      }
    }

    // Calculate final quiz stats
    int finalUserGrade = 0;
    int finalMaxGrade = 0;
    bool hasFinalGrades = false;

    for (var quiz in finalQuizzes) {
      finalMaxGrade += quiz.finalGrade;
      if (quiz.userGrade != null) {
        finalUserGrade += quiz.userGrade!;
        hasFinalGrades = true;
      }
    }

    // Calculate percentages
    final weeklyPercentage = hasWeeklyGrades && weeklyMaxGrade > 0
        ? (weeklyUserGrade / weeklyMaxGrade * 100)
        : 0.0;

    final finalPercentage = hasFinalGrades && finalMaxGrade > 0
        ? (finalUserGrade / finalMaxGrade * 100)
        : 0.0;

    // Calculate weighted percentage (40% weekly + 60% final)
    double weightedPercentage = 0.0;
    bool hasGrades = hasWeeklyGrades || hasFinalGrades;

    if (hasWeeklyGrades && hasFinalGrades) {
      // Both types available - use full weighted calculation
      weightedPercentage = (weeklyPercentage * 0.4) + (finalPercentage * 0.6);
    } else if (hasWeeklyGrades && !hasFinalGrades) {
      // Only weekly grades available - scale to represent 40% of total
      weightedPercentage = weeklyPercentage * 0.4;
    } else if (!hasWeeklyGrades && hasFinalGrades) {
      // Only final grades available - scale to represent 60% of total
      weightedPercentage = finalPercentage * 0.6;
    }

    // Calculate traditional total for display
    final totalUserGrade = weeklyUserGrade + finalUserGrade;
    final totalMaxGrade = weeklyMaxGrade + finalMaxGrade;
    final traditionalPercentage = hasGrades && totalMaxGrade > 0
        ? (totalUserGrade / totalMaxGrade * 100)
        : 0.0;

    return {
      'totalUserGrade': totalUserGrade,
      'totalMaxGrade': totalMaxGrade,
      'traditionalPercentage': traditionalPercentage,
      'weightedPercentage': weightedPercentage,
      'weeklyPercentage': weeklyPercentage,
      'finalPercentage': finalPercentage,
      'hasGrades': hasGrades,
      'hasWeeklyGrades': hasWeeklyGrades,
      'hasFinalGrades': hasFinalGrades,
      'weeklyUserGrade': weeklyUserGrade,
      'weeklyMaxGrade': weeklyMaxGrade,
      'finalUserGrade': finalUserGrade,
      'finalMaxGrade': finalMaxGrade,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.student.user.name} - Grades'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: MouseRegion(
        cursor: SystemMouseCursors.basic,
        child: Consumer<GradesProvider>(
          builder: (context, gradesProvider, child) {
          if (gradesProvider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (gradesProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    gradesProvider.error!,
                    style: TextStyle(color: Colors.red),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadStudentGrades,
                    child: Text('Retry'),
                    style: AppTheme.primaryButtonStyle,
                  ),
                ],
              ),
            );
          }

          final grades = gradesProvider.semesterGrades;
          if (grades == null) {
            return Center(
              child: Text('No grades data available'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                SizedBox(height: 24),
                _buildSemesterSummary(grades.subjects),
                SizedBox(height: 24),
                ...grades.subjects.map((subject) => _buildSubjectCard(subject)),
              ],
            ),
          );
          },
        ),
      ),
    );
  }

  Widget _buildSemesterSummary(List<SubjectGrades> subjects) {
    final stats = _calculateSemesterStats(subjects);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withValues(alpha: 0.1),
            AppTheme.primaryColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics, color: AppTheme.primaryColor, size: 28),
              SizedBox(width: 12),
              Text(
                'Semester Overview',
                style: AppTheme.headingLarge.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Weighted Average',
                  '${stats['averagePercentage'].toStringAsFixed(1)}%',
                  Icons.analytics,
                  _getGradeColor(stats['averagePercentage']),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  'Pass Status',
                  stats['averagePercentage'] >= 60.0 ? 'PASSED' : 'FAILED',
                  stats['averagePercentage'] >= 60.0 ? Icons.check_circle : Icons.cancel,
                  stats['averagePercentage'] >= 60.0 ? Colors.green : Colors.red,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  'Subjects Passed',
                  '${stats['passedSubjects']}/${stats['completedSubjects']}',
                  Icons.school,
                  Colors.blue,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildProgressCard(
                  'Completion',
                  stats['completionRate'] / 100,
                  '${stats['completionRate'].toStringAsFixed(0)}%',
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          // Grading System Info
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Grading System',
                      style: AppTheme.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildGradingInfoCard(
                        'Weekly Quizzes',
                        '40%',
                        Colors.green,
                        Icons.quiz,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildGradingInfoCard(
                        'Final Exams',
                        '60%',
                        Colors.blue,
                        Icons.school,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildGradingInfoCard(
                        'Pass Threshold',
                        '60%',
                        Colors.orange,
                        Icons.flag,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textSecondaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: AppTheme.headingMedium.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(String title, double progress, String percentage) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up, color: AppTheme.primaryColor, size: 20),
              SizedBox(width: 8),
              Text(
                title,
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textSecondaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          CircularPercentIndicator(
            radius: 30.0,
            lineWidth: 6.0,
            percent: progress,
            center: Text(
              percentage,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: AppTheme.primaryColor,
              ),
            ),
            progressColor: AppTheme.primaryColor,
            backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
            circularStrokeCap: CircularStrokeCap.round,
          ),
        ],
      ),
    );
  }

  Widget _buildGradingInfoCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          SizedBox(height: 6),
          Text(
            title,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondaryColor,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: AppTheme.bodyMedium.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Student Grades',
            style: AppTheme.headingLarge,
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  'Student',
                  widget.student.user.name,
                  Icons.person,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildInfoCard(
                  'Student Code',
                  widget.student.studentCode,
                  Icons.badge,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildInfoCard(
                  'Semester',
                  widget.semester.name,
                  Icons.school,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildInfoCard(
                  'Period',
                  '${_formatDate(widget.semester.startDate)} - ${_formatDate(widget.semester.endDate)}',
                  Icons.calendar_today,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppTheme.primaryColor),
              SizedBox(width: 8),
              Text(
                title,
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: AppTheme.headingMedium.copyWith(
              color: AppTheme.textPrimaryColor,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectCard(SubjectGrades subject) {
    final stats = _calculateSubjectStats(subject);

    return Container(
      margin: EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
            spreadRadius: 2,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor.withValues(alpha: 0.08),
                  AppTheme.primaryColor.withValues(alpha: 0.03),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.book, color: AppTheme.primaryColor, size: 24),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            subject.name,
                            style: AppTheme.headingMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Code: ${subject.code}',
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppTheme.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildSubjectGradeCircle(subject),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildSubjectStatCard(
                        'Weighted Score',
                        '${stats['weightedPercentage'].toStringAsFixed(1)}%',
                        Icons.analytics,
                        _getGradeColor(stats['weightedPercentage']),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildSubjectStatCard(
                        'Pass Status',
                        stats['weightedPercentage'] >= 60.0 ? 'PASS' : 'FAIL',
                        stats['weightedPercentage'] >= 60.0 ? Icons.check_circle : Icons.cancel,
                        stats['weightedPercentage'] >= 60.0 ? Colors.green : Colors.red,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildScaledStatCard(
                        'Weekly (40%)',
                        stats['hasWeeklyGrades']
                          ? '${((stats['weeklyPercentage'] / 100) * 40).toStringAsFixed(1)}/40'
                          : 'N/A',
                        stats['hasWeeklyGrades'] ? '${stats['weeklyPercentage'].toStringAsFixed(1)}%' : '',
                        Icons.quiz,
                        stats['hasWeeklyGrades'] ? Colors.green : Colors.grey,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildScaledStatCard(
                        'Final (60%)',
                        stats['hasFinalGrades']
                          ? '${((stats['finalPercentage'] / 100) * 60).toStringAsFixed(1)}/60'
                          : 'N/A',
                        stats['hasFinalGrades'] ? '${stats['finalPercentage'].toStringAsFixed(1)}%' : '',
                        Icons.school,
                        stats['hasFinalGrades'] ? Colors.blue : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _buildQuizzesTable(subject.quizzes),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildSubjectStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          SizedBox(height: 6),
          Text(
            title,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondaryColor,
              fontSize: 10,
            ),
          ),
          SizedBox(height: 2),
          Text(
            value,
            style: AppTheme.bodyMedium.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScaledStatCard(String title, String scaledValue, String percentage, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          SizedBox(height: 6),
          Text(
            title,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondaryColor,
              fontSize: 10,
            ),
          ),
          SizedBox(height: 2),
          Text(
            scaledValue,
            style: AppTheme.bodyMedium.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          if (percentage.isNotEmpty) ...[
            SizedBox(height: 2),
            Text(
              percentage,
              style: AppTheme.bodyMedium.copyWith(
                color: color.withValues(alpha: 0.7),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSubjectGradeCircle(SubjectGrades subject) {
    final stats = _calculateSubjectStats(subject);
    final hasGrades = stats['hasGrades'];
    final weightedPercentage = stats['weightedPercentage'];

    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(
          color: hasGrades
              ? _getGradeColor(weightedPercentage)
              : Colors.grey,
          width: 3,
        ),
      ),
      child: Center(
        child: hasGrades
            ? Text(
                '${weightedPercentage.round()}%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _getGradeColor(weightedPercentage),
                  fontSize: 16,
                ),
              )
            : Text(
                'N/A',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
      ),
    );
  }

  Widget _buildQuizzesTable(List<QuizGrade> quizzes) {
    if (quizzes.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(
              Icons.quiz_outlined,
              size: 48,
              color: AppTheme.textSecondaryColor.withValues(alpha: 0.5),
            ),
            SizedBox(height: 16),
            Text(
              'No quizzes available for this subject',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Separate final quizzes and other quizzes
    // Final quizzes are those that are NOT "Week Quizzes"
    final finalQuizzes = quizzes.where((quiz) =>
        quiz.name.toLowerCase() != 'week quizzes'
    ).toList();
    final otherQuizzes = quizzes.where((quiz) =>
        quiz.name.toLowerCase() == 'week quizzes'
    ).toList();

    return Container(
      margin: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Final Quizzes Section (grouped by subcategories)
          if (finalQuizzes.isNotEmpty) ...[
            _buildFinalQuizzesSection(finalQuizzes),
            if (otherQuizzes.isNotEmpty) SizedBox(height: 24),
          ],

          // Other Quizzes Section
          if (otherQuizzes.isNotEmpty) ...[
            _buildOtherQuizzesSection(otherQuizzes),
          ],
        ],
      ),
    );
  }

  Widget _buildFinalQuizzesSection(List<QuizGrade> finalQuizzes) {
    // Group final quizzes by subcategory
    Map<String, List<QuizGrade>> groupedQuizzes = {};

    for (var quiz in finalQuizzes) {
      String categoryKey = quiz.subCategory?.name ?? 'General Final Exams';
      if (!groupedQuizzes.containsKey(categoryKey)) {
        groupedQuizzes[categoryKey] = [];
      }
      groupedQuizzes[categoryKey]!.add(quiz);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Container(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.school,
                  color: Colors.blue,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Text(
                'Final Examinations',
                style: AppTheme.headingMedium.copyWith(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${finalQuizzes.length} exam${finalQuizzes.length != 1 ? 's' : ''}',
                  style: AppTheme.bodyMedium.copyWith(
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12),

        // Subcategory Groups
        ...groupedQuizzes.entries.map((entry) {
          final categoryName = entry.key;
          final categoryQuizzes = entry.value;

          return Container(
            margin: EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
              color: Colors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Subcategory Header
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.category,
                          color: Colors.blue,
                          size: 16,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          categoryName,
                          style: AppTheme.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                      _buildCategoryStats(categoryQuizzes),
                    ],
                  ),
                ),

                // Quiz Table Header
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    border: Border(
                      bottom: BorderSide(color: Colors.blue.withValues(alpha: 0.1)),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          'Exam Name',
                          style: AppTheme.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Grade',
                          textAlign: TextAlign.center,
                          style: AppTheme.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Performance',
                          textAlign: TextAlign.center,
                          style: AppTheme.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Quiz Rows
                ...categoryQuizzes.asMap().entries.map((entry) {
                  final index = entry.key;
                  final quiz = entry.value;
                  return _buildEnhancedQuizRow(quiz, index, true);
                }),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildOtherQuizzesSection(List<QuizGrade> otherQuizzes) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.05),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.quiz,
                    color: Colors.green,
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  'Weekly Assessments',
                  style: AppTheme.headingMedium.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${otherQuizzes.length} quiz${otherQuizzes.length != 1 ? 'zes' : ''}',
                    style: AppTheme.bodyMedium.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Quiz Table Header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(
                bottom: BorderSide(color: Colors.green.withValues(alpha: 0.1)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Quiz Name',
                    style: AppTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Grade',
                    textAlign: TextAlign.center,
                    style: AppTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Performance',
                    textAlign: TextAlign.center,
                    style: AppTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Quiz Rows
          ...otherQuizzes.asMap().entries.map((entry) {
            final index = entry.key;
            final quiz = entry.value;
            return _buildEnhancedQuizRow(quiz, index, false);
          }),
        ],
      ),
    );
  }

  Widget _buildCategoryStats(List<QuizGrade> quizzes) {
    int totalUserGrade = 0;
    int totalMaxGrade = 0;

    for (var quiz in quizzes) {
      totalMaxGrade += quiz.finalGrade;
      if (quiz.userGrade != null) {
        totalUserGrade += quiz.userGrade!;
      }
    }

    final percentage = totalMaxGrade > 0 ? (totalUserGrade / totalMaxGrade * 100) : 0.0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$totalUserGrade/$totalMaxGrade',
            style: AppTheme.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: _getGradeColor(percentage),
            ),
          ),
          SizedBox(width: 8),
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _getGradeColor(percentage),
            ),
          ),
          SizedBox(width: 8),
          Text(
            '${percentage.toStringAsFixed(1)}%',
            style: AppTheme.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: _getGradeColor(percentage),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedQuizRow(QuizGrade quiz, int index, bool isFinalExam) {
    final bool hasGrade = quiz.userGrade != null;
    final String gradeText = hasGrade
        ? '${quiz.userGrade}/${quiz.finalGrade}'
        : '-/${quiz.finalGrade}';
    final double? percentage = hasGrade
        ? (quiz.userGrade! / quiz.finalGrade * 100)
        : null;
    final Color themeColor = isFinalExam ? Colors.blue : Colors.green;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: index % 2 == 0 ? Colors.grey.withValues(alpha: 0.02) : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: themeColor.withValues(alpha: 0.1),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // Quiz Name Column
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: themeColor,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        quiz.name,
                        style: AppTheme.bodyMedium.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (quiz.submissionDate != null)
                        Text(
                          'Submitted: ${DateFormat('MMM d, y').format(quiz.submissionDate!)}',
                          style: AppTheme.bodyMedium.copyWith(
                            fontSize: 11,
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      if (isFinalExam && quiz.subCategory != null)
                        Container(
                          margin: EdgeInsets.only(top: 4),
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.purple.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            quiz.subCategory!.name,
                            style: AppTheme.bodyMedium.copyWith(
                              fontSize: 10,
                              color: Colors.purple.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Grade Column
          Expanded(
            flex: 2,
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: hasGrade
                      ? _getGradeColor(percentage!).withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  gradeText,
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: hasGrade
                        ? _getGradeColor(percentage!)
                        : Colors.grey,
                  ),
                ),
              ),
            ),
          ),
          // Performance Column
          Expanded(
            flex: 2,
            child: Center(
              child: hasGrade
                  ? CircularPercentIndicator(
                      radius: 20.0,
                      lineWidth: 4.0,
                      percent: percentage! / 100,
                      center: Text(
                        '${percentage.round()}%',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: _getGradeColor(percentage),
                        ),
                      ),
                      progressColor: _getGradeColor(percentage),
                      backgroundColor: _getGradeColor(percentage).withValues(alpha: 0.2),
                      circularStrokeCap: CircularStrokeCap.round,
                    )
                  : Text(
                      'N/A',
                      style: AppTheme.bodyMedium.copyWith(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getGradeColor(double percentage) {
    if (percentage >= 85) return Colors.green;
    if (percentage >= 75) return Colors.lightGreen;
    if (percentage >= 60) return Colors.orange; // Pass threshold
    return Colors.red; // Fail
  }

  String _formatDate(DateTime date) {
    try {
      return DateFormat('MMM d, y').format(date);
    } catch (e) {
      return 'Invalid date';
    }
  }
}
