import 'package:flutter/material.dart';
import '../Models/simple_student.dart';
import '../Theme.dart';

class SimpleStudentSelectionDialog extends StatefulWidget {
  final List<SimpleStudent> students;
  final String title;

  const SimpleStudentSelectionDialog({
    Key? key,
    required this.students,
    this.title = 'Select Student',
  }) : super(key: key);

  @override
  _SimpleStudentSelectionDialogState createState() => _SimpleStudentSelectionDialogState();
}

class _SimpleStudentSelectionDialogState extends State<SimpleStudentSelectionDialog> {
  SimpleStudent? selectedStudent;
  String searchQuery = '';
  List<SimpleStudent> filteredStudents = [];

  @override
  void initState() {
    super.initState();
    filteredStudents = widget.students;
  }

  void _filterStudents(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredStudents = widget.students;
      } else {
        filteredStudents = widget.students.where((student) {
          final name = student.name.toLowerCase();
          final code = student.code.toLowerCase();
          final searchLower = query.toLowerCase();
          
          return name.contains(searchLower) || code.contains(searchLower);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: AppTheme.headingMedium,
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            SizedBox(height: 16),
            
            // Search field
            TextField(
              decoration: InputDecoration(
                hintText: 'Search by name or code...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: AppTheme.surfaceColor,
              ),
              onChanged: _filterStudents,
            ),
            SizedBox(height: 16),
            
            // Students count
            Text(
              '${filteredStudents.length} student(s) found',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
            ),
            SizedBox(height: 16),
            
            // Students list
            Expanded(
              child: filteredStudents.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_search,
                            size: 64,
                            color: AppTheme.textSecondaryColor,
                          ),
                          SizedBox(height: 16),
                          Text(
                            searchQuery.isEmpty 
                                ? 'No students available'
                                : 'No students found matching "$searchQuery"',
                            style: AppTheme.bodyLarge.copyWith(
                              color: AppTheme.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredStudents.length,
                      itemBuilder: (context, index) {
                        final student = filteredStudents[index];
                        final isSelected = selectedStudent?.id == student.id;
                        
                        return Card(
                          margin: EdgeInsets.only(bottom: 8),
                          color: isSelected 
                              ? AppTheme.primaryColor.withValues(alpha: 0.1)
                              : null,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppTheme.primaryColor,
                              child: Text(
                                student.name.isNotEmpty 
                                    ? student.name[0].toUpperCase()
                                    : 'S',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              student.name.isNotEmpty 
                                  ? student.name 
                                  : 'Student ${student.id}',
                              style: AppTheme.bodyLarge.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: isSelected 
                                    ? AppTheme.primaryColor 
                                    : AppTheme.textPrimaryColor,
                              ),
                            ),
                            subtitle: Text(
                              'Student Code: ${student.code}',
                              style: AppTheme.bodyMedium.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: isSelected
                                ? Icon(
                                    Icons.check_circle,
                                    color: AppTheme.primaryColor,
                                  )
                                : null,
                            onTap: () {
                              setState(() {
                                selectedStudent = student;
                              });
                            },
                          ),
                        );
                      },
                    ),
            ),
            
            SizedBox(height: 16),
            
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancel'),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: selectedStudent != null
                      ? () => Navigator.of(context).pop(selectedStudent)
                      : null,
                  style: AppTheme.primaryButtonStyle,
                  child: Text('Select'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
