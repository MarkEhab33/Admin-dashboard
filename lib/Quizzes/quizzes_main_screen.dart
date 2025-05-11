import 'package:admin_dashboard/Quizzes/grades_tab.dart';
import 'package:admin_dashboard/Quizzes/quizzes_tab.dart';
import 'package:admin_dashboard/Theme.dart';
import 'package:flutter/material.dart';

class QuizzesMainScreen extends StatefulWidget {
  @override
  _QuizzesMainScreenState createState() => _QuizzesMainScreenState();
}

class _QuizzesMainScreenState extends State<QuizzesMainScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title and tabs
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quizzes Management',
                style: AppTheme.headingLarge,
              ),
              SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                child: TabBar(
                  controller: _tabController,
                  tabs: [
                    Tab(
                      icon: Icon(Icons.quiz),
                      text: 'Quizzes',
                    ),
                    Tab(
                      icon: Icon(Icons.grading),
                      text: 'Grades',
                    ),
                  ],
                  labelColor: AppTheme.primaryColor,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
        ),
        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              QuizzesTab(),
              GradesTab(),
            ],
          ),
        ),
      ],
    );
  }
}
