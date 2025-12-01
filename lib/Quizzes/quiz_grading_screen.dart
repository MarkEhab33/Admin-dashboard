import 'package:admin_dashboard/Models/quiz_answer.dart';
import 'package:admin_dashboard/Models/quiz.dart';
import 'package:admin_dashboard/Theme.dart';
import 'package:admin_dashboard/provider/quiz_answer_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import '../Models/question.dart';
import '../Models/quiz_answer_details.dart';
import '../widgets/coptic_text_field.dart';
import '../l10n/app_localizations.dart';

class QuizGradingScreen extends StatefulWidget {
  final int quizAnswerId;
  final int quizId;

  const QuizGradingScreen({Key? key, required this.quizAnswerId,required this.quizId}) : super(key: key);

  @override
  _QuizGradingScreenState createState() => _QuizGradingScreenState();
}

class _QuizGradingScreenState extends State<QuizGradingScreen> {
  final TextEditingController _gradeController = TextEditingController();
  final TextEditingController _manualGradeController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  // Map to store individual question grades
  final Map<int, TextEditingController> _questionGradeControllers = {};
  int? _maxGrade;
  bool _isSubmitting = false;
  bool _isManualGradeMode = false;
  bool _isCommentEditing = false;
  bool _isSavingComment = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        print('=== Quiz Grading Screen Debug ===');
        print('Quiz Answer ID: ${widget.quizAnswerId}');
        print('Quiz ID: ${widget.quizId}');
        Provider.of<QuizAnswerProvider>(context, listen: false)
            .fetchQuizAnswerDetails(widget.quizAnswerId);
      }
    });
  }

  @override
  void dispose() {
    _gradeController.dispose();
    _manualGradeController.dispose();
    _commentController.dispose();
    _questionGradeControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz Submission'),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        actions: [
          Consumer<QuizAnswerProvider>(
            builder: (context, provider, _) {
              final quizAnswer = provider.currentQuizAnswer;
              if (quizAnswer != null) {
                return IconButton(
                  icon: Icon(Icons.delete_outline),
                  onPressed: () => _showDeleteConfirmationDialog(quizAnswer),
                  tooltip: AppLocalizations.of(context)!.deleteQuizAnswer,
                );
              }
              return SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<QuizAnswerProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (provider.error.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60, color: Colors.red.shade300),
                  SizedBox(height: 16),
                  Text(
                    'Failed to load submission',
                    style: AppTheme.headingMedium.copyWith(color: Colors.red.shade700),
                  ),
                  SizedBox(height: 8),
                  Text(provider.error, style: AppTheme.bodyMedium),
                  SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      provider.fetchQuizAnswerDetails(widget.quizAnswerId);
                    },
                    icon: Icon(Icons.refresh),
                    label: Text('Try Again'),
                  ),
                ],
              ),
            );
          }

          final quizAnswer = provider.currentQuizAnswer;
          if (quizAnswer == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 60, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Submission not found', style: AppTheme.headingMedium),
                ],
              ),
            );
          }

          // Pre-fill with existing grade if available
          if (quizAnswer.grade != null && _gradeController.text.isEmpty) {
            _gradeController.text = quizAnswer.grade.toString();
          }

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _buildStudentHeader(quizAnswer),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _buildQuizInfoCards(quizAnswer),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildGradingSection(quizAnswer, provider),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Student Answers',
                    style: AppTheme.headingMedium,
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: _buildAnswerCard(quizAnswer.answers[index], index),
                    );
                  },
                  childCount: quizAnswer.answers.length,
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(height: 24),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStudentHeader(QuizAnswerDetails quizAnswer) {
    return Container(
      padding: EdgeInsets.only(top: 16, bottom: 24, left: 16, right: 16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white,
                radius: 30,
                child: Text(
                  quizAnswer.studentName.isNotEmpty ? quizAnswer.studentName[0].toUpperCase() : '?',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quizAnswer.studentName,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'ID: ${quizAnswer.studentCode}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      quizAnswer.studentEmail,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quizAnswer.quizName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${quizAnswer.subjectName} • Week ${quizAnswer.weekNumber}',
                      style: TextStyle(
                        color: AppTheme.textSecondaryColor,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: quizAnswer.grade != null ? Colors.green.shade50 : Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: quizAnswer.grade != null ? Colors.green.shade300 : Colors.orange.shade300,
                    ),
                  ),
                  child: Text(
                    quizAnswer.grade != null ? 'Graded' : 'Pending',
                    style: TextStyle(
                      color: quizAnswer.grade != null ? Colors.green.shade700 : Colors.orange.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizInfoCards(QuizAnswerDetails quizAnswer) {
    print('=== Quiz Info Cards Debug ===');
    print('Time taken: ${quizAnswer.timeTaken}');
    print('Time limit: ${quizAnswer.timeLimit}');
    print('Final grade: ${quizAnswer.finalGrade}');

    // Format time taken in minutes and seconds
    // Handle null or negative time values for recording quizzes
    final timeTaken = quizAnswer.timeTaken;
    final minutes = timeTaken ~/ 60;
    final seconds = timeTaken % 60;
    final formattedTimeTaken = timeTaken > 0 ? '$minutes min ${seconds} sec' : 'No time limit';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 24),
        Text('Quiz Information', style: AppTheme.headingMedium),
        SizedBox(height: 16),
        Container(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildInfoCard('Time Taken', formattedTimeTaken, Icons.timer, Colors.blue),
              _buildInfoCard('Time Limit', quizAnswer.timeLimit != null ? '${quizAnswer.timeLimit! ~/ 60} min' : 'No limit', Icons.schedule, Colors.orange),
              _buildInfoCard('Attempt', '${quizAnswer.attemptNumber}/${quizAnswer.maxAttempts}', Icons.repeat, Colors.purple),
              _buildInfoCard('Max Grade', '${quizAnswer.finalGrade} points', Icons.grade, Colors.amber),
              _buildInfoCard('Submitted', _formatDate(quizAnswer.submissionDate), Icons.calendar_today, Colors.teal),
              _buildInfoCard('Type', quizAnswer.quizType, Icons.category, Colors.indigo),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildInfoCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: 150,
      margin: EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: AppTheme.textSecondaryColor,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradingSection(QuizAnswerDetails quizAnswer, QuizAnswerProvider provider) {
    // Initialize manual grade controller with current grade if available
    if (quizAnswer.grade != null && _manualGradeController.text.isEmpty) {
      _manualGradeController.text = quizAnswer.grade.toString();
    }

    return Column(
      children: [
        // Quick Direct Grade Card - Always visible and prominent
        _buildQuickGradeCard(quizAnswer, provider),
        SizedBox(height: 16),

        // Comment Section Card
        _buildCommentCard(quizAnswer, provider),
        SizedBox(height: 16),

        // Detailed Grading Card (from individual answers)
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.calculate, color: AppTheme.primaryColor, size: 24),
                    SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context)!.calculateFromAnswers,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.calculateFromAnswersDescription,
                  style: TextStyle(
                    color: AppTheme.textSecondaryColor,
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: TextFormField(
                          controller: _gradeController,
                          decoration: InputDecoration(
                            labelText: 'Total Grade',
                            hintText: 'Out of ${quizAnswer.finalGrade}',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            labelStyle: TextStyle(color: AppTheme.primaryColor),
                          ),
                          keyboardType: TextInputType.number,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          readOnly: true,
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _isSubmitting
                          ? null
                          : () => _submitGrades(quizAnswer, provider),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isSubmitting
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'Submit',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _calculateTotalGrade(quizAnswer),
                  icon: Icon(Icons.calculate),
                  label: Text('Calculate Total Grade'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                    foregroundColor: AppTheme.textPrimaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Quick Grade Card - Direct grade entry without calculating from answers
  Widget _buildQuickGradeCard(QuizAnswerDetails quizAnswer, QuizAnswerProvider provider) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: Colors.green.shade50,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.green.shade50, Colors.green.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.green.shade600,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.edit_note, color: Colors.white, size: 28),
                  ),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.quickGrade,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                        ),
                      ),
                      Text(
                        AppLocalizations.of(context)!.quickGradeDescription,
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Current grade display
              if (quizAnswer.grade != null)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  margin: EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.green.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green.shade600, size: 20),
                      SizedBox(width: 8),
                      Text(
                        '${AppLocalizations.of(context)!.currentGrade}: ',
                        style: TextStyle(color: Colors.green.shade700),
                      ),
                      Text(
                        '${quizAnswer.grade} / ${quizAnswer.finalGrade}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                          fontSize: 16,
                        ),
                      ),
                      Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: quizAnswer.autoGraded ? Colors.blue.shade100 : Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          quizAnswer.autoGraded
                            ? AppLocalizations.of(context)!.autoGraded
                            : AppLocalizations.of(context)!.manuallyGraded,
                          style: TextStyle(
                            fontSize: 11,
                            color: quizAnswer.autoGraded ? Colors.blue.shade700 : Colors.orange.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Grade input
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.shade400, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.1),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _manualGradeController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.enterGrade,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          labelStyle: TextStyle(color: Colors.green.shade700),
                          suffixText: '/ ${quizAnswer.finalGrade}',
                          suffixStyle: TextStyle(
                            color: Colors.green.shade600,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: ElevatedButton(
                      onPressed: _isSubmitting
                          ? null
                          : () => _submitManualGrade(quizAnswer, provider),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: _isSubmitting
                          ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.save, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  AppLocalizations.of(context)!.saveGrade,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Text(
                AppLocalizations.of(context)!.quickGradeNote,
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Comment Card - Shows and allows editing of instructor comments
  Widget _buildCommentCard(QuizAnswerDetails quizAnswer, QuizAnswerProvider provider) {
    // Initialize comment controller with current comment if available and not editing
    if (!_isCommentEditing && quizAnswer.comment != null && _commentController.text.isEmpty) {
      _commentController.text = quizAnswer.comment!;
    }

    final hasComment = quizAnswer.comment != null && quizAnswer.comment!.isNotEmpty;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.blue.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade600,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.comment, color: Colors.white, size: 20),
                      ),
                      SizedBox(width: 10),
                      Text(
                        AppLocalizations.of(context)!.instructorComment,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ],
                  ),
                  if (!_isCommentEditing)
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _isCommentEditing = true;
                          if (quizAnswer.comment != null) {
                            _commentController.text = quizAnswer.comment!;
                          }
                        });
                      },
                      icon: Icon(
                        hasComment ? Icons.edit : Icons.add,
                        size: 18,
                        color: Colors.blue.shade700,
                      ),
                      label: Text(
                        hasComment
                            ? AppLocalizations.of(context)!.editComment
                            : AppLocalizations.of(context)!.addComment,
                        style: TextStyle(color: Colors.blue.shade700),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 12),
              if (_isCommentEditing) ...[
                // Editing mode
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade300),
                  ),
                  child: TextField(
                    controller: _commentController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.commentPlaceholder,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(12),
                    ),
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isCommentEditing = false;
                          // Reset to original comment
                          _commentController.text = quizAnswer.comment ?? '';
                        });
                      },
                      child: Text(AppLocalizations.of(context)!.cancel),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _isSavingComment
                          ? null
                          : () => _saveComment(quizAnswer, provider),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: _isSavingComment
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Icon(Icons.save, size: 18),
                      label: Text(AppLocalizations.of(context)!.saveComment),
                    ),
                  ],
                ),
              ] else ...[
                // Display mode
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Text(
                    hasComment
                        ? quizAnswer.comment!
                        : AppLocalizations.of(context)!.noComment,
                    style: TextStyle(
                      color: hasComment ? Colors.grey.shade800 : Colors.grey.shade500,
                      fontStyle: hasComment ? FontStyle.normal : FontStyle.italic,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveComment(QuizAnswerDetails quizAnswer, QuizAnswerProvider provider) async {
    final comment = _commentController.text.trim();

    setState(() {
      _isSavingComment = true;
    });

    try {
      final success = await provider.updateQuizAnswerComment(quizAnswer.id, comment);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.commentSavedSuccessfully),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _isCommentEditing = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error.isNotEmpty
                ? provider.error
                : AppLocalizations.of(context)!.failedToSaveComment),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isSavingComment = false;
      });
    }
  }

  Future<void> _submitManualGrade(QuizAnswerDetails quizAnswer, QuizAnswerProvider provider) async {
    final gradeText = _manualGradeController.text.trim();

    if (gradeText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.pleaseEnterGrade),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    int? grade;
    try {
      grade = int.parse(gradeText);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.invalidGradeFormat),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (grade < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.gradeCannotBeNegative),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (grade > quizAnswer.finalGrade) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppLocalizations.of(context)!.gradeCannotExceedMax} (${quizAnswer.finalGrade})'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final success = await provider.gradeQuizAnswerManual(
        quizAnswer.id,
        grade,
        quizAnswer.finalGrade,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.gradeUpdatedSuccessfully),
              backgroundColor: Colors.green,
            ),
          );
          // Refresh the data
          await provider.fetchQuizAnswerDetails(quizAnswer.id);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.error.isNotEmpty ? provider.error : AppLocalizations.of(context)!.failedToUpdateGrade),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.errorUpdatingGrade}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _calculateTotalGrade(QuizAnswerDetails quizAnswer) {
    int totalGrade = 0;
    bool allQuestionsGraded = true;
    List<String> errors = [];

    for (int i = 0; i < quizAnswer.answers.length; i++) {
      final answer = quizAnswer.answers[i];
      final controller = _questionGradeControllers[i];
      
      if (controller == null || controller.text.isEmpty) {
        allQuestionsGraded = false;
        errors.add('Question ${i+1} is not graded');
        continue;
      }
      
      try {
        final grade = int.parse(controller.text);
        if (grade < 0) {
          errors.add('Question ${i+1}: Grade cannot be negative');
          continue;
        }
        if (grade > answer.questionGrade) {
          errors.add('Question ${i+1}: Grade exceeds maximum (${answer.questionGrade})');
          continue;
        }
        totalGrade += grade;
      } catch (e) {
        errors.add('Question ${i+1}: Invalid grade format');
      }
    }

    if (errors.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Please fix the following issues:'),
              ...errors.map((e) => Text('• $e')).toList(),
            ],
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _gradeController.text = totalGrade.toString();
    });

    if (!allQuestionsGraded) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Some questions are not graded. Please grade all questions.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _submitGrades(QuizAnswerDetails quizAnswer, QuizAnswerProvider provider) async {
    _calculateTotalGrade(quizAnswer);
    
    if (_gradeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please calculate the total grade first')),
      );
      return;
    }

    final totalGrade = int.parse(_gradeController.text);
    
    // Prepare question grades for submission
    List<Map<String, dynamic>> questionGrades = [];
    for (int i = 0; i < quizAnswer.answers.length; i++) {
      final controller = _questionGradeControllers[i];
      if (controller == null || controller.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please grade all questions')),
        );
        return;
      }
      
      questionGrades.add({
        'questionIndex': i,
        'grade': int.parse(controller.text),
      });
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await provider.gradeQuizAnswerWithQuestions(
        quizAnswer.id, 
        totalGrade,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Quiz graded successfully'),
            backgroundColor: Colors.green,
          ),
        );

      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error grading quiz: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildAnswerCard(QuizAnswerItem answer, int index) {
    print('=== Building Answer Card Debug ===');
    print('Index: $index');
    print('Answer type: ${answer.type}');
    print('Question: ${answer.question}');
    print('Question grade: ${answer.questionGrade}');
    print('User answer: ${answer.userAnswer}');
    print('Is correct: ${answer.isCorrect}');

    final bool isMCQ = answer.type.toLowerCase() == 'mcq';
    final bool isRecord = answer.type.toLowerCase() == 'record';

    print('Is MCQ: $isMCQ');
    print('Is Record: $isRecord');

    // Handle different question types
    Color cardColor;
    Color borderColor;
    IconData statusIcon;
    Color iconColor;

    if (isMCQ) {
      cardColor = answer.isCorrect == true ? Colors.green.shade50 : Colors.red.shade50;
      borderColor = answer.isCorrect == true ? Colors.green.shade200 : Colors.red.shade200;
      statusIcon = answer.isCorrect == true ? Icons.check_circle : Icons.cancel;
      iconColor = answer.isCorrect == true ? Colors.green : Colors.red;
    } else if (isRecord) {
      cardColor = Colors.purple.shade50;
      borderColor = Colors.purple.shade200;
      statusIcon = Icons.mic;
      iconColor = Colors.purple;
    } else {
      // Text questions
      cardColor = Colors.blue.shade50;
      borderColor = Colors.blue.shade200;
      statusIcon = Icons.text_fields;
      iconColor = Colors.blue;
    }
    
    // Create a controller for this question if it doesn't exist
    if (!_questionGradeControllers.containsKey(index)) {
      print('Creating controller for question $index');
      // For MCQ, pre-fill with max grade if correct, 0 if incorrect
      if (isMCQ) {
        final gradeValue = answer.isCorrect == true ? answer.questionGrade : 0;
        _questionGradeControllers[index] = TextEditingController(
          text: gradeValue.toString()
        );
        print('MCQ controller created with grade: $gradeValue');
      } else if (isRecord) {
        // For recording questions, start with empty grade (manual grading required)
        _questionGradeControllers[index] = TextEditingController();
        print('Record controller created (empty)');
      } else {
        // For text questions
        _questionGradeControllers[index] = TextEditingController();
        print('Text controller created (empty)');
      }
    } else if (isMCQ) {
      // Ensure MCQ grades are always set correctly even if controller exists
      final gradeValue = answer.isCorrect == true ? answer.questionGrade : 0;
      if (_questionGradeControllers[index]!.text != gradeValue.toString()) {
        _questionGradeControllers[index]!.text = gradeValue.toString();
        print('MCQ controller updated with grade: $gradeValue');
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: cardColor,
          child: Icon(statusIcon, color: iconColor, size: 20),
        ),
        title: Text(
          'Question ${index + 1}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimaryColor,
          ),
        ),
        subtitle: Text(
          '${answer.type.toUpperCase()} • ${answer.questionGrade} points${isRecord ? ' • Manual Grading Required' : ''}',
          style: TextStyle(
            color: AppTheme.textSecondaryColor,
            fontSize: 12,
          ),
        ),
        trailing: Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          child: Text(
            isMCQ
                ? (answer.isCorrect == true ? 'Correct' : 'Incorrect')
                : isRecord
                    ? 'Recording'
                    : 'Text Answer',
            style: TextStyle(
              color: iconColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Question:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
                SizedBox(height: 8),
                CopticText(
                  answer.question,
                  style: TextStyle(
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Student Answer:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
                SizedBox(height: 8),
                isRecord
                    ? _buildAudioPlayer(answer.userAnswer)
                    : CopticText(
                        answer.userAnswer,
                        style: TextStyle(
                          color: AppTheme.textPrimaryColor,
                        ),
                      ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _questionGradeControllers[index],
                        decoration: InputDecoration(
                          labelText: 'Grade (max: ${answer.questionGrade})',
                          border: OutlineInputBorder(),
                          filled: isMCQ,
                          fillColor: isMCQ ? Colors.grey.shade100 : null,
                        ),
                        keyboardType: TextInputType.number,
                        enabled: !isMCQ, // Disable editing for MCQ questions only
                        readOnly: isMCQ, // Make MCQ fields read-only
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          try {
                            final grade = int.parse(value);
                            if (grade < 0) return 'Must be positive';
                            if (grade > answer.questionGrade) return 'Exceeds max grade';
                          } catch (e) {
                            return 'Invalid number';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                if (isMCQ) ...[
                  SizedBox(height: 8),
                  Text(
                    'MCQ questions are graded automatically',
                    style: TextStyle(
                      color: AppTheme.textSecondaryColor,
                      fontStyle: FontStyle.italic,
                      fontSize: 12,
                    ),
                  ),
                ] else if (isRecord) ...[
                  SizedBox(height: 8),
                  Text(
                    'Recording questions require manual grading. Listen to the audio and assign appropriate grade.',
                    style: TextStyle(
                      color: Colors.purple.shade600,
                      fontStyle: FontStyle.italic,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioPlayer(String audioUrl) {
    print('Building audio player for URL: $audioUrl');

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.audiotrack, color: Colors.purple, size: 20),
              SizedBox(width: 8),
              Text(
                'Audio Recording',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.purple.shade700,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          // Audio player using iframe
          Container(
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _buildIframeAudioPlayer(audioUrl),
            ),
          ),
          SizedBox(height: 8),
          // Filename and controls
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Icon(Icons.audiotrack, size: 16, color: Colors.grey.shade600),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    audioUrl.split('/').last, // Show filename
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Play in new tab button
                TextButton.icon(
                  onPressed: () {
                    html.window.open(audioUrl, '_blank');
                  },
                  icon: Icon(Icons.open_in_new, size: 16),
                  label: Text('Open'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.purple.shade600,
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIframeAudioPlayer(String audioUrl) {
    // Create HTML for audio player
    final audioHtml = '''
      <!DOCTYPE html>
      <html>
      <head>
        <style>
          body {
            margin: 0;
            padding: 8px;
            font-family: Arial, sans-serif;
            background: white;
          }
          audio {
            width: 100%;
            height: 40px;
            outline: none;
          }
        </style>
      </head>
      <body>
        <audio controls preload="metadata">
          <source src="$audioUrl" type="audio/mpeg">
          <source src="$audioUrl" type="audio/wav">
          <source src="$audioUrl" type="audio/ogg">
          Your browser does not support the audio element.
        </audio>
      </body>
      </html>
    ''';

    // Create data URL
    final dataUrl = 'data:text/html;charset=utf-8,${Uri.encodeComponent(audioHtml)}';

    // Create iframe element
    final iframe = html.IFrameElement()
      ..src = dataUrl
      ..style.width = '100%'
      ..style.height = '60px'
      ..style.border = 'none'
      ..style.borderRadius = '8px';

    // Create unique view type
    final viewType = 'audio-iframe-${audioUrl.hashCode}';

    // Register view factory
    ui_web.platformViewRegistry.registerViewFactory(
      viewType,
      (int viewId) => iframe,
    );

    return HtmlElementView(viewType: viewType);
  }

  void _showDeleteConfirmationDialog(QuizAnswerDetails quizAnswer) {
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
                      'Student: ${quizAnswer.studentName}',
                      style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Code: ${quizAnswer.studentCode}',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textSecondaryColor,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Quiz: ${quizAnswer.quizName}',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textSecondaryColor,
                        fontSize: 12,
                      ),
                    ),
                    if (quizAnswer.grade != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Grade: ${quizAnswer.grade}/${quizAnswer.finalGrade}',
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
              onPressed: () => _deleteQuizAnswer(quizAnswer),
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

  Future<void> _deleteQuizAnswer(QuizAnswerDetails quizAnswer) async {
    try {
      // Store context references before async operations
      final navigator = Navigator.of(context);
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      final successMessage = AppLocalizations.of(context)!.quizAnswerDeletedSuccessfully;

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
          .deleteQuizAnswer(quizAnswer.id);

      // Close loading dialog and navigate back
      if (mounted) {
        navigator.pop(); // Close loading dialog

        // Navigate back to quiz answers list or previous screen
        if (context.canPop()) {
          context.pop();
        } else {
          // Fallback navigation
          context.go('/quizzes');
        }

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
}
