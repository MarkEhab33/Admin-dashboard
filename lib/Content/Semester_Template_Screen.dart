import 'package:admin_dashboard/Models/Subject_Template.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/semester_templates_provider.dart';
import '../Theme.dart';
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
            _buildHeader(semester),
            const SizedBox(height: 20),
            Expanded(
              child: semester.subjects.isEmpty
                  ? _buildEmptyState()
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


  Widget _buildHeader(SemesterTemplate semester) {
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
                    'Subjects Management',
                    style: AppTheme.headingLarge.copyWith(
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manage and organize subjects for this semester',
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.library_books_outlined,
            size: 64,
            color: AppTheme.primaryColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No subjects available',
            style: AppTheme.headingMedium.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start by adding your first subject',
            style: AppTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectsGrid(SemesterTemplate semester) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GridView.builder(
        padding: const EdgeInsets.only(bottom: 80),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          crossAxisSpacing: 12.0,  // Reduced from 20.0
          mainAxisSpacing: 12.0,   // Reduced from 20.0
          childAspectRatio: 1.0,   // Reduced from 1.3 to make cards more compact
        ),
        itemCount: semester.subjects.length,
        itemBuilder: (context, index) {
          final subject = semester.subjects[index];
          return _buildSubjectCard(context, subject);
        },
      ),
    );
  }

  Widget _buildSubjectCard(BuildContext context, Subject subject) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),  // Reduced from 16
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(

              builder: (context) => SubjectDetailsScreen(subject: subject),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),  // Reduced from 16
        child: Container(
          padding: const EdgeInsets.all(16),  // Reduced from 20
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primaryColor,
                Color(0xFF1a2940),
              ],
            ),
            borderRadius: BorderRadius.circular(12),  // Reduced from 16
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.2),
                blurRadius: 8,  // Reduced from 10
                offset: const Offset(0, 3),  // Reduced from Offset(0, 4)
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),  // Reduced from 12
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.book,
                  color: Colors.white,
                  size: 28,  // Reduced from 32
                ),
              ),
              const SizedBox(height: 12),  // Reduced from 16
              Text(
                subject.subjectName ?? "NA",
                style: AppTheme.bodyLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,  // Added to make text slightly smaller
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),  // Reduced from 8
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),  // Reduced padding
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  subject.code ?? "",
                  style: AppTheme.bodyMedium.copyWith(
                    color: Colors.white70,
                    fontSize: 12,  // Added to make text slightly smaller
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
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
                        await provider.addSubject(
                          semesterId,
                          subjectNameController.text,
                          subjectCodeController.text,
                        );
                        Navigator.pop(context);
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
}
