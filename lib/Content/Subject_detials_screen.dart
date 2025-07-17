import 'dart:html' as html;

import 'package:admin_dashboard/utils/string_extensions.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../Models/Subject_Template.dart';
import '../Models/lesson_item.dart';

import '../provider/subject_provider.dart';
import '../provider/semesters_provider.dart';
import '../provider/quiz_provider.dart' as quiz_provider;
import '../Theme.dart';
import '../l10n/app_localizations.dart';

import '../widgets/audio_player.dart';
import '../widgets/pdf_viewer.dart';
import '../widgets/video_viewer.dart';
import '../Quizzes/create_quiz_screen.dart';
import '../Quizzes/create_tasmi3_screen.dart';
import '../Quizzes/quiz_details_screen.dart';
import '../widgets/subcategories_modal.dart';
import '../provider/subcategory_provider.dart';


class SubjectDetailsScreen extends StatefulWidget {
  final Subject subject;

  const SubjectDetailsScreen({Key? key, required this.subject}) : super(key: key);

  @override
  State<SubjectDetailsScreen> createState() => _SubjectDetailsScreenState();
}

class _SubjectDetailsScreenState extends State<SubjectDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    // Fetch lessons after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LessonProvider>(context, listen: false)
          .fetchLessons(widget.subject.subjectId!);
      Provider.of<LessonProvider>(context, listen: false).setLessonNull();
    });

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          widget.subject.subjectName ?? "NA",
          style: AppTheme.headingMedium.copyWith(color: Colors.white),
        ),
        backgroundColor: AppTheme.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.category_outlined),
            onPressed: () => _showSubcategoriesModal(context),
            tooltip: AppLocalizations.of(context)!.subcategories,
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showSubjectInfo(context),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryColor.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: Row(
          children: [
            // Left side - Lessons Panel
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 320,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(2, 0),
                  ),
                ],
              ),
              child: _buildLessonsPanel(context),
            ),
            // Right side - Content Panel
            Expanded(
              child: _buildContentPanel(context),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  Widget _buildLessonsPanel(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.lessons,
                    style: AppTheme.headingLarge.copyWith(
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showAddLessonDialog(context),
                    icon: const Icon(Icons.add, size: 20),
                    label: Text(AppLocalizations.of(context)!.addLessonButton),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.manageCourseContent,
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Consumer<LessonProvider>(
            builder: (context, lessonProvider, _) {
              if (lessonProvider.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (lessonProvider.lessons.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.school_outlined,
                        size: 64,
                        color: AppTheme.primaryColor.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppLocalizations.of(context)!.noLessonsYet,
                        style: AppTheme.headingMedium.copyWith(
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppLocalizations.of(context)!.startByAddingFirstLesson,
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: lessonProvider.lessons.length,
                itemBuilder: (context, index) {
                  final lesson = lessonProvider.lessons[index];
                  return _buildLessonCard(context, lesson, lessonProvider);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLessonCard(
    BuildContext context,
    dynamic lesson,
    LessonProvider lessonProvider,
  ) {
    final isSelected = lessonProvider.selectedLesson == lesson;
    return Card(
      elevation: isSelected ? 4 : 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected
              ? AppTheme.primaryColor
              : AppTheme.primaryColor.withOpacity(0.1),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () => lessonProvider.selectLesson(lesson),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.book_outlined,
                    color: isSelected
                        ? AppTheme.primaryColor
                        : AppTheme.textSecondaryColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      lesson.name,
                      style: AppTheme.bodyLarge.copyWith(
                        color: isSelected
                            ? AppTheme.primaryColor
                            : AppTheme.textPrimaryColor,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.edit_outlined,
                      size: 20,
                      color: AppTheme.textSecondaryColor,
                    ),
                    onPressed: () => _showEditLessonDialog(context, lesson),
                    tooltip: 'Edit Lesson',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentPanel(BuildContext context) {
    return Consumer<LessonProvider>(
      builder: (context, lessonProvider, _) {
        if (lessonProvider.selectedLesson == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.touch_app_outlined,
                  size: 64,
                  color: AppTheme.primaryColor.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)!.selectLessonToViewContent,
                  style: AppTheme.headingMedium.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                lessonProvider.selectedLesson!.name,
                style: AppTheme.headingLarge,
              ),
              const SizedBox(height: 16),
              _buildContentTabs(context, lessonProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContentTabs(BuildContext context, LessonProvider lessonProvider) {
    return Expanded(
      child: DefaultTabController(
        length: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TabBar(
              tabs: [
                Tab(text: AppLocalizations.of(context)!.mediaContent),
                Tab(text: AppLocalizations.of(context)!.quizzesTab),
              ],
              labelColor: AppTheme.primaryColor,
              unselectedLabelColor: AppTheme.textSecondaryColor,
              indicatorColor: AppTheme.primaryColor,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TabBarView(
                children: [
                  // Media Content Tab
                  _buildMediaGrid(context, lessonProvider),

                  // Quizzes Tab
                  _buildQuizzesTab(context, lessonProvider),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizzesTab(BuildContext context, LessonProvider lessonProvider) {
    // Fetch quizzes for this lesson when the tab is shown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<quiz_provider.QuizProvider>(context, listen: false)
          .fetchQuizzes(lessonId: lessonProvider.selectedLesson!.id);
    });

    return Consumer<quiz_provider.QuizProvider>(
      builder: (context, quizProvider, _) {
        if (quizProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (quizProvider.error.isNotEmpty) {
          return Center(
            child: Text(
              'Error loading quizzes: ${quizProvider.error}',
              style: TextStyle(color: Colors.red),
            ),
          );
        }

        final lessonQuizzes = quizProvider.quizzes;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.quizzesTab,
                  style: AppTheme.headingMedium,
                ),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _navigateToCreateTasmi3(context, lessonProvider, widget.subject.subjectName!),
                      icon: const Icon(Icons.mic, size: 18, color: Colors.white),
                      label: Text(AppLocalizations.of(context)!.createTasmi3),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () => _navigateToCreateQuiz(context, lessonProvider,widget.subject.subjectName!),
                      icon: const Icon(Icons.add, size: 18, color: Colors.white),
                      label: Text(AppLocalizations.of(context)!.createQuiz),
                      style: AppTheme.primaryButtonStyle,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: lessonQuizzes.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.quiz_outlined,
                            size: 64,
                            color: AppTheme.primaryColor.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            AppLocalizations.of(context)!.noQuizzesForLesson,
                            style: AppTheme.headingMedium.copyWith(
                              color: AppTheme.textSecondaryColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppLocalizations.of(context)!.createQuizToTestKnowledge,
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppTheme.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: lessonQuizzes.length,
                      itemBuilder: (context, index) {
                        final quiz = lessonQuizzes[index];
                        final bool isRecordingQuiz = quiz.isRecord == true;
                        final Color cardColor = isRecordingQuiz ? Colors.green.shade50 : Colors.white;
                        final Color borderColor = isRecordingQuiz ? Colors.green.shade200 : Colors.grey.shade200;
                        final Color iconColor = isRecordingQuiz ? Colors.green : AppTheme.primaryColor;
                        final Color iconBackgroundColor = isRecordingQuiz ? Colors.green.withOpacity(0.1) : AppTheme.primaryColor.withOpacity(0.1);

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 2,
                          color: cardColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: borderColor, width: 1),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: iconBackgroundColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                isRecordingQuiz ? Icons.mic : Icons.quiz,
                                color: iconColor,
                              ),
                            ),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    quiz.name,
                                    style: AppTheme.bodyLarge.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                if (isRecordingQuiz)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      AppLocalizations.of(context)!.tasmi3,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  'Created: ${_formatDate(quiz.createdAt)}',
                                  style: AppTheme.bodyMedium.copyWith(
                                    color: AppTheme.textSecondaryColor,
                                  ),
                                ),
                                if (isRecordingQuiz)
                                  Row(
                                    children: [
                                      Icon(Icons.mic, size: 14, color: Colors.green.shade600),
                                      const SizedBox(width: 4),
                                      Text(
                                        AppLocalizations.of(context)!.audioRecordingAssessment,
                                        style: TextStyle(
                                          color: Colors.green.shade600,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _editQuiz(context, quiz),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _showDeleteQuizDialog(context, quiz),
                                ),
                              ],
                            ),
                            onTap: () => _viewQuizDetails(context, quiz),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _navigateToCreateQuiz(BuildContext context, LessonProvider lessonProvider, String subjectName) {
    final lesson = lessonProvider.selectedLesson!;
    // Get the semester ID from the current context

    // Try to get the semester ID and name from the quiz provider's semester list

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateQuizScreen(

          initialSubjectId: lesson.subjectId,
          initialLessonId: lesson.id,
          subjectName: subjectName ?? 'Subject ${lesson.subjectId}',
          lessonName: lesson.name,
        ),
      ),
    ).then((_) {
      if (context.mounted) {
        Provider.of<quiz_provider.QuizProvider>(context, listen: false)
            .fetchQuizzes(lessonId: lesson.id);
      }
    });
  }

  void _navigateToCreateTasmi3(BuildContext context, LessonProvider lessonProvider, String subjectName) {
    final lesson = lessonProvider.selectedLesson!;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateTasmi3Screen(
          initialSubjectId: lesson.subjectId,
          initialLessonId: lesson.id,
          subjectName: subjectName,
          lessonName: lesson.name,
        ),
      ),
    ).then((_) {
      if (context.mounted) {
        Provider.of<quiz_provider.QuizProvider>(context, listen: false)
            .fetchQuizzes(lessonId: lesson.id);
      }
    });
  }

  void _editQuiz(BuildContext context, quiz_provider.QuizGet quiz) async {
    // Store context before async operation
    final currentContext = context;

    final provider = Provider.of<quiz_provider.QuizProvider>(context, listen: false);

    try {
      await provider.fetchQuizById(quiz.id);

      // Check if the widget is still mounted before proceeding
      if (!context.mounted) return;

      final quizDetails = provider.currentQuiz;
      if (quizDetails != null) {
        String? subjectName = quiz.subject['name'] as String;

        // Use Future.microtask to avoid the context issue
        Future.microtask(() {
          if (context.mounted) {
            Navigator.push(
              currentContext,
              MaterialPageRoute(
                builder: (context) => CreateQuizScreen(
                  quizToEdit: quizDetails,
                  subjectName: subjectName,
                  lessonName: quizDetails.lesson!['name'],
                ),
              ),
            ).then((_) {
              // Check if still mounted before updating
              if (context.mounted) {
                // Refresh quizzes after returning
                final lessonProvider = Provider.of<LessonProvider>(currentContext, listen: false);
                if (lessonProvider.selectedLesson != null) {
                  Provider.of<quiz_provider.QuizProvider>(currentContext, listen: false)
                      .fetchQuizzes(lessonId: lessonProvider.selectedLesson!.id);
                }
              }
            });
          }
        });
      }
    } catch (e) {
      // Handle errors
      if (context.mounted) {
        ScaffoldMessenger.of(currentContext).showSnackBar(
          SnackBar(content: Text('Error loading quiz: $e')),
        );
      }
    }
  }

  void _viewQuizDetails(BuildContext context, quiz_provider.QuizGet quiz) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizDetailsScreen(quizId: quiz.id),
      ),
    );
  }

  void _showDeleteQuizDialog(BuildContext context, quiz_provider.QuizGet quiz) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteQuizTitle),
        content: Text('Are you sure you want to delete "${quiz.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () async {
              try {
                await Provider.of<quiz_provider.QuizProvider>(context, listen: false)
                    .deleteQuiz(quiz.id);

                if (!context.mounted) return;

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context)!.quizDeletedSuccessfully),
                    backgroundColor: Colors.green,
                  ),
                );

                if (context.mounted) {
                  final lessonProvider = Provider.of<LessonProvider>(context, listen: false);
                  Provider.of<quiz_provider.QuizProvider>(context, listen: false)
                      .fetchQuizzes(lessonId: lessonProvider.selectedLesson!.id);
                }
              } catch (e) {
                if (!context.mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to delete quiz: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text(
              AppLocalizations.of(context)!.delete,
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaGrid(BuildContext context, LessonProvider lessonProvider) {
    if (lessonProvider.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_to_photos_outlined,
              size: 64,
              color: AppTheme.primaryColor.withAlpha(128),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.noMediaContentYet,
              style: AppTheme.headingMedium.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add videos, PDFs, or audio files to this lesson',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
      );
    }

    // Removed the Expanded widget since it's already inside an Expanded in the TabBarView
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 3.2, // Makes cards more horizontal/compact
      ),
      padding: const EdgeInsets.all(12),
      itemCount: lessonProvider.items.length,
      itemBuilder: (context, index) {
        final item = lessonProvider.items[index];
        return _buildMediaCard(context, item);
      },
    );
  }

  Widget _buildMediaCard(BuildContext context, dynamic item) {
    IconData getMediaIcon() {
      switch (item.itemType.toLowerCase()) {
        case 'video':
          return Icons.play_circle_outline;
        case 'pdf':
          return Icons.picture_as_pdf_outlined;
        case 'audio':
          return Icons.audiotrack_outlined;
        default:
          return Icons.insert_drive_file_outlined;
      }
    }

    Color getTypeColor() {
      switch (item.itemType.toLowerCase()) {
        case 'video':
          return Colors.blue;
        case 'pdf':
          return Colors.red;
        case 'audio':
          return Colors.green;
        default:
          return Colors.grey;
      }
    }

    void handleItemTap() {
      switch (item.itemType.toLowerCase()) {
        case 'video':
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoViewer(
                videoUrl: item.itemContent,
                title: item.title,
              ),
            ),
          );
          break;

        case 'pdf':
          print("conteeent a ged3an ${item.itemContent}");
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PdfViewer(
                pdfUrl: item.itemContent,
                title: item.title,
              ),
            ),
          );
          break;

        case 'audio':
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AudioPlayerWidget(
                audioUrl: item.itemContent,
                title: item.title,
              ),
            ),
          );
          break;
      }
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: handleItemTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: getTypeColor().withAlpha(25),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      getMediaIcon(),
                      size: 24,
                      color: getTypeColor(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: AppTheme.bodyLarge.copyWith(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: getTypeColor().withAlpha(25),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item.itemType.toUpperCase(),
                            style: AppTheme.bodyMedium.copyWith(
                              color: getTypeColor(),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    color: AppTheme.primaryColor,
                    onPressed: () => _showEditLessonItemDialog(context, item),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    color: Colors.red.withAlpha(204),
                    onPressed: () => _showDeleteConfirmation(context, item),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return Consumer<LessonProvider>(
      builder: (context, lessonProvider, _) {
        if (lessonProvider.selectedLesson == null) return Container();

        return FloatingActionButton.extended(
          onPressed: () => _showAddMediaDialog(context),
          backgroundColor: AppTheme.primaryColor,
          icon: const Icon(Icons.add),
          label: Text(AppLocalizations.of(context)!.addMedia),
        );
      },
    );
  }

  void _showSubjectInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.subjectInformation, style: AppTheme.headingMedium),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(AppLocalizations.of(context)!.subjectName, widget.subject.subjectName ?? 'NA'),
            _buildInfoRow(AppLocalizations.of(context)!.subjectCode, widget.subject.code ?? 'NA'),
            // Add more subject details as needed
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.close,
                style: TextStyle(color: AppTheme.primaryColor)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  void _showAddLessonDialog(BuildContext context) {
    final TextEditingController lessonNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.addLessonButton, style: AppTheme.headingMedium),
        content: TextField(
          controller: lessonNameController,
          decoration: AppTheme.inputDecoration(AppLocalizations.of(context)!.enterLessonName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel, style: TextStyle(color: AppTheme.primaryColor)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (lessonNameController.text.isNotEmpty) {
                await Provider.of<LessonProvider>(context, listen: false)
                    .addLesson(lessonNameController.text, widget.subject.subjectId!);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: Text(AppLocalizations.of(context)!.addButton),
          ),
        ],
      ),
    );
  }

  void _showEditLessonDialog(BuildContext context, dynamic lesson) {
    final TextEditingController lessonNameController = TextEditingController(text: lesson.name);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Lesson', style: AppTheme.headingMedium),
        content: TextField(
          controller: lessonNameController,
          decoration: AppTheme.inputDecoration('Lesson Name'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel, style: TextStyle(color: AppTheme.primaryColor)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (lessonNameController.text.isNotEmpty && lessonNameController.text != lesson.name) {
                final navigator = Navigator.of(context);
                final scaffoldMessenger = ScaffoldMessenger.of(context);

                try {
                  await Provider.of<LessonProvider>(context, listen: false)
                      .updateLesson(
                        lessonId: lesson.id,
                        name: lessonNameController.text,
                      );
                  navigator.pop();

                  if (mounted) {
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: Text('Lesson updated successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  navigator.pop();
                  if (mounted) {
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: Text('Error updating lesson: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              } else {
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showAddMediaDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.addMedia, style: AppTheme.headingMedium),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.video_library_outlined),
              title: Text(AppLocalizations.of(context)!.videoType),
              onTap: () {
                Navigator.pop(context);
                _showVideoUrlDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf_outlined),
              title: Text(AppLocalizations.of(context)!.pdfType),
              onTap: () {
                Navigator.pop(context);
                _showPdfDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.audiotrack_outlined),
              title: Text(AppLocalizations.of(context)!.audioType),
              onTap: () {
                Navigator.pop(context);
                _showAudioDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showPdfDialog(BuildContext context) {
    final titleController = TextEditingController();
    html.File? selectedFile;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.addPdf, style: AppTheme.headingMedium),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: AppTheme.inputDecoration(AppLocalizations.of(context)!.pdfTitle)
                    .copyWith(
                  hintText: AppLocalizations.of(context)!.enterPdfTitle,
                  prefixIcon: Icon(Icons.title),
                ),
              ),
              SizedBox(height: 16),
              if (selectedFile != null)
                Row(
                  children: [
                    Icon(Icons.picture_as_pdf, color: AppTheme.primaryColor),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        selectedFile?.name ?? AppLocalizations.of(context)!.noFileSelected,
                        style: AppTheme.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () async {
                  final input = html.FileUploadInputElement()
                    ..accept = '.pdf'
                    ..click();

                  input.onChange.listen((event) {
                    if (input.files?.isNotEmpty ?? false) {
                      setState(() {
                        selectedFile = input.files![0];
                      });
                    }
                  });
                },
                icon: Icon(Icons.upload_file),
                label: Text(AppLocalizations.of(context)!.choosePdf),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Max file size: 20MB',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textSecondaryColor,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          actions: [
            Consumer<LessonProvider>(
              builder: (context, provider, child) {
                return ElevatedButton(
                  onPressed: provider.isUploading ? null : () async {
                    try {
                      await provider.uploadPdfItem(
                        lessonId: provider.selectedLesson!.id,
                        title: titleController.text,
                        file: selectedFile!,
                      );
                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.toString())),
                      );
                    }
                  },
                  child: provider.isUploading
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 2,
                          ),
                        )
                      : Text(AppLocalizations.of(context)!.upload),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAudioDialog(BuildContext context) {
    final titleController = TextEditingController();
    html.File? selectedFile;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.addAudio, style: AppTheme.headingMedium),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: AppTheme.inputDecoration(AppLocalizations.of(context)!.audioTitle)
                    .copyWith(
                  hintText: AppLocalizations.of(context)!.enterAudioTitle,
                  prefixIcon: Icon(Icons.title),
                ),
              ),
              SizedBox(height: 16),
              if (selectedFile != null)
                Row(
                  children: [
                    Icon(Icons.audiotrack, color: AppTheme.primaryColor),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        selectedFile?.name ?? AppLocalizations.of(context)!.noFileSelected,
                        style: AppTheme.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () async {
                  final input = html.FileUploadInputElement()
                    ..accept = '.mp3,.wav,.ogg,.m4a'
                    ..click();

                  input.onChange.listen((event) {
                    if (input.files?.isNotEmpty ?? false) {
                      setState(() {
                        selectedFile = input.files![0];
                      });
                    }
                  });
                },
                icon: Icon(Icons.upload_file),
                label: Text(AppLocalizations.of(context)!.chooseAudio),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Supported: MP3, WAV, OGG, M4A • Max size: 50MB',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textSecondaryColor,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          actions: [
            Consumer<LessonProvider>(
              builder: (context, provider, child) {
                return ElevatedButton(
                  onPressed: provider.isUploading || selectedFile == null ? null : () async {
                    if (titleController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(AppLocalizations.of(context)!.pleaseEnterTitle)),
                      );
                      return;
                    }

                    try {
                      await provider.uploadAudioItem(
                        lessonId: provider.selectedLesson!.id,
                        title: titleController.text,
                        file: selectedFile!,
                      );
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(AppLocalizations.of(context)!.audioUploadedSuccessfully)),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.toString())),
                      );
                    }
                  },
                  child: provider.isUploading
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 2,
                          ),
                        )
                      : Text(AppLocalizations.of(context)!.upload),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showVideoUrlDialog(BuildContext context) {
    String videoUrl = '';
    final titleController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.addVideoUrl, style: AppTheme.headingMedium),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: AppTheme.inputDecoration(AppLocalizations.of(context)!.videoTitle)
                .copyWith(
                  hintText: AppLocalizations.of(context)!.enterVideoTitle,
                  prefixIcon: Icon(Icons.title),
                ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: AppTheme.inputDecoration(AppLocalizations.of(context)!.enterVideoUrl)
                .copyWith(
                  hintText: 'https://example.com/video',
                  prefixIcon: Icon(Icons.link),
                ),
              onChanged: (value) => videoUrl = value,
            ),
            SizedBox(height: 8),
            Text(
              'Supported platforms: YouTube, Vimeo',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              if (videoUrl.isNotEmpty && titleController.text.isNotEmpty) {
                try {
                  await Provider.of<LessonProvider>(context, listen: false)
                      .uploadLessonItem(
                        lessonId: Provider.of<LessonProvider>(context, listen: false).selectedLesson!.id,
                        title: titleController.text,
                        itemType: 'video',
                        itemContent: videoUrl,
                      );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppLocalizations.of(context)!.videoAddedSuccessfully)),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${AppLocalizations.of(context)!.errorAddingVideo}: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: Text(AppLocalizations.of(context)!.addButton),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, LessonItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${item.itemType.capitalize()}?'),
        content: Text('Are you sure you want to delete "${item.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          Consumer<LessonProvider>(
            builder: (context, provider, _) => ElevatedButton(
              onPressed: provider.isDeleting
                ? null
                : () async {
                    try {
                      await provider.deleteLessonItem(item);
                      Navigator.pop(context);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${item.itemType.capitalize()} deleted successfully'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      Navigator.pop(context);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(e.toString()),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: provider.isDeleting
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2,
                    ),
                  )
                : Text(AppLocalizations.of(context)!.delete),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditLessonItemDialog(BuildContext context, LessonItem item) {
    final titleController = TextEditingController(text: item.title);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.edit_outlined,
              color: AppTheme.primaryColor,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              AppLocalizations.of(context)!.editLessonItemTitle,
              style: AppTheme.headingMedium.copyWith(
                color: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: AppTheme.inputDecoration(AppLocalizations.of(context)!.enterItemTitle),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppLocalizations.of(context)!.cancel,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty) {
                // Store context before async operation
                final currentContext = context;
                final navigator = Navigator.of(context);
                final scaffoldMessenger = ScaffoldMessenger.of(context);

                try {
                  final provider = Provider.of<SemestersProvider>(currentContext, listen: false);
                  await provider.updateLessonItem(
                    itemId: item.id,
                    title: titleController.text,
                  );

                  navigator.pop();

                  // Refresh the lesson items
                  final lessonProvider = Provider.of<LessonProvider>(currentContext, listen: false);
                  if (lessonProvider.selectedLesson != null) {
                    await lessonProvider.fetchLessonItems(lessonProvider.selectedLesson!.id);
                  }

                  if (mounted) {
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: Text(AppLocalizations.of(currentContext)!.lessonItemUpdatedSuccessfully),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: Text(e.toString()),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            style: AppTheme.primaryButtonStyle,
            child: Text(AppLocalizations.of(context)!.update),
          ),
        ],
      ),
    );
  }

  void _showSubcategoriesModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ChangeNotifierProvider(
        create: (context) => SubcategoryProvider(),
        child: SubcategoriesModal(subject: widget.subject),
      ),
    );
  }
}
