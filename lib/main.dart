import 'package:admin_dashboard/Theme.dart';
import 'package:admin_dashboard/provider/dashboard_provider.dart';
import 'package:admin_dashboard/home_screen.dart';
import 'package:admin_dashboard/provider/grades_provider.dart';
import 'package:admin_dashboard/provider/semester_templates_provider.dart';
import 'package:admin_dashboard/provider/semesters_provider.dart';
import 'package:admin_dashboard/provider/student_provider.dart';
import 'package:admin_dashboard/provider/subject_provider.dart';
import 'package:admin_dashboard/provider/quiz_provider.dart';

import 'package:admin_dashboard/provider/quiz_answer_provider.dart';
import 'package:admin_dashboard/provider/subcategory_provider.dart';
import 'package:admin_dashboard/provider/announcements_provider.dart';
import 'package:admin_dashboard/provider/locale_provider.dart';
import 'package:admin_dashboard/provider/admin_auth_provider.dart';
import 'package:admin_dashboard/l10n/app_localizations.dart';
import 'package:admin_dashboard/screens/splash_screen.dart';
import 'package:admin_dashboard/screens/admin_login_screen.dart';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AdminAuthProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => SemestersProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => StudentsProvider()),
        ChangeNotifierProvider(create: (_) => SemestersTemplatesProvider()),
        ChangeNotifierProvider(create: (_) => LessonProvider()),
        ChangeNotifierProvider(create: (_) => QuizProvider()),
        ChangeNotifierProvider(create: (_) => QuizAnswerProvider()),
        ChangeNotifierProvider(create: (_) => SubcategoryProvider()),
        ChangeNotifierProvider(create: (_) => AnnouncementsProvider()),
        ChangeNotifierProvider(create: (ctx) => GradesProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'لوحة تحكم أريبسالين',
          locale: localeProvider.locale,
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          theme: ThemeData(
            colorScheme: ColorScheme.light(primary: AppTheme.primaryColor),
            scaffoldBackgroundColor: AppTheme.backgroundColor,
            fontFamily: 'NotoKufiArabic',
            appBarTheme: const AppBarTheme(
              backgroundColor: AppTheme.primaryColor,
              elevation: 0,
              centerTitle: false,
              titleTextStyle: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'NotoKufiArabic',
              ),
              iconTheme: IconThemeData(color: Colors.white),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: AppTheme.primaryButtonStyle,
            ),
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          builder: (context, child) {
            return Directionality(
              textDirection: localeProvider.isArabic ? TextDirection.rtl : TextDirection.ltr,
              child: child!,
            );
          },
          home: DashboardScreen(),
        );
      },
    );
  }
}

