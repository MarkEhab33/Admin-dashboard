import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/semester_templates_provider.dart';
import '../Theme.dart';
import 'Semester_Template_Screen.dart';

class SemestersContentTab extends StatefulWidget {
  const SemestersContentTab({super.key});

  @override
  State<SemestersContentTab> createState() => _SemestersContentTabState();
}

class _SemestersContentTabState extends State<SemestersContentTab> {
  final TextEditingController semesterController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SemestersTemplatesProvider>(context, listen: false).fetchSemesters();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Semesters', style: AppTheme.headingMedium.copyWith(color: Colors.white)),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Center(
              child: Text(
                'Add New Semester Template',
                style: AppTheme.headingMedium,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: showAddSemesterDialog,
              style: AppTheme.primaryButtonStyle,
              child: const Text('Add Semester'),
            ),
          ),
          Expanded(
            child: Consumer<SemestersTemplatesProvider>(
              builder: (context, semestersProvider, _) {
                final semesters = semestersProvider.semesters;
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  itemCount: semesters.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 25),
                      child: Container(
                        decoration: AppTheme.cardDecoration,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                          title: Text(
                            'Semester ${semesters[index].semesterNo}',
                            style: AppTheme.bodyLarge,
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: AppTheme.textSecondaryColor),
                            onPressed: () => semestersProvider.removeSemester(index),
                          ),
                          onTap: () {
                            semestersProvider.setSelectedSemester(semesters[index]);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SemesterTemplateScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void showAddSemesterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New Semester', style: AppTheme.headingMedium),
          content: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: TextField(
              controller: semesterController,
              decoration: AppTheme.inputDecoration('Enter Semester Number'),
              keyboardType: TextInputType.number,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: TextStyle(color: AppTheme.primaryColor)),
            ),
            ElevatedButton(
              onPressed: () {
                addSemester();
                Navigator.of(context).pop();
              },
              style: AppTheme.primaryButtonStyle,
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void addSemester() {
    final semesterNumber = semesterController.text;
    if (semesterNumber.isNotEmpty) {
      Provider.of<SemestersTemplatesProvider>(context, listen: false)
          .addSemester(int.parse(semesterNumber));
      semesterController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a semester number.', style: AppTheme.bodyMedium.copyWith(color: Colors.white)),
          backgroundColor: AppTheme.primaryColor,
        ),
      );
    }
  }
}
