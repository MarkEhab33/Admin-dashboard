import 'package:admin_dashboard/Models/subject.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Models/Subject_Template.dart';
import '../Models/week.dart';

import '../provider/semesters_provider.dart';
import '../Theme.dart';

class WeekContentPage extends StatefulWidget {
  final Week week;

  const WeekContentPage({Key? key, required this.week}) : super(key: key);

  @override
  State<WeekContentPage> createState() => _WeekContentPageState();
}

class _WeekContentPageState extends State<WeekContentPage> {
  Map<String, List<Lesson>> _groupedLessons = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchLessons();
  }

  Future<void> _fetchLessons() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final provider = Provider.of<SemestersProvider>(context, listen: false);
      final lessons = await provider.fetchWeekLessons(widget.week.id);

      // Group lessons by subject name
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

  void _deleteLessonFromWeek(BuildContext context, int lessonId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Lesson'),
        content: const Text('Are you sure you want to remove this lesson from the week?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
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
                    const SnackBar(content: Text('Lesson successfully removed from week')),
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
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
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
                    'Add Lesson to Week',
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
                                  'No subjects found',
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
                                    subject.subjectName ?? 'Unnamed Subject',
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
                                                'No lessons available',
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
                                                      const SnackBar(
                                                        content: Text('Lesson added successfully'),
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
                      'Cancel',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Week ${widget.week.weekNo} Content',
          style: AppTheme.headingMedium.copyWith(color: Colors.white),
        ),
        actions: [
          ElevatedButton.icon(
            onPressed: () => _showAddLessonDialog(context),
            icon: const Icon(Icons.add, size: 20),
            label: const Text('Add Lesson'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.primaryColor,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
          const SizedBox(width: 24),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryColor.withOpacity(0.05),
              Colors.white,
            ],
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? _buildErrorState()
                : _buildContent(),
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
              'Error Loading Content',
              style: AppTheme.headingMedium.copyWith(color: Colors.red.shade700),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Unknown error occurred',
              style: AppTheme.bodyMedium.copyWith(color: Colors.red.shade600),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _fetchLessons,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
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

  Widget _buildContent() {
    if (_groupedLessons.isEmpty) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.school_outlined,
                size: 72,
                color: AppTheme.primaryColor.withOpacity(0.5),
              ),
              const SizedBox(height: 24),
              Text(
                'No Content Yet',
                style: AppTheme.headingLarge.copyWith(
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Start by adding lessons to this week',
                style: AppTheme.bodyLarge.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => _showAddLessonDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Add Your First Lesson'),
                style: AppTheme.primaryButtonStyle,
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWeekHeader(),
          const SizedBox(height: 32),
          ..._groupedLessons.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: _buildSubjectSection(entry.key, entry.value),
            );
          }),
        ],
      ),
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
                  '${_getTotalLessonsCount()} Lessons in ${_groupedLessons.length} Subjects',
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
                        subjectName,
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
                    '${lessons.length} ${lessons.length == 1 ? 'Lesson' : 'Lessons'}',
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






