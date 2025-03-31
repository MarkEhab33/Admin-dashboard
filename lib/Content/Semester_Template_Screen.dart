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
        body: Center(child: Text("No semester selected!", style: AppTheme.bodyLarge)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Semester ${semester.semesterNo} Details', 
          style: AppTheme.headingMedium.copyWith(color: Colors.white)),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Text(
              'Subjects List',
              style: AppTheme.headingLarge,
            ),
          ),
          ElevatedButton(
            onPressed: () => _showAddSubjectDialog(context, semesterProvider, semester.id),
            style: AppTheme.primaryButtonStyle,
            child: const Text("Add Subject"),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: semester.subjects.isEmpty
                ? Center(child: Text('No subjects available.', style: AppTheme.bodyLarge))
                : GridView.builder(
                    padding: const EdgeInsets.all(8.0),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 10,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                    ),
                    itemCount: semester.subjects.length,
                    itemBuilder: (context, index) {
                      final subject = semester.subjects[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SubjectDetailsScreen(subject: subject),
                            ),
                          );
                        },
                        child: Container(
                          decoration: AppTheme.cardDecoration.copyWith(
                            color: AppTheme.primaryColor,
                          ),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                subject.subjectName ?? "NA",
                                style: AppTheme.bodyLarge.copyWith(color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
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
      builder: (context) => AlertDialog(
        title: Text("Add Subject", style: AppTheme.headingMedium),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: subjectNameController,
              decoration: AppTheme.inputDecoration("Enter subject name"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: subjectCodeController,
              decoration: AppTheme.inputDecoration("Enter subject code"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(color: AppTheme.primaryColor)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (subjectNameController.text.isNotEmpty && subjectCodeController.text.isNotEmpty) {
                await provider.addSubject(semesterId, subjectNameController.text, subjectCodeController.text);
                Navigator.pop(context);
              }
            },
            style: AppTheme.primaryButtonStyle,
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }
}
