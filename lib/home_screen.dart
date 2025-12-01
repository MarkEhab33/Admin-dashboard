import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'Theme.dart';
import 'l10n/app_localizations.dart';


import 'Content/semesters_content_tab.dart';
import 'Semesters/Content-management_tab.dart';
import 'Students/students_tab_screen.dart';
import 'Students/student_requests_tab.dart';
import 'Quizzes/quizzes_main_screen.dart';
import 'provider/dashboard_provider.dart';
import 'provider/admin_auth_provider.dart';
import 'Quizzes/quizzes_tab.dart';
import 'Announcements/announcements_tab.dart';
import 'Settings/settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final List<Widget> _pages = [
    StudentsSemesterTab(),
    StudentRequestsTab(),
    ContentManagementTab(),
    QuizzesMainScreen(),
    SemestersContentTab(),
    AnnouncementsTab(),
    SettingsScreen(),
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
                    child: _pages[provider.selectedIndex >= 0 && provider.selectedIndex < _pages.length
                        ? provider.selectedIndex
                        : 0],
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
    final localizations = AppLocalizations.of(context)!;

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withAlpha(25),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          // Admin Info Header
          Consumer<AdminAuthProvider>(
            builder: (context, authProvider, child) {
              print('=== HOME SCREEN ADMIN DATA ===');
              print('Admin name: ${authProvider.adminName}');
              print('Admin username: ${authProvider.adminUsername}');
              print('Admin role: ${authProvider.adminRole}');
              print('Full admin data: ${authProvider.adminData}');

              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.05),
                  border: Border(
                    bottom: BorderSide(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppTheme.primaryColor,
                      child: Icon(
                        Icons.admin_panel_settings,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      authProvider.adminName ?? 'Aripsalin Administrator',
                      style: AppTheme.headingMedium.copyWith(
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      authProvider.adminUsername ?? 'admin',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textSecondaryColor,
                        fontSize: 12,
                      ),
                    ),
                    if (authProvider.adminRole != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          authProvider.adminRole!.replaceAll('_', ' ').toUpperCase(),
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'SUPER ADMIN',
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),

          // Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildDrawerItem(context, Icons.people, localizations.studentsAndSemesters, 0),
                _buildDrawerItem(context, Icons.pending_actions, localizations.studentRequests, 1),
                _buildDrawerItem(context, Icons.import_contacts_sharp, localizations.semesters, 2),
                _buildDrawerItem(context, Icons.quiz, localizations.quizzes, 3),
                _buildDrawerItem(context, Icons.subject_outlined, localizations.content, 4),
                _buildDrawerItem(context, Icons.campaign_rounded, localizations.announcements, 5),
                _buildDrawerItem(context, Icons.settings, localizations.settings, 6),
              ],
            ),
          ),

          // Logout Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                ),
              ),
            ),
            child: Consumer<AdminAuthProvider>(
              builder: (context, authProvider, child) {
                return ListTile(
                  leading: Icon(
                    Icons.logout,
                    color: Colors.red.shade600,
                  ),
                  title: Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.red.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () async {
                    // Show confirmation dialog
                    final shouldLogout = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Confirm Logout'),
                        content: const Text('Are you sure you want to logout?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Logout'),
                          ),
                        ],
                      ),
                    );

                    if (shouldLogout == true) {
                      await authProvider.logout();
                    }
                  },
                );
              },
            ),
          ),
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
          // Map index to route
          final routes = [
            '/students',           // 0
            '/student-requests',   // 1
            '/content-management', // 2
            '/quizzes',           // 3
            '/semesters',         // 4
            '/announcements',     // 5
            '/settings',          // 6
          ];

          if (index < routes.length) {
            context.go(routes[index]);
          }

          // Close drawer if on small screen
          if (MediaQuery.of(context).size.width <= 1200) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }


}


