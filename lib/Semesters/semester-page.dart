// Assuming navigation is set up in your app:
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Models/semester.dart';
import '../Models/week.dart';
import '../Theme.dart';
import 'Content-management_tab.dart';

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
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: semester.weeks.isEmpty
                ? Center(
                    child: Text(
                      'No weeks available for this semester',
                      style: AppTheme.bodyLarge,
                    ),
                  )
                : _buildWeeksList(),
          ),
        ],
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
