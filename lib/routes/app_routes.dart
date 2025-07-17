import 'package:flutter/material.dart';
import '../home_screen.dart';
import '../Students/students_tab_screen.dart';
import '../Students/student_requests_tab.dart';
import '../Content/semesters_content_tab.dart';
import '../Semesters/Content-management_tab.dart';
import '../Quizzes/quizzes_main_screen.dart';
import '../Announcements/announcements_tab.dart';
import '../Settings/settings_screen.dart';

class AppRoutes {
  // Route names
  static const String dashboard = '/';
  static const String students = '/students';
  static const String studentRequests = '/student-requests';
  static const String contentManagement = '/content-management';
  static const String quizzes = '/quizzes';
  static const String semesters = '/semesters';
  static const String announcements = '/announcements';
  static const String settings = '/settings';

  // Route to tab index mapping
  static const Map<String, int> routeToIndex = {
    dashboard: 0,
    students: 0,
    studentRequests: 1,
    contentManagement: 2,
    quizzes: 3,
    semesters: 4,
    announcements: 5,
    settings: 6,
  };

  // Index to route mapping
  static const Map<int, String> indexToRoute = {
    0: students,
    1: studentRequests,
    2: contentManagement,
    3: quizzes,
    4: semesters,
    5: announcements,
    6: settings,
  };

  // Route names for display
  static const Map<String, String> routeNames = {
    students: 'Students',
    studentRequests: 'Student Requests',
    contentManagement: 'Content Management',
    quizzes: 'Quizzes',
    semesters: 'Semesters',
    announcements: 'Announcements',
    settings: 'Settings',
  };

  // Generate routes
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case dashboard:
      case students:
      case studentRequests:
      case contentManagement:
      case quizzes:
      case semesters:
      case announcements:
      case settings:
        return MaterialPageRoute(
          builder: (_) => DashboardScreen(initialRoute: settings.name ?? dashboard),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => DashboardScreen(initialRoute: dashboard),
          settings: const RouteSettings(name: dashboard),
        );
    }
  }

  // Get tab index from route
  static int getTabIndex(String route) {
    return routeToIndex[route] ?? 0;
  }

  // Get route from tab index
  static String getRoute(int index) {
    return indexToRoute[index] ?? students;
  }

  // Check if route is valid
  static bool isValidRoute(String route) {
    return routeToIndex.containsKey(route);
  }
}
