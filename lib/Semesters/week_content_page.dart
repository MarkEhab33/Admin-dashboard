import 'package:admin_dashboard/Models/subject.dart';
import 'package:admin_dashboard/Quizzes/quiz_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Models/Subject_Template.dart';
import '../Models/week.dart';

import '../provider/quiz_provider.dart';
import '../provider/semesters_provider.dart';
import '../Theme.dart';
import '../l10n/app_localizations.dart';

class WeekContentPage extends StatefulWidget {
  final Week week;
  final int? semesterId;
  const WeekContentPage({Key? key, required this.week, this.semesterId}) : super(key: key);

  @override
  State<WeekContentPage> createState() => _WeekContentPageState();
}

class _WeekContentPageState extends State<WeekContentPage> {
  Map<String, List<Lesson>> _groupedLessons = {};
  List<dynamic> _weekQuizzes = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Don't call _fetchData() here - move to didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isLoading) {
      _fetchData();
    }
  }

  Future<void> _fetchData() async {
    await Future.wait([
      _fetchLessons(),
      _fetchQuizzes(),
    ]);
  }

  Future<void> _fetchLessons() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final provider = Provider.of<SemestersProvider>(context, listen: false);
      final lessons = await provider.fetchWeekLessons(widget.week.id);

      // Group lessons by subject name - we'll handle localization in the UI
      final grouped = <String, List<Lesson>>{};
      for (var lesson in lessons) {
        final subjectName = lesson.subject?.subjectName ?? 'Uncategorized';
        if (!grouped.containsKey(subjectName)) {
          grouped[subjectName] = [];
        }
        grouped[subjectName]!.add(lesson);
      }

      // Sort the groups alphabetically by subject name
      final sortedGroups = Map.fromEntries(
        grouped.entries.toList()
          ..sort((a, b) => a.key.compareTo(b.key))
      );

      setState(() {
        _groupedLessons = sortedGroups;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchQuizzes() async {
    try {
      final provider = Provider.of<SemestersProvider>(context, listen: false);
      final quizzes = await provider.fetchWeekQuizzes(widget.week.id);
      setState(() {
        _weekQuizzes = quizzes;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  void _deleteLessonFromWeek(BuildContext context, int lessonId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteLesson),
        content: Text(AppLocalizations.of(context)!.deleteLessonConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () async {
              try {
                final provider = Provider.of<SemestersProvider>(context, listen: false);
                await provider.deleteLesson(widget.week.id, lessonId);
                
                Navigator.pop(context);
                _fetchLessons(); // Refresh the lessons list
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppLocalizations.of(context)!.lessonSuccessfullyRemovedFromWeek)),
                  );
                }
              } catch (e) {
                Navigator.pop(context);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString()),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text(AppLocalizations.of(context)!.delete, style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAddLessonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.5,
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.add_circle_outline, 
                    color: AppTheme.primaryColor,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    AppLocalizations.of(context)!.addLessonToWeek,
                    style: AppTheme.headingMedium.copyWith(
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Consumer<SemestersProvider>(
                  builder: (context, provider, _) {
                    return FutureBuilder<List<Subject>>(
                      future: provider.fetchSemesterSubjects(widget.week.semesterId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        
                        if (snapshot.hasError) {
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.error_outline, 
                                  size: 48, 
                                  color: Colors.red.shade400
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Error: ${snapshot.error}',
                                  style: AppTheme.bodyLarge.copyWith(
                                    color: Colors.red.shade700,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        }

                        final subjects = snapshot.data ?? [];
                        if (subjects.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.folder_off,
                                  size: 48,
                                  color: AppTheme.primaryColor.withOpacity(0.5),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  AppLocalizations.of(context)!.noSubjectsFound,
                                  style: AppTheme.bodyLarge.copyWith(
                                    color: AppTheme.textSecondaryColor,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListView.separated(
                            itemCount: subjects.length,
                            separatorBuilder: (context, index) => Divider(
                              height: 1,
                              color: AppTheme.primaryColor.withOpacity(0.1),
                            ),
                            itemBuilder: (context, index) {
                              final subject = subjects[index];
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  dividerColor: Colors.transparent,
                                ),
                                child: ExpansionTile(
                                  leading: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(Icons.subject,
                                      color: AppTheme.primaryColor,
                                      size: 20,
                                    ),
                                  ),
                                  title: Text(
                                    subject.subjectName ?? AppLocalizations.of(context)!.unnamedSubject,
                                    style: AppTheme.bodyLarge.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Code: ${subject.code ?? 'NA'}',
                                    style: AppTheme.bodyMedium,
                                  ),
                                  children: [
                                    FutureBuilder<List<Lesson>>(
                                      future: provider.fetchSubjectLessons(subject.subjectId ?? 0),
                                      builder: (context, lessonSnapshot) {
                                        if (lessonSnapshot.connectionState == ConnectionState.waiting) {
                                          return const Padding(
                                            padding: EdgeInsets.all(16),
                                            child: Center(child: CircularProgressIndicator()),
                                          );
                                        }

                                        final lessons = lessonSnapshot.data ?? [];
                                        if (lessons.isEmpty) {
                                          return Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Center(
                                              child: Text(
                                                AppLocalizations.of(context)!.noLessonsAvailable,
                                                style: AppTheme.bodyMedium.copyWith(
                                                  color: AppTheme.textSecondaryColor,
                                                ),
                                              ),
                                            ),
                                          );
                                        }

                                        return ListView.builder(
                                          shrinkWrap: true,
                                          physics: const NeverScrollableScrollPhysics(),
                                          itemCount: lessons.length,
                                          itemBuilder: (context, lessonIndex) {
                                            final lesson = lessons[lessonIndex];
                                            return ListTile(
                                              leading: const Icon(Icons.book_outlined),
                                              title: Text(lesson.name),
                                              contentPadding: const EdgeInsets.symmetric(
                                                horizontal: 32,
                                                vertical: 8,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              onTap: () async {
                                                try {
                                                  await provider.addLessonToWeek(
                                                    weekId: widget.week.id,
                                                    lessonId: lesson.id,
                                                  );
                                                  Navigator.pop(context);
                                                  _fetchLessons();
                                                  
                                                  if (context.mounted) {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(
                                                        content: Text(AppLocalizations.of(context)!.lessonAddedSuccessfully),
                                                        backgroundColor: Colors.green,
                                                      ),
                                                    );
                                                  }
                                                } catch (e) {
                                                  if (context.mounted) {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(
                                                        content: Text(e.toString()),
                                                        backgroundColor: Colors.red,
                                                      ),
                                                    );
                                                  }
                                                }
                                              },
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      AppLocalizations.of(context)!.cancel,
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textSecondaryColor,
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

  void _showEditLessonDialog(BuildContext context, Lesson lesson) {
    final lessonNameController = TextEditingController(text: lesson.name);
    int selectedSubjectId = lesson.subjectId;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.4,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.edit_outlined,
                    color: AppTheme.primaryColor,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    AppLocalizations.of(context)!.editLessonTitle,
                    style: AppTheme.headingMedium.copyWith(
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: lessonNameController,
                decoration: AppTheme.inputDecoration(AppLocalizations.of(context)!.enterLessonName),
              ),
              const SizedBox(height: 16),
              Consumer<SemestersProvider>(
                builder: (context, provider, _) {
                  return FutureBuilder<List<Subject>>(
                    future: provider.fetchSemesterSubjects(widget.week.semesterId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }

                      final subjects = snapshot.data ?? [];
                      if (subjects.isEmpty) {
                        return Text(AppLocalizations.of(context)!.noSubjectsFound);
                      }

                      return DropdownButtonFormField<int>(
                        value: selectedSubjectId,
                        decoration: AppTheme.inputDecoration('Subject'),
                        items: subjects.map((subject) {
                          return DropdownMenuItem<int>(
                            value: subject.subjectId,
                            child: Text(subject.subjectName ?? 'Unnamed Subject'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            selectedSubjectId = value;
                          }
                        },
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      AppLocalizations.of(context)!.cancel,
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () async {
                      if (lessonNameController.text.isNotEmpty) {
                        try {
                          final provider = Provider.of<SemestersProvider>(context, listen: false);
                          await provider.updateLesson(
                            lessonId: lesson.id,
                            name: lessonNameController.text,
                            subjectId: selectedSubjectId,
                          );

                          Navigator.pop(context);
                          _fetchLessons(); // Refresh the lessons list

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(AppLocalizations.of(context)!.lessonUpdatedSuccessfully),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuizzesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context)!.weekQuizzes,
              style: AppTheme.headingMedium,
            ),

          ],
        ),
        const SizedBox(height: 16),
        if (_weekQuizzes.isEmpty)
          Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.quiz_outlined, 
                    size: 48, 
                    color: Colors.grey.shade400
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.noQuizzesAssignedToWeek,
                    style: AppTheme.bodyLarge.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _weekQuizzes.length,
            itemBuilder: (context, index) {
              final quiz = _weekQuizzes[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
             Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QuizDetailsScreen(quizId: quiz["id"],semesterId:widget.semesterId ,),
                ),
              );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _getQuizTypeIcon(quiz['type']),
                            color: AppTheme.primaryColor,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                quiz['name'] ?? AppLocalizations.of(context)!.untitledQuiz,
                                style: AppTheme.bodyLarge.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                quiz['subjectName'] ?? AppLocalizations.of(context)!.noSubject,
                                style: AppTheme.bodyMedium.copyWith(
                                  color: AppTheme.textSecondaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getQuizTypeColor(quiz['type']).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _formatQuizType(quiz['type']),
                            style: AppTheme.bodyMedium.copyWith(
                              color: _getQuizTypeColor(quiz['type']),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          color: Colors.red.shade400,
                          onPressed: () => _showDeleteQuizDialog(context, quiz['id']),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  IconData _getQuizTypeIcon(String? type) {
    switch (type?.toUpperCase()) {
      case 'MULTIPLE_CHOICE':
        return Icons.check_circle_outline;
      case 'TRUE_FALSE':
        return Icons.rule;
      case 'ESSAY':
        return Icons.edit_note;
      default:
        return Icons.quiz;
    }
  }

  Color _getQuizTypeColor(String? type) {
    switch (type?.toUpperCase()) {
      case 'MULTIPLE_CHOICE':
        return Colors.green;
      case 'TRUE_FALSE':
        return Colors.blue;
      case 'ESSAY':
        return Colors.purple;
      default:
        return AppTheme.primaryColor;
    }
  }

  String _formatQuizType(String? type) {
    if (type == null) return AppLocalizations.of(context)!.unknown;
    return type.split('_').map((word) => 
      word[0].toUpperCase() + word.substring(1).toLowerCase()
    ).join(' ');
  }



  void _showDeleteQuizDialog(BuildContext context, int quizId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.removeQuiz),
        content: Text(AppLocalizations.of(context)!.removeQuizConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () async {
              try {
                final provider = Provider.of<SemestersProvider>(context, listen: false);
                await provider.removeQuizFromWeek(widget.week.id, quizId);
                Navigator.pop(context);
                _fetchQuizzes();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppLocalizations.of(context)!.quizRemovedSuccessfully)),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(e.toString()),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text(AppLocalizations.of(context)!.remove, style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('محتوى اسبوع ${widget.week.weekNo} '),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Existing lessons section
            _buildLessonsSection(),
            
            // Add the new quizzes section here
            _buildQuizzesSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.errorLoadingContent,
              style: AppTheme.headingMedium.copyWith(color: Colors.red.shade700),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? AppLocalizations.of(context)!.unknownErrorOccurred,
              style: AppTheme.bodyMedium.copyWith(color: Colors.red.shade600),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _fetchLessons,
              icon: const Icon(Icons.refresh),
              label: Text(AppLocalizations.of(context)!.tryAgain),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade100,
                foregroundColor: Colors.red.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context)!.weekLessons,
              style: AppTheme.headingMedium,
            ),
            ElevatedButton.icon(
              onPressed: () => _showAddLessonDialog(context),
              icon: const Icon(Icons.add, size: 18, color: Colors.white),
              label: Text(AppLocalizations.of(context)!.addLesson),
              style: AppTheme.primaryButtonStyle,
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_groupedLessons.isEmpty)
          Center(
            child: Text(
              AppLocalizations.of(context)!.noLessonsAssignedToWeek,
              style: AppTheme.bodyLarge.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
            ),
          )
        else
          Column(
            children: _groupedLessons.entries.map((entry) {
              return Column(
                children: [
                  _buildSubjectSection(entry.key, entry.value),
                  const SizedBox(height: 16),
                ],
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildWeekHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.2),
            blurRadius: 20,
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
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.calendar_today,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Week ${widget.week.weekNo}',
                style: AppTheme.headingLarge.copyWith(
                  color: Colors.white,
                  fontSize: 32,
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${_getTotalLessonsCount()} ${_getTotalLessonsCount() == 1 ? AppLocalizations.of(context)!.singleLesson : AppLocalizations.of(context)!.multipleLessons} in ${_groupedLessons.length} ${_groupedLessons.length == 1 ? AppLocalizations.of(context)!.subject : AppLocalizations.of(context)!.subjects}',
                  style: AppTheme.bodyLarge.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ),

              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.date_range,
                      color: Colors.white.withOpacity(0.9),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_formatDate(widget.week.startDate)} - ${_formatDate(widget.week.endDate)}',
                      style: AppTheme.bodyLarge.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectSection(String subjectName, List<Lesson> lessons) {
    final subject = lessons.first.subject;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.04),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.subject,
                    color: AppTheme.primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subjectName == 'Uncategorized' ? AppLocalizations.of(context)!.uncategorized : subjectName,
                        style: AppTheme.headingMedium.copyWith(
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      if (subject?.code != null)
                        Text(
                          'Code: ${subject!.code}',
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${lessons.length} ${lessons.length == 1 ? AppLocalizations.of(context)!.singleLesson : AppLocalizations.of(context)!.multipleLessons}',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: lessons.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: Colors.grey.withOpacity(0.1),
            ),
            itemBuilder: (context, index) => _buildLessonTile(lessons[index]),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonTile(Lesson lesson) {
    return ListTile(
      contentPadding: const EdgeInsets.all(16),
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.secondaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            Icon(
              Icons.book,
              color: AppTheme.secondaryColor,
              size: 24,
            ),
            if (lesson.items.isNotEmpty)
              Positioned(
                right: -6,
                bottom: -6,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Text(
                    lesson.items.length.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      title: Text(
        lesson.name,
        style: AppTheme.bodyLarge.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            'Added: ${_formatDate(lesson.createdAt)}',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
          ),
          if (lesson.items.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              '${lesson.items.length} ${lesson.items.length == 1 ? 'item' : 'items'}',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _showEditLessonDialog(context, lesson),
            color: AppTheme.primaryColor,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _deleteLessonFromWeek(context, lesson.id),
            color: Colors.red.shade400,
          ),
        ],
      ),
      onTap: () {
        // TODO: Navigate to lesson details
      },
    );
  }

  int _getTotalLessonsCount() {
    return _groupedLessons.values
        .map((lessons) => lessons.length)
        .reduce((a, b) => a + b);
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}






