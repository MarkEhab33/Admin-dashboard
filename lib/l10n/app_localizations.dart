import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

abstract class AppLocalizations {
  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    delegate,
  ];

  static const List<Locale> supportedLocales = [
    Locale('ar'),
    Locale('en'),
  ];

  // App Title
  String get appTitle;
  String get dashboardTitle;

  // Navigation
  String get studentsAndSemesters;
  String get studentRequests;
  String get semesters;
  String get quizzes;
  String get content;
  String get announcements;
  String get settings;

  // Common
  String get name;
  String get search;
  String get save;
  String get cancel;
  String get delete;
  String get edit;
  String get add;
  String get loading;
  String get error;
  String get success;
  String get confirm;
  String get yes;
  String get no;

  // Students
  String get searchByNameOrCode;
  String get noStudentsFound;
  String get currentSemester;
  String get church;
  String get phoneNumber;
  String get studentDetails;

  // Quizzes
  String get questions;
  String get recordingQuestions;
  String get tasmi3;
  String get createQuiz;
  String get quizDetails;
  String get grades;

  // Semesters
  String get semesterOverview;
  String get subjects;
  String get students;
  String get startDate;
  String get endDate;

  // Settings
  String get language;
  String get arabic;
  String get english;
  String get selectLanguage;

  // Announcements
  String get title;
  String get description;
  String get meetingLink;
  String get createdAt;

  // Subcategories
  String get subcategory;
  String get subcategories;
  String get selectSubcategory;
  String get noSubcategory;
  String get unnamed;

  // Grades
  String get finalGrades;
  String get studentGrades;
  String get quizGrades;

  // Content
  String get semesterDetails;
  String get subjectDetails;
  String get lessons;
  String get materials;

  // Forms
  String get required;
  String get invalidInput;
  String get pleaseEnterValue;
  String get selectOption;

  // Messages
  String get dataLoadedSuccessfully;
  String get errorLoadingData;
  String get noDataAvailable;
  String get operationCompleted;
  String get operationFailed;
  String get notAssigned;

  // Student Grades
  String get academicPerformance;
  String get weeklyQuizzes;
  String get finalQuizzes;
  String get totalScore;
  String get percentage;
  String get grade;
  String get noGradesAvailable;
  String get semester;
  String get overallGrade;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['ar', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    switch (locale.languageCode) {
      case 'ar':
        return AppLocalizationsAr();
      case 'en':
      default:
        return AppLocalizationsEn();
    }
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) => false;
}

class AppLocalizationsAr extends AppLocalizations {
  @override
  String get appTitle => 'لوحة تحكم أريبسالين';

  @override
  String get dashboardTitle => 'لوحة تحكم أريبسالين';

  // Navigation
  @override
  String get studentsAndSemesters => 'الطلاب والفصول الدراسية';

  @override
  String get studentRequests => 'طلبات الطلاب';

  @override
  String get semesters => 'الفصول الدراسية';

  @override
  String get quizzes => 'الاختبارات';

  @override
  String get content => 'المحتوى';

  @override
  String get announcements => 'الإعلانات';

  @override
  String get settings => 'الإعدادات';

  // Common
  @override
  String get name => 'الاسم';

  @override
  String get search => 'بحث';

  @override
  String get save => 'حفظ';

  @override
  String get cancel => 'إلغاء';

  @override
  String get delete => 'حذف';

  @override
  String get edit => 'تعديل';

  @override
  String get add => 'إضافة';

  @override
  String get loading => 'جاري التحميل...';

  @override
  String get error => 'خطأ';

  @override
  String get success => 'نجح';

  @override
  String get confirm => 'تأكيد';

  @override
  String get yes => 'نعم';

  @override
  String get no => 'لا';

  // Students
  @override
  String get searchByNameOrCode => 'البحث بالاسم أو رمز الطالب';

  @override
  String get noStudentsFound => 'لم يتم العثور على طلاب';

  @override
  String get currentSemester => 'الفصل الدراسي الحالي';

  @override
  String get church => 'الكنيسة';

  @override
  String get phoneNumber => 'رقم الهاتف';

  @override
  String get studentDetails => 'تفاصيل الطالب';

  // Quizzes
  @override
  String get questions => 'الأسئلة';

  @override
  String get recordingQuestions => 'أسئلة التسجيل';

  @override
  String get tasmi3 => 'تسميع';

  @override
  String get createQuiz => 'إنشاء اختبار';

  @override
  String get quizDetails => 'تفاصيل الاختبار';

  @override
  String get grades => 'الدرجات';

  // Semesters
  @override
  String get semesterOverview => 'نظرة عامة على الفصل الدراسي';

  @override
  String get subjects => 'المواد';

  @override
  String get students => 'الطلاب';

  @override
  String get startDate => 'تاريخ البداية';

  @override
  String get endDate => 'تاريخ النهاية';

  // Settings
  @override
  String get language => 'اللغة';

  @override
  String get arabic => 'العربية';

  @override
  String get english => 'الإنجليزية';

  @override
  String get selectLanguage => 'اختر اللغة';

  // Announcements
  @override
  String get title => 'العنوان';

  @override
  String get description => 'الوصف';

  @override
  String get meetingLink => 'رابط الاجتماع';

  @override
  String get createdAt => 'تاريخ الإنشاء';

  // Subcategories
  @override
  String get subcategory => 'الفئة الفرعية';

  @override
  String get subcategories => 'الفئات الفرعية';

  @override
  String get selectSubcategory => 'اختر الفئة الفرعية';

  @override
  String get noSubcategory => 'بدون فئة فرعية';

  @override
  String get unnamed => 'بدون اسم';

  // Grades
  @override
  String get finalGrades => 'الدرجات النهائية';

  @override
  String get studentGrades => 'درجات الطالب';

  @override
  String get quizGrades => 'درجات الاختبار';

  // Content
  @override
  String get semesterDetails => 'تفاصيل الفصل الدراسي';

  @override
  String get subjectDetails => 'تفاصيل المادة';

  @override
  String get lessons => 'الدروس';

  @override
  String get materials => 'المواد التعليمية';

  // Forms
  @override
  String get required => 'مطلوب';

  @override
  String get invalidInput => 'إدخال غير صحيح';

  @override
  String get pleaseEnterValue => 'يرجى إدخال قيمة';

  @override
  String get selectOption => 'اختر خيار';

  // Messages
  @override
  String get dataLoadedSuccessfully => 'تم تحميل البيانات بنجاح';

  @override
  String get errorLoadingData => 'خطأ في تحميل البيانات';

  @override
  String get noDataAvailable => 'لا توجد بيانات متاحة';

  @override
  String get operationCompleted => 'تمت العملية بنجاح';

  @override
  String get operationFailed => 'فشلت العملية';

  @override
  String get notAssigned => 'غير مخصص';

  // Student Grades
  @override
  String get academicPerformance => 'الأداء الأكاديمي';

  @override
  String get weeklyQuizzes => 'اختبارات الأسبوع';

  @override
  String get finalQuizzes => 'الاختبارات النهائية';

  @override
  String get totalScore => 'النتيجة الإجمالية';

  @override
  String get percentage => 'النسبة المئوية';

  @override
  String get grade => 'الدرجة';

  @override
  String get noGradesAvailable => 'لا توجد درجات متاحة';

  @override
  String get semester => 'الفصل الدراسي';

  @override
  String get overallGrade => 'الدرجة الإجمالية';
}

class AppLocalizationsEn extends AppLocalizations {
  @override
  String get appTitle => 'Aripsalin Dashboard';

  @override
  String get dashboardTitle => 'Aripsalin Dashboard';

  // Navigation
  @override
  String get studentsAndSemesters => 'Students & Semesters';

  @override
  String get studentRequests => 'Student Requests';

  @override
  String get semesters => 'Semesters';

  @override
  String get quizzes => 'Quizzes';

  @override
  String get content => 'Content';

  @override
  String get announcements => 'Announcements';

  @override
  String get settings => 'Settings';

  // Common
  @override
  String get name => 'Name';

  @override
  String get search => 'Search';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get add => 'Add';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get confirm => 'Confirm';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  // Students
  @override
  String get searchByNameOrCode => 'Search by name or student code';

  @override
  String get noStudentsFound => 'No students found';

  @override
  String get currentSemester => 'Current Semester';

  @override
  String get church => 'Church';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get studentDetails => 'Student Details';

  // Quizzes
  @override
  String get questions => 'Questions';

  @override
  String get recordingQuestions => 'Recording Questions';

  @override
  String get tasmi3 => 'TASMI3';

  @override
  String get createQuiz => 'Create Quiz';

  @override
  String get quizDetails => 'Quiz Details';

  @override
  String get grades => 'Grades';

  // Semesters
  @override
  String get semesterOverview => 'Semester Overview';

  @override
  String get subjects => 'Subjects';

  @override
  String get students => 'Students';

  @override
  String get startDate => 'Start Date';

  @override
  String get endDate => 'End Date';

  // Settings
  @override
  String get language => 'Language';

  @override
  String get arabic => 'Arabic';

  @override
  String get english => 'English';

  @override
  String get selectLanguage => 'Select Language';

  // Announcements
  @override
  String get title => 'Title';

  @override
  String get description => 'Description';

  @override
  String get meetingLink => 'Meeting Link';

  @override
  String get createdAt => 'Created At';

  // Subcategories
  @override
  String get subcategory => 'Subcategory';

  @override
  String get subcategories => 'Subcategories';

  @override
  String get selectSubcategory => 'Select Subcategory';

  @override
  String get noSubcategory => 'No Subcategory';

  @override
  String get unnamed => 'Unnamed';

  // Grades
  @override
  String get finalGrades => 'Final Grades';

  @override
  String get studentGrades => 'Student Grades';

  @override
  String get quizGrades => 'Quiz Grades';

  // Content
  @override
  String get semesterDetails => 'Semester Details';

  @override
  String get subjectDetails => 'Subject Details';

  @override
  String get lessons => 'Lessons';

  @override
  String get materials => 'Materials';

  // Forms
  @override
  String get required => 'Required';

  @override
  String get invalidInput => 'Invalid Input';

  @override
  String get pleaseEnterValue => 'Please enter a value';

  @override
  String get selectOption => 'Select Option';

  // Messages
  @override
  String get dataLoadedSuccessfully => 'Data loaded successfully';

  @override
  String get errorLoadingData => 'Error loading data';

  @override
  String get noDataAvailable => 'No data available';

  @override
  String get operationCompleted => 'Operation completed successfully';

  @override
  String get operationFailed => 'Operation failed';

  @override
  String get notAssigned => 'Not Assigned';

  // Student Grades
  @override
  String get academicPerformance => 'Academic Performance';

  @override
  String get weeklyQuizzes => 'Weekly Quizzes';

  @override
  String get finalQuizzes => 'Final Quizzes';

  @override
  String get totalScore => 'Total Score';

  @override
  String get percentage => 'Percentage';

  @override
  String get grade => 'Grade';

  @override
  String get noGradesAvailable => 'No grades available';

  @override
  String get semester => 'Semester';

  @override
  String get overallGrade => 'Overall Grade';
}
