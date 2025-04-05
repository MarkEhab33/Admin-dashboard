// Assuming navigation is set up in your app:
import 'package:admin_dashboard/Models/student.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Models/semester.dart';
import '../Models/week.dart';
import '../Theme.dart';


class SemesterDetailPage extends StatelessWidget {
  final Semester semester;

  SemesterDetailPage({required this.semester});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(semester.name),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Weeks Section (70% of width)
                  Expanded(
                    flex: 7,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Weeks',
                          style: AppTheme.headingMedium,
                        ),
                        const SizedBox(height: 16),
                        Container(
                          decoration: AppTheme.cardDecoration,
                          child: semester.weeks.isEmpty
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(24.0),
                                    child: Text(
                                      'No weeks available for this semester',
                                      style: AppTheme.bodyLarge,
                                    ),
                                  ),
                                )
                              : _buildWeeksList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  // Students Section (30% of width)
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Students',
                              style: AppTheme.headingMedium,
                            ),
                            ElevatedButton.icon(
                              onPressed: () => _showAddStudentDialog(context),
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('Add Student'),
                              style: AppTheme.primaryButtonStyle,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          decoration: AppTheme.cardDecoration,
                          child: _buildStudentsList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Logic to add a new week
        },
        child: Icon(Icons.add),
        backgroundColor: AppTheme.secondaryColor,
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Semester Overview',
            style: AppTheme.headingLarge,
          ),
          SizedBox(height: 20),
          Row(
            children: [
              _buildInfoCard(
                'Subjects',
                '${semester.semesterTemplate.subjects.length}',
                Icons.book,
              ),
              SizedBox(width: 16),
              _buildInfoCard(
                'Students',
                '${semester.students.length}',
                Icons.people,
              ),
              SizedBox(width: 16),
              _buildInfoCard(
                'Start Date',
                _formatDate(semester.startDate),
                Icons.calendar_today,
              ),
              SizedBox(width: 16),
              _buildInfoCard(
                'End Date',
                _formatDate(semester.endDate),
                Icons.event,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.primaryColor.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: AppTheme.primaryColor),
                SizedBox(width: 8),
                Text(
                  title,
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              value,
              style: AppTheme.headingMedium.copyWith(
                color: AppTheme.textPrimaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeksList() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: semester.weeks.length,
      itemBuilder: (context, index) {
        final week = semester.weeks[index];
        return Card(
          margin: EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.all(16),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '${week.weekNo}',
                  style: AppTheme.headingMedium.copyWith(
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ),
            title: Text(
              'Week ${week.weekNo}',
              style: AppTheme.headingMedium,
            ),
            subtitle: Text(
              '${_formatDate(week.startDate)} - ${_formatDate(week.endDate)}',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
            ),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => WeekContentPage(week: week),
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    try {
      return DateFormat('MMM d, y').format(date);
    } catch (e) {
      return 'Invalid date';
    }
  }

  Widget _buildStudentsList() {
    if (semester.students.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Text(
            'No students enrolled in this semester',
            style: AppTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: semester.students.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final student = semester.students[index];
        // Safe way to get initials
        final initials = student.user.name.isNotEmpty 
            ? student.user.name.characters.first.toUpperCase()
            : '?';
            
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: AppTheme.primaryColor,
            child: Text(
              initials,
              style: TextStyle(color: Colors.white),
            ),
          ),
          title: Text(student.user.name),
          subtitle: Text(student.studentCode),
          trailing: IconButton(
            icon: Icon(Icons.remove_circle_outline, color: Colors.red),
            onPressed: () => _showRemoveStudentDialog(context, student),
          ),
        );
      },
    );
  }

  void _showAddStudentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Student to Semester'),
        content: Container(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'Search students',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  // Implement search functionality
                },
              ),
              const SizedBox(height: 16),
              Container(
                height: 300,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: ListView.builder(
                  itemCount: 0, // Replace with filtered students list
                  itemBuilder: (context, index) {
                    return ListTile(
                      // Build student item
                      onTap: () {
                        // Add student to semester
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showRemoveStudentDialog(BuildContext context, Student student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove Student'),
        content: Text(
          'Are you sure you want to remove ${student.user.name} from this semester?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Implement remove student logic
              Navigator.pop(context);
            },
            child: Text(
              'Remove',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

class WeekContentPage extends StatelessWidget {
  final Week week;

  WeekContentPage({required this.week});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Content for Week ${week.weekNo}'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Center(
        child: Text('Week content management goes here'),
      ),
    );
  }
}
