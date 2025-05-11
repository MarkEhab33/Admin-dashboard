
import 'dart:html' as html;

import 'package:admin_dashboard/utils/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart'; // for file picking
import 'package:provider/provider.dart';
import '../Models/Subject_Template.dart';
import '../Models/lesson_item.dart';
import '../provider/subject_provider.dart';
import '../provider/quiz_provider.dart' as quiz_provider;
import '../Theme.dart';
import '../services/cloudinary_service.dart';
import '../widgets/audio_player.dart';
import '../widgets/pdf_viewer.dart';
import '../widgets/video_viewer.dart';
import '../Quizzes/create_quiz_screen.dart';
import '../Quizzes/quiz_details_screen.dart';

class SubjectDetailsScreen extends StatelessWidget {
  final Subject subject;

  const SubjectDetailsScreen({Key? key, required this.subject}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Fetch lessons after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LessonProvider>(context, listen: false)
          .fetchLessons(subject.subjectId!);
    });

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          subject.subjectName ?? "NA",
          style: AppTheme.headingMedium.copyWith(color: Colors.white),
        ),
        backgroundColor: AppTheme.primaryColor,
        actions: [
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
                    'Lessons',
                    style: AppTheme.headingLarge.copyWith(
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showAddLessonDialog(context),
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text('Add Lesson'),
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
                'Manage your course content',
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
                        'No lessons yet',
                        style: AppTheme.headingMedium.copyWith(
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Start by adding your first lesson',
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
                  'Select a lesson to view content',
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
              tabs: const [
                Tab(text: 'Media Content'),
                Tab(text: 'Quizzes'),
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
                  'Quizzes',
                  style: AppTheme.headingMedium,
                ),
                ElevatedButton.icon(
                  onPressed: () => _navigateToCreateQuiz(context, lessonProvider),
                  icon: const Icon(Icons.add, size: 18, color: Colors.white),
                  label: const Text('Create Quiz'),
                  style: AppTheme.primaryButtonStyle,
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
                            'No quizzes for this lesson',
                            style: AppTheme.headingMedium.copyWith(
                              color: AppTheme.textSecondaryColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Create a quiz to test student knowledge',
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
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.quiz,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            title: Text(
                              quiz.name,
                              style: AppTheme.bodyLarge.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  'Type: ${quiz.type} • Grade: ${quiz.semester['grade']}',
                                  style: AppTheme.bodyMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Created: ${_formatDate(quiz.createdAt)}',
                                  style: AppTheme.bodyMedium.copyWith(
                                    color: AppTheme.textSecondaryColor,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _editQuiz(context, quiz, lessonProvider),
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

  void _navigateToCreateQuiz(BuildContext context, LessonProvider lessonProvider) {
    final lesson = lessonProvider.selectedLesson!;
    // Get the semester ID from the current context
    final quizProvider = Provider.of<quiz_provider.QuizProvider>(context, listen: false);
    int? semesterId;
    String? semesterName;
    String? subjectName;

    // Try to get the semester ID and name from the quiz provider's semester list
    if (quizProvider.semestersList.isNotEmpty) {
      // For simplicity, we'll use the first semester in the list
      final semester = quizProvider.semestersList.first;
      semesterId = semester['id'];
      semesterName = semester['name'];

      // Try to find the subject name
      if (semester['subjects'] != null) {
        final subjects = List<Map<String, dynamic>>.from(semester['subjects']);
        final subject = subjects.firstWhere(
          (s) => s['id'] == lesson.subjectId,
          orElse: () => {},
        );
        if (subject.isNotEmpty) {
          subjectName = subject['name'];
        }
      }
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateQuizScreen(
          initialSemesterId: semesterId,
          initialSubjectId: lesson.subjectId,
          initialLessonId: lesson.id,
          semesterName: semesterName,
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

  void _editQuiz(BuildContext context, quiz_provider.QuizGet quiz, LessonProvider lessonProvider) async {
    final provider = Provider.of<quiz_provider.QuizProvider>(context, listen: false);
    await provider.fetchQuizById(quiz.id);

    if (!context.mounted) return;

    final quizDetails = provider.currentQuiz;
    if (quizDetails != null) {
      // Get the semester and subject names from the quiz
      String? semesterName = quiz.semester['name'] as String?;
      String? subjectName = quiz.subject['name'] as String?;
      String? lessonName;

      // Get the lesson name
      if (quiz.lesson != null) {
        lessonName = quiz.lesson!['name'] as String?;
      } else if (lessonProvider.selectedLesson != null) {
        lessonName = lessonProvider.selectedLesson!.name;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CreateQuizScreen(
            quizToEdit: quizDetails,
            semesterName: semesterName,
            subjectName: subjectName,
            lessonName: lessonName,
          ),
        ),
      ).then((_) {
        if (context.mounted) {
          provider.fetchQuizzes(lessonId: lessonProvider.selectedLesson!.id);
        }
      });
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
        title: const Text('Delete Quiz'),
        content: Text('Are you sure you want to delete "${quiz.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await Provider.of<quiz_provider.QuizProvider>(context, listen: false)
                    .deleteQuiz(quiz.id);

                if (!context.mounted) return;

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Quiz deleted successfully'),
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
            child: const Text(
              'Delete',
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
              'No media content yet',
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
          label: const Text('Add Media'),
        );
      },
    );
  }

  void _showSubjectInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Subject Information', style: AppTheme.headingMedium),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Subject Name', subject.subjectName ?? 'NA'),
            _buildInfoRow('Subject Code', subject.code ?? 'NA'),
            // Add more subject details as needed
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close',
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
        title: Text('Add Lesson', style: AppTheme.headingMedium),
        content: TextField(
          controller: lessonNameController,
          decoration: AppTheme.inputDecoration('Enter lesson name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppTheme.primaryColor)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (lessonNameController.text.isNotEmpty) {
                await Provider.of<LessonProvider>(context, listen: false)
                    .addLesson(lessonNameController.text, subject.subjectId!);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddMediaDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Media', style: AppTheme.headingMedium),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.video_library_outlined),
              title: const Text('Video'),
              onTap: () {
                Navigator.pop(context);
                _showVideoUrlDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf_outlined),
              title: const Text('PDF'),
              onTap: () {
                Navigator.pop(context);
                _showPdfDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.audiotrack_outlined),
              title: const Text('Audio'),
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
          title: Text('Add PDF', style: AppTheme.headingMedium),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: AppTheme.inputDecoration('PDF Title')
                    .copyWith(
                  hintText: 'Enter PDF title',
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
                        selectedFile?.name ?? 'No file selected',
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
                label: Text('Choose PDF'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
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
                      : Text('Upload'),
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
          title: Text('Add Audio', style: AppTheme.headingMedium),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: AppTheme.inputDecoration('Audio Title')
                    .copyWith(
                  hintText: 'Enter audio title',
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
                        selectedFile?.name ?? 'No file selected',
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
                    ..accept = '.mp3,.wav,.m4a'
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
                label: Text('Choose Audio'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
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
                        SnackBar(content: Text('Please enter a title')),
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
                        SnackBar(content: Text('Audio uploaded successfully')),
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
                      : Text('Upload'),
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
        title: Text('Add Video URL', style: AppTheme.headingMedium),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: AppTheme.inputDecoration('Video Title')
                .copyWith(
                  hintText: 'Enter video title',
                  prefixIcon: Icon(Icons.title),
                ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: AppTheme.inputDecoration('Enter video URL')
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
            child: Text('Cancel'),
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
                    SnackBar(content: Text('Video added successfully')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error adding video: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: Text('Add'),
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
            child: Text('Cancel'),
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
                : Text('Delete'),
            ),
          ),
        ],
      ),
    );
  }
}
