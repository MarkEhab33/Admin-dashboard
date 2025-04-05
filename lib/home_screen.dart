import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Theme.dart';

import 'Content/semesters_content_tab.dart';
import 'Semesters/Content-management_tab.dart';
import 'Students/students_tab_screen.dart';
import 'Students/student_requests_tab.dart';
import 'provider/dashboard_provider.dart';
import 'Quizzes/quizzes_tab.dart';

class DashboardScreen extends StatelessWidget {
  final List<Widget> _pages = [
    StudentsSemesterTab(),
    ContentManagementTab(),
    QuizzesTab(),
    SemestersContentTab(),
    StudentRequestsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DashboardProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 1200;

    return Scaffold(
      key: provider.scaffoldKey, // Add this line to manage the drawer state
      drawer: isWideScreen ? null : _buildDrawer(context),
      body: Row(
        children: [
          if (isWideScreen) _buildDrawer(context),
          Expanded(
            child: Column(
              children: [

                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    child: _pages[provider.selectedIndex],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.1),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              "Aripsalin Dashboard",
              style: AppTheme.headingMedium,
            ),
          ),
          _buildDrawerItem(context, Icons.people, 'Students & Semesters', 0),
          _buildDrawerItem(context, Icons.pending_actions, 'Student Requests', 4),
          _buildDrawerItem(context,Icons.import_contacts_sharp,'Semesters',1),
          _buildDrawerItem(context, Icons.quiz, 'Quizzes', 2),
          _buildDrawerItem(context, Icons.subject_outlined, 'Content', 3),
        ],
      ),
    );
  }



  Widget _buildDrawerItem(BuildContext context, IconData icon, String title, int index) {
    final provider = Provider.of<DashboardProvider>(context);
    final isSelected = provider.selectedIndex == index;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: isSelected ? AppTheme.secondaryColor : Colors.transparent,
      ),
      child: ListTile(
        leading: Icon(icon, 
          color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondaryColor),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondaryColor,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: () {
          provider.setIndex(index);
          // Close drawer if on small screen
          if (MediaQuery.of(context).size.width <= 1200) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }

 
}


