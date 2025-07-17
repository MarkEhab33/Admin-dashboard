import 'package:admin_dashboard/Models/Subject_Template.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/semester_templates_provider.dart';
import '../Theme.dart';
import '../l10n/app_localizations.dart';
import '../Models/semester_template.dart';
import 'Subject_detials_screen.dart';

class SemesterTemplateScreen extends StatelessWidget {
  const SemesterTemplateScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final semesterProvider = Provider.of<SemestersTemplatesProvider>(context);
    final SemesterTemplate? semester = semesterProvider.selectedSemester;

    if (semester == null) {
      return Scaffold(
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
          child: Center(
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
                  "No semester selected!",
                  style: AppTheme.headingMedium.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'Semester ${semester.semesterNo} Details',
          style: AppTheme.headingMedium.copyWith(color: Colors.white),
        ),
        backgroundColor: AppTheme.primaryColor,

      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF8FAFF), // Light blue-ish white
              Colors.white,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, semester),
            const SizedBox(height: 20),
            Expanded(
              child: semester.subjects.isEmpty
                  ? _buildEmptyState(context)
                  : _buildSubjectsGrid(semester),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSubjectDialog(context, semesterProvider, semester.id),
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.add),
        label: const Text("Add Subject"),
      ),
    );
  }


  Widget _buildHeader(BuildContext context, SemesterTemplate semester) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.school,
                color: AppTheme.primaryColor,
                size: 32,
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.subjectsManagement,
                    style: AppTheme.headingLarge.copyWith(
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppLocalizations.of(context)!.manageAndOrganizeSubjects,
                    style: AppTheme.bodyMedium,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.library_books_outlined,
                size: 40,
                color: AppTheme.primaryColor.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)!.noSubjectsAvailable,
              style: AppTheme.headingMedium.copyWith(
                color: AppTheme.textSecondaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context)!.startByAddingFirstSubject,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondaryColor.withValues(alpha: 0.8),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectsGrid(SemesterTemplate semester) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Responsive grid based on screen width
          int crossAxisCount;
          if (constraints.maxWidth > 1400) {
            crossAxisCount = 8;
          } else if (constraints.maxWidth > 1200) {
            crossAxisCount = 7;
          } else if (constraints.maxWidth > 1000) {
            crossAxisCount = 6;
          } else if (constraints.maxWidth > 800) {
            crossAxisCount = 5;
          } else if (constraints.maxWidth > 600) {
            crossAxisCount = 4;
          } else {
            crossAxisCount = 3;
          }

          // Sort subjects by name before displaying
          final sortedSubjects = List<Subject>.from(semester.subjects)
            ..sort((a, b) => (a.subjectName ?? '').toLowerCase().compareTo((b.subjectName ?? '').toLowerCase()));

          return GridView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              childAspectRatio: 0.9,  // Slightly taller for better proportions
            ),
            itemCount: sortedSubjects.length,
            itemBuilder: (context, index) {
              final subject = sortedSubjects[index];
              return _buildSubjectCard(context, subject);
            },
          );
        },
      ),
    );
  }

  Widget _buildSubjectCard(BuildContext context, Subject subject) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SubjectDetailsScreen(subject: subject),
                ),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.primaryColor.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon container with modern design
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.book_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Subject name with better typography
                  Text(
                    subject.subjectName ?? "NA",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Subject code with modern badge design
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      subject.code ?? "",
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Edit button with modern design
          Positioned(
            top: 6,
            right: 6,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.edit_outlined,
                  color: Colors.white,
                  size: 14,
                ),
                onPressed: () => _showEditSubjectDialog(context, subject),
                tooltip: 'Edit Subject',
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(
                  minWidth: 28,
                  minHeight: 28,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddSubjectDialog(BuildContext context, SemestersTemplatesProvider provider, int semesterId) {
    final TextEditingController subjectNameController = TextEditingController();
    final TextEditingController subjectCodeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.library_add_outlined,
                    color: AppTheme.primaryColor,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Add New Subject",
                    style: AppTheme.headingMedium.copyWith(
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: subjectNameController,
                decoration: AppTheme.inputDecoration("Subject Name")
                    .copyWith(prefixIcon: const Icon(Icons.book_outlined)),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: subjectCodeController,
                decoration: AppTheme.inputDecoration("Subject Code")
                    .copyWith(prefixIcon: const Icon(Icons.code)),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "Cancel",
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () async {
                      if (subjectNameController.text.isNotEmpty &&
                          subjectCodeController.text.isNotEmpty) {
                        final navigator = Navigator.of(context);
                        await provider.addSubject(
                          semesterId,
                          subjectNameController.text,
                          subjectCodeController.text,
                        );
                        navigator.pop();
                      }
                    },
                    style: AppTheme.primaryButtonStyle,
                    child: const Text("Add Subject"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditSubjectDialog(BuildContext context, Subject subject) {
    final TextEditingController subjectNameController = TextEditingController(text: subject.subjectName ?? '');
    final TextEditingController subjectCodeController = TextEditingController(text: subject.code ?? '');
    final provider = Provider.of<SemestersTemplatesProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.edit_outlined,
                    color: AppTheme.primaryColor,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Edit Subject",
                    style: AppTheme.headingMedium.copyWith(
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: subjectNameController,
                decoration: AppTheme.inputDecoration("Subject Name")
                    .copyWith(prefixIcon: const Icon(Icons.book_outlined)),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: subjectCodeController,
                decoration: AppTheme.inputDecoration("Subject Code")
                    .copyWith(prefixIcon: const Icon(Icons.code)),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "Cancel",
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () async {
                      if (subjectNameController.text.isNotEmpty &&
                          subjectCodeController.text.isNotEmpty) {
                        final navigator = Navigator.of(context);
                        final scaffoldMessenger = ScaffoldMessenger.of(context);

                        try {
                          await provider.updateSubject(
                            subjectId: subject.subjectId!,
                            name: subjectNameController.text,
                            code: subjectCodeController.text,
                          );
                          navigator.pop();

                          if (context.mounted) {
                            scaffoldMessenger.showSnackBar(
                              SnackBar(
                                content: Text('Subject updated successfully'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e) {
                          navigator.pop();
                          if (context.mounted) {
                            scaffoldMessenger.showSnackBar(
                              SnackBar(
                                content: Text('Error updating subject: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      }
                    },
                    style: AppTheme.primaryButtonStyle,
                    child: const Text("Update Subject"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
