import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../home_screen.dart';
import '../provider/dashboard_provider.dart';
import '../provider/semesters_provider.dart';
import '../provider/semester_templates_provider.dart';
import '../provider/quiz_answer_provider.dart';
import '../Semesters/semester-page.dart';
import '../Content/Subject_detials_screen.dart';
import '../Content/Semester_Template_Screen.dart';
import '../Semesters/week_content_page.dart';
import '../Quizzes/quiz_answers_list_screen.dart';
import '../Quizzes/quiz_grading_screen.dart';
import '../Models/semester.dart';
import '../Models/semester_template.dart';
import '../Models/Subject_Template.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/students',
    routes: [
      // Main dashboard routes
      GoRoute(
        path: '/students',
        name: 'students',
        builder: (context, state) => const DashboardWrapper(tabIndex: 0),
      ),
      GoRoute(
        path: '/student-requests',
        name: 'student-requests',
        builder: (context, state) => const DashboardWrapper(tabIndex: 1),
      ),
      GoRoute(
        path: '/content-management',
        name: 'content-management',
        builder: (context, state) => const DashboardWrapper(tabIndex: 2),
      ),
      GoRoute(
        path: '/quizzes',
        name: 'quizzes',
        builder: (context, state) => const DashboardWrapper(tabIndex: 3),
      ),
      GoRoute(
        path: '/semesters',
        name: 'semesters',
        builder: (context, state) => const DashboardWrapper(tabIndex: 4),
      ),
      GoRoute(
        path: '/announcements',
        name: 'announcements',
        builder: (context, state) => const DashboardWrapper(tabIndex: 5),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const DashboardWrapper(tabIndex: 6),
      ),
      
      // Nested routes for detailed pages
      GoRoute(
        path: '/semester/:semesterId',
        name: 'semester-detail',
        builder: (context, state) {
          final semesterId = int.parse(state.pathParameters['semesterId']!);
          return SemesterDetailWrapper(semesterId: semesterId);
        },
      ),

      GoRoute(
        path: '/semester-template/:templateId',
        name: 'semester-template',
        builder: (context, state) {
          final templateId = int.parse(state.pathParameters['templateId']!);
          return SemesterTemplateWrapper(templateId: templateId);
        },
      ),

      GoRoute(
        path: '/subject/:subjectId',
        name: 'subject-detail',
        builder: (context, state) {
          final subjectId = int.parse(state.pathParameters['subjectId']!);
          return SubjectDetailWrapper(subjectId: subjectId);
        },
      ),
      
      GoRoute(
        path: '/week/:weekId',
        name: 'week-content',
        builder: (context, state) {
          final weekId = int.parse(state.pathParameters['weekId']!);
          // You'll need to fetch the week data here
          return Scaffold(
            appBar: AppBar(title: Text('Week $weekId')),
            body: Center(child: Text('Week Content Page - ID: $weekId')),
          );
        },
      ),

      GoRoute(
        path: '/quiz/:quizId/answers',
        name: 'quiz-answers',
        builder: (context, state) {
          final quizId = int.parse(state.pathParameters['quizId']!);
          final quizName = state.uri.queryParameters['quizName'] ?? 'Quiz';
          final semesterIdStr = state.uri.queryParameters['semesterId'];
          final semesterId = semesterIdStr != null ? int.tryParse(semesterIdStr) : null;
          return QuizAnswersWrapper(
            quizId: quizId,
            quizName: quizName,
            semesterId: semesterId,
          );
        },
      ),

      GoRoute(
        path: '/quiz-answer/:quizAnswerId',
        name: 'quiz-answer-detail',
        builder: (context, state) {
          final quizAnswerId = int.parse(state.pathParameters['quizAnswerId']!);
          final quizIdStr = state.uri.queryParameters['quizId'];
          final quizId = quizIdStr != null ? int.tryParse(quizIdStr) : 0;
          return QuizAnswerDetailWrapper(
            quizAnswerId: quizAnswerId,
            quizId: quizId ?? 0,
          );
        },
      ),

      // Fallback route
      GoRoute(
        path: '/',
        redirect: (context, state) => '/students',
      ),
    ],
    
    // Error handling
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Page not found: ${state.uri}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/students'),
              child: const Text('Go to Students'),
            ),
          ],
        ),
      ),
    ),
  );
}

// Wrapper widget that sets the correct tab index in the dashboard
class DashboardWrapper extends StatefulWidget {
  final int tabIndex;
  
  const DashboardWrapper({
    Key? key,
    required this.tabIndex,
  }) : super(key: key);

  @override
  State<DashboardWrapper> createState() => _DashboardWrapperState();
}

class _DashboardWrapperState extends State<DashboardWrapper> {
  @override
  void initState() {
    super.initState();
    // Set the tab index after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final provider = Provider.of<DashboardProvider>(context, listen: false);
        provider.setIndex(widget.tabIndex);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const DashboardScreen();
  }
}

// Wrapper for semester detail page that fetches data on refresh
class SemesterDetailWrapper extends StatefulWidget {
  final int semesterId;

  const SemesterDetailWrapper({
    Key? key,
    required this.semesterId,
  }) : super(key: key);

  @override
  State<SemesterDetailWrapper> createState() => _SemesterDetailWrapperState();
}

class _SemesterDetailWrapperState extends State<SemesterDetailWrapper> {
  Semester? semester;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadSemester();
  }

  Future<void> _loadSemester() async {
    try {
      final provider = Provider.of<SemestersProvider>(context, listen: false);
      await provider.fetchSemesters();

      // Find the semester by ID
      final foundSemester = provider.semesters.firstWhere(
        (s) => s.id == widget.semesterId,
        orElse: () => throw Exception('Semester not found'),
      );

      setState(() {
        semester = foundSemester;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Loading Semester...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (error != null) {
      return Scaffold(
        appBar: AppBar(title: Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading semester: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/semesters'),
                child: const Text('Back to Semesters'),
              ),
            ],
          ),
        ),
      );
    }

    return SemesterDetailPage(semester: semester!);
  }
}

// Wrapper for semester template page that fetches data on refresh
class SemesterTemplateWrapper extends StatefulWidget {
  final int templateId;

  const SemesterTemplateWrapper({
    Key? key,
    required this.templateId,
  }) : super(key: key);

  @override
  State<SemesterTemplateWrapper> createState() => _SemesterTemplateWrapperState();
}

class _SemesterTemplateWrapperState extends State<SemesterTemplateWrapper> {
  SemesterTemplate? semesterTemplate;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadSemesterTemplate();
  }

  Future<void> _loadSemesterTemplate() async {
    try {
      final provider = Provider.of<SemestersTemplatesProvider>(context, listen: false);
      await provider.fetchSemesters();

      // Find the semester template by ID
      final foundTemplate = provider.semesters.firstWhere(
        (template) => template.id == widget.templateId,
        orElse: () => throw Exception('Semester template not found'),
      );

      // Set the selected semester in the provider
      provider.setSelectedSemester(foundTemplate);

      setState(() {
        semesterTemplate = foundTemplate;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Loading Semester Template...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (error != null) {
      return Scaffold(
        appBar: AppBar(title: Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading semester template: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/content-management'),
                child: const Text('Back to Content Management'),
              ),
            ],
          ),
        ),
      );
    }

    return SemesterTemplateScreen();
  }
}

// Wrapper for subject detail page that fetches data on refresh
class SubjectDetailWrapper extends StatefulWidget {
  final int subjectId;

  const SubjectDetailWrapper({
    Key? key,
    required this.subjectId,
  }) : super(key: key);

  @override
  State<SubjectDetailWrapper> createState() => _SubjectDetailWrapperState();
}

class _SubjectDetailWrapperState extends State<SubjectDetailWrapper> {
  Subject? subject;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadSubject();
  }

  Future<void> _loadSubject() async {
    try {
      final provider = Provider.of<SemestersTemplatesProvider>(context, listen: false);
      await provider.fetchSemesters();

      // Find the subject by ID across all semester templates
      Subject? foundSubject;
      for (final template in provider.semesters) {
        for (final subject in template.subjects) {
          if (subject.subjectId == widget.subjectId) {
            foundSubject = subject;
            break;
          }
        }
        if (foundSubject != null) break;
      }

      if (foundSubject == null) {
        throw Exception('Subject not found');
      }

      setState(() {
        subject = foundSubject;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Loading Subject...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (error != null) {
      return Scaffold(
        appBar: AppBar(title: Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading subject: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/content-management'),
                child: const Text('Back to Content Management'),
              ),
            ],
          ),
        ),
      );
    }

    return SubjectDetailsScreen(subject: subject!);
  }
}

// Wrapper for quiz answers list screen that fetches data on refresh
class QuizAnswersWrapper extends StatefulWidget {
  final int quizId;
  final String quizName;
  final int? semesterId;

  const QuizAnswersWrapper({
    Key? key,
    required this.quizId,
    required this.quizName,
    this.semesterId,
  }) : super(key: key);

  @override
  State<QuizAnswersWrapper> createState() => _QuizAnswersWrapperState();
}

class _QuizAnswersWrapperState extends State<QuizAnswersWrapper> {
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadQuizAnswers();
  }

  Future<void> _loadQuizAnswers() async {
    try {
      final provider = Provider.of<QuizAnswerProvider>(context, listen: false);
      await provider.fetchQuizAnswersByQuizId(widget.quizId);

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Loading Quiz Answers...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (error != null) {
      return Scaffold(
        appBar: AppBar(title: Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading quiz answers: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/quizzes'),
                child: const Text('Back to Quizzes'),
              ),
            ],
          ),
        ),
      );
    }

    return QuizAnswersListScreen(
      quizId: widget.quizId,
      quizName: widget.quizName,
      semesterId: widget.semesterId,
    );
  }
}

// Wrapper for quiz answer detail screen that fetches data on refresh
class QuizAnswerDetailWrapper extends StatefulWidget {
  final int quizAnswerId;
  final int quizId;

  const QuizAnswerDetailWrapper({
    Key? key,
    required this.quizAnswerId,
    required this.quizId,
  }) : super(key: key);

  @override
  State<QuizAnswerDetailWrapper> createState() => _QuizAnswerDetailWrapperState();
}

class _QuizAnswerDetailWrapperState extends State<QuizAnswerDetailWrapper> {
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadQuizAnswerDetails();
  }

  Future<void> _loadQuizAnswerDetails() async {
    try {
      final provider = Provider.of<QuizAnswerProvider>(context, listen: false);
      await provider.fetchQuizAnswerDetails(widget.quizAnswerId);

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Loading Quiz Answer...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (error != null) {
      return Scaffold(
        appBar: AppBar(title: Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading quiz answer: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/quizzes'),
                child: const Text('Back to Quizzes'),
              ),
            ],
          ),
        ),
      );
    }

    return QuizGradingScreen(
      quizAnswerId: widget.quizAnswerId,
      quizId: widget.quizId,
    );
  }
}
