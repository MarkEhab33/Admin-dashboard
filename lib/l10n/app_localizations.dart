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
  String get studentApprovedSuccessfully;
  String get studentDeclinedSuccessfully;
  String get confirmApproval;
  String get confirmDecline;
  String get approveStudentConfirmation;
  String get declineStudentConfirmation;
  String get approve;
  String get decline;
  String get pendingVerification;
  String get academicInformation;
  String get academicYear;
  String get currentSemesterName;
  String get personalInformation;
  String get dateOfBirth;
  String get emailAddress;
  String get phoneContact;
  String get studentAddress;
  String get viewTazkia;
  String get viewIdFront;
  String get viewIdBack;
  String get additionalInformation;
  String get studentQualifications;
  String get churchService;
  String get deaconLevel;
  String get verifiedStatus;
  String get pendingApproval;
  String get studentName;
  String get studentId;
  String get notAvailable;
  String get pendingRequests;
  String get noPendingRequestsFound;
  String get studentDetailsColon;

  // Quizzes
  String get questions;
  String get recordingQuestions;
  String get tasmi3;
  String get createQuiz;
  String get createTasmi3;
  String get quizDetails;
  String get grades;
  String get type;
  String get attempts;
  String get timeLimit;
  String get format;
  String get audioRecording;
  String get audioRecordingAssessment;
  String get audioRecordingQuestion;
  String get noTimeLimit;
  String get noTimeLimitForRecording;
  String get maxDuration;
  String get maxDurationSeconds;
  String get addRedo;
  String get viewSubmissions;
  String get selectStudentForRedo;
  String get addingRedo;
  String get selectSemester;
  String get noSemestersAvailable;
  String get noStudentsFoundInSemester;
  String get errorLoadingStudents;
  String get errorLoadingSemesters;
  String get errorAddingRedo;
  String get redoAddedSuccessfully;
  String get allQuizzes;
  String get regularQuizzes;
  String get recordingQuizzesTasmi3;
  String get quizType;
  String get answerOptions;
  String get correctAnswer;
  String get correct;
  String get audio;
  String get points;
  String get min;
  String get seconds;

  // Semesters
  String get semesterOverview;
  String get subjects;
  String get subject;
  String get students;
  String get startDate;
  String get endDate;
  String get semestersManagement;
  String get addNewSemester;
  String get selectTemplate;
  String get selectSemesterTemplate;
  String get semesterNumber;
  String get pleaseSelectStartDateFirst;
  String get pleaseFillAllFields;
  String get semesterCreatedSuccessfully;
  String get create;
  String get allYears;
  String get semesterName;
  String get current;
  String get noSemestersFoundForSelectedYear;
  String get weeks;
  String get week;
  String get addWeek;
  String get noWeeksAvailableForSemester;
  String get addStudent;
  String get noStudentsEnrolledInSemester;
  String get viewGrades;
  String get removeStudent;
  String get addStudentToSemester;
  String get searchStudents;
  String get noStudentsFoundInSearch;
  String get studentAddedSuccessfully;
  String get removeStudentTitle;
  String get removeStudentConfirmation;
  String get remove;
  String get studentRemovedSuccessfully;
  String get addNewWeek;
  String get weekNumber;
  String get weekAddedSuccessfully;
  String get failedToAddWeek;
  String get editWeek;
  String get weekUpdatedSuccessfully;
  String get failedToUpdateWeek;
  String get update;
  String get invalidDate;

  // Week Content
  String get uncategorized;
  String get deleteLesson;
  String get deleteLessonConfirmation;
  String get lessonSuccessfullyRemovedFromWeek;
  String get addLessonToWeek;
  String get noSubjectsFound;
  String get unnamedSubject;
  String get noLessonsAvailable;
  String get lessonAddedSuccessfully;
  String get weekQuizzes;
  String get noQuizzesAssignedToWeek;
  String get untitledQuiz;
  String get noSubject;
  String get unknown;
  String get removeQuiz;
  String get removeQuizConfirmation;
  String get quizRemovedSuccessfully;
  String get errorLoadingContent;
  String get unknownErrorOccurred;
  String get tryAgain;
  String get weekLessons;
  String get addLesson;
  String get noLessonsAssignedToWeek;
  String get singleLesson;
  String get multipleLessons;
  String get singleItem;
  String get multipleItems;

  // Content Management
  String get subjectsManagement;
  String get manageAndOrganizeSubjects;
  String get noSubjectsAvailable;
  String get startByAddingFirstSubject;
  String get subcategories;
  String get manageCourseContent;
  String get addLessonButton;
  String get noLessonsYet;
  String get startByAddingFirstLesson;
  String get selectLessonToViewContent;
  String get mediaContent;
  String get quizzesTab;
  String get noQuizzesForLesson;
  String get createQuizToTestKnowledge;
  String get deleteQuizTitle;
  String get deleteQuizConfirmation;
  String get quizDeletedSuccessfully;
  String get noMediaContentYet;
  String get videoType;
  String get pdfType;
  String get audioType;
  String get addMedia;
  String get subjectInformation;
  String get subjectName;
  String get subjectCode;
  String get close;
  String get enterLessonName;
  String get addButton;
  String get addPdf;
  String get pdfTitle;
  String get enterPdfTitle;
  String get noFileSelected;
  String get choosePdf;
  String get upload;
  String get addAudio;
  String get audioTitle;
  String get enterAudioTitle;
  String get chooseAudio;
  String get pleaseEnterTitle;
  String get audioUploadedSuccessfully;
  String get addVideoUrl;
  String get videoTitle;
  String get enterVideoTitle;
  String get enterVideoUrl;
  String get videoAddedSuccessfully;
  String get errorAddingVideo;
  String get deleteMediaConfirmation;
  String get actionCannotBeUndone;

  String get addNewSemesterTemplate;
  String get addSemester;

  String get enterSemesterNumber;

  // Admin Login Screen
  String get aripsalinAdminDashboard;
  String get signInToAccessAdminPanel;
  String get username;
  String get enterYourUsername;
  String get pleaseEnterUsername;
  String get password;
  String get enterYourPassword;
  String get pleaseEnterPassword;
  String get rememberMe;
  String get signingIn;
  String get signIn;
  String get aripsalinAdminDashboardVersion;

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

  @override
  String get studentApprovedSuccessfully => 'تم قبول الطالب بنجاح';

  @override
  String get studentDeclinedSuccessfully => 'تم رفض الطالب بنجاح';

  @override
  String get confirmApproval => 'تأكيد القبول';

  @override
  String get confirmDecline => 'تأكيد الرفض';

  @override
  String get approveStudentConfirmation => 'هل أنت متأكد من أنك تريد قبول طلب هذا الطالب؟';

  @override
  String get declineStudentConfirmation => 'هل أنت متأكد من أنك تريد رفض طلب هذا الطالب؟ لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get approve => 'قبول';

  @override
  String get decline => 'رفض';

  @override
  String get pendingVerification => 'في انتظار التحقق';

  @override
  String get academicInformation => 'المعلومات الأكاديمية';

  @override
  String get academicYear => 'السنة الدراسية';

  @override
  String get currentSemesterName => 'الفصل الدراسي';

  @override
  String get personalInformation => 'المعلومات الشخصية';

  @override
  String get dateOfBirth => 'تاريخ الميلاد';

  @override
  String get emailAddress => 'البريد الإلكتروني';

  @override
  String get phoneContact => 'الهاتف';

  @override
  String get studentAddress => 'العنوان';

  @override
  String get viewTazkia => 'عرض التزكية';

  @override
  String get viewIdFront => 'عرض الهوية الأمامية';

  @override
  String get viewIdBack => 'عرض الهوية الخلفية';

  @override
  String get additionalInformation => 'معلومات إضافية';

  @override
  String get studentQualifications => 'المؤهلات';

  @override
  String get churchService => 'خدمة الكنيسة';

  @override
  String get deaconLevel => 'درجة الشماسية';

  @override
  String get verifiedStatus => 'تم التحقق';

  @override
  String get pendingApproval => 'في انتظار الموافقة';

  @override
  String get studentName => 'الاسم';

  @override
  String get studentId => 'الرقم التعريفي';

  @override
  String get notAvailable => 'غير متوفر';

  @override
  String get pendingRequests => 'الطلبات المعلقة';

  @override
  String get noPendingRequestsFound => 'لم يتم العثور على طلبات معلقة';

  @override
  String get studentDetailsColon => 'تفاصيل الطالب:';

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
  String get createTasmi3 => 'إنشاء تسميع';

  @override
  String get quizDetails => 'تفاصيل الاختبار';

  @override
  String get grades => 'الدرجات';

  @override
  String get type => 'النوع';

  @override
  String get attempts => 'المحاولات';

  @override
  String get timeLimit => 'الحد الزمني';

  @override
  String get format => 'التنسيق';

  @override
  String get audioRecording => 'تسجيل صوتي';

  @override
  String get audioRecordingAssessment => 'تقييم التسجيل الصوتي';

  @override
  String get audioRecordingQuestion => 'سؤال التسجيل الصوتي';

  @override
  String get noTimeLimit => 'بدون حد زمني';

  @override
  String get noTimeLimitForRecording => 'بدون حد زمني للتسجيل';

  @override
  String get maxDuration => 'المدة القصوى';

  @override
  String get maxDurationSeconds => 'المدة القصوى: {duration} ثانية';

  @override
  String get addRedo => 'إضافة إعادة';

  @override
  String get viewSubmissions => 'عرض الإجابات';

  @override
  String get selectStudentForRedo => 'اختر طالب للإعادة';

  @override
  String get addingRedo => 'جاري إضافة الإعادة لـ {studentName}...';

  @override
  String get selectSemester => 'اختر الفصل الدراسي';

  @override
  String get noSemestersAvailable => 'لا توجد فصول دراسية متاحة';

  @override
  String get noStudentsFoundInSemester => 'لم يتم العثور على طلاب في هذا الفصل';

  @override
  String get errorLoadingStudents => 'خطأ في تحميل الطلاب: {error}';

  @override
  String get errorLoadingSemesters => 'خطأ في تحميل الفصول الدراسية: {error}';

  @override
  String get errorAddingRedo => 'خطأ في إضافة الإعادة: {error}';

  @override
  String get redoAddedSuccessfully => 'تم إضافة الإعادة بنجاح';

  @override
  String get allQuizzes => 'جميع الاختبارات';

  @override
  String get regularQuizzes => 'الاختبارات العادية';

  @override
  String get recordingQuizzesTasmi3 => 'اختبارات التسجيل (تسميع)';

  @override
  String get quizType => 'نوع الاختبار';

  @override
  String get answerOptions => 'خيارات الإجابة';

  @override
  String get correctAnswer => 'الإجابة الصحيحة';

  @override
  String get correct => 'صحيح';

  @override
  String get audio => 'صوتي';

  @override
  String get points => 'نقاط';

  @override
  String get min => 'دقيقة';

  @override
  String get seconds => 'ثانية';

  // Semesters
  @override
  String get semesterOverview => 'نظرة عامة على الفصل الدراسي';

  @override
  String get subjects => 'المواد';

  @override
  String get subject => 'مادة';

  @override
  String get students => 'الطلاب';

  @override
  String get startDate => 'تاريخ البداية';

  @override
  String get endDate => 'تاريخ النهاية';

  @override
  String get semestersManagement => 'إدارة الفصول الدراسية';

  @override
  String get addNewSemester => 'إضافة فصل دراسي جديد';

  @override
  String get selectTemplate => 'اختر القالب';

  @override
  String get selectSemesterTemplate => 'اختر قالب الفصل الدراسي';

  @override
  String get semesterNumber => 'الفصل الدراسي';

  @override
  String get pleaseSelectStartDateFirst => 'يرجى اختيار تاريخ البداية أولاً';

  @override
  String get pleaseFillAllFields => 'يرجى ملء جميع الحقول';

  @override
  String get semesterCreatedSuccessfully => 'تم إنشاء الفصل الدراسي بنجاح';

  @override
  String get create => 'إنشاء';

  @override
  String get allYears => 'جميع السنوات';

  @override
  String get semesterName => 'اسم الفصل الدراسي';

  @override
  String get current => 'الحالي';

  @override
  String get noSemestersFoundForSelectedYear => 'لم يتم العثور على فصول دراسية للسنة المحددة';

  @override
  String get weeks => 'الأسابيع';

  @override
  String get week => 'أسبوع';

  @override
  String get addWeek => 'إضافة أسبوع';

  @override
  String get noWeeksAvailableForSemester => 'لا توجد أسابيع متاحة لهذا الفصل الدراسي';

  @override
  String get addStudent => 'إضافة طالب';

  @override
  String get noStudentsEnrolledInSemester => 'لا يوجد طلاب مسجلون في هذا الفصل الدراسي';

  @override
  String get viewGrades => 'عرض الدرجات';

  @override
  String get removeStudent => 'إزالة الطالب';

  @override
  String get addStudentToSemester => 'إضافة طالب إلى الفصل الدراسي';

  @override
  String get searchStudents => 'البحث عن الطلاب';

  @override
  String get noStudentsFoundInSearch => 'لم يتم العثور على طلاب';

  @override
  String get studentAddedSuccessfully => 'تم إضافة الطالب بنجاح';

  @override
  String get removeStudentTitle => 'إزالة الطالب';

  @override
  String get removeStudentConfirmation => 'هل أنت متأكد من أنك تريد إزالة هذا الطالب من الفصل الدراسي؟';

  @override
  String get remove => 'إزالة';

  @override
  String get studentRemovedSuccessfully => 'تم إزالة الطالب بنجاح';

  @override
  String get addNewWeek => 'إضافة أسبوع جديد';

  @override
  String get weekNumber => 'رقم الأسبوع';

  @override
  String get weekAddedSuccessfully => 'تم إضافة الأسبوع بنجاح';

  @override
  String get failedToAddWeek => 'فشل في إضافة الأسبوع';

  @override
  String get editWeek => 'تعديل الأسبوع';

  @override
  String get weekUpdatedSuccessfully => 'تم تحديث الأسبوع بنجاح';

  @override
  String get failedToUpdateWeek => 'فشل في تحديث الأسبوع';

  @override
  String get update => 'تحديث';

  @override
  String get invalidDate => 'تاريخ غير صحيح';

  // Week Content
  @override
  String get uncategorized => 'غير مصنف';

  @override
  String get deleteLesson => 'حذف الدرس';

  @override
  String get deleteLessonConfirmation => 'هل أنت متأكد من أنك تريد إزالة هذا الدرس من الأسبوع؟';

  @override
  String get lessonSuccessfullyRemovedFromWeek => 'تم إزالة الدرس من الأسبوع بنجاح';

  @override
  String get addLessonToWeek => 'إضافة درس إلى الأسبوع';

  @override
  String get noSubjectsFound => 'لم يتم العثور على مواد';

  @override
  String get unnamedSubject => 'مادة بدون اسم';

  @override
  String get noLessonsAvailable => 'لا توجد دروس متاحة';

  @override
  String get lessonAddedSuccessfully => 'تم إضافة الدرس بنجاح';

  @override
  String get weekQuizzes => 'اختبارات الأسبوع';

  @override
  String get noQuizzesAssignedToWeek => 'لا توجد اختبارات مخصصة لهذا الأسبوع';

  @override
  String get untitledQuiz => 'اختبار بدون عنوان';

  @override
  String get noSubject => 'بدون مادة';

  @override
  String get unknown => 'غير معروف';

  @override
  String get removeQuiz => 'إزالة الاختبار';

  @override
  String get removeQuizConfirmation => 'هل أنت متأكد من أنك تريد إزالة هذا الاختبار من الأسبوع؟';

  @override
  String get quizRemovedSuccessfully => 'تم إزالة الاختبار بنجاح';

  @override
  String get errorLoadingContent => 'خطأ في تحميل المحتوى';

  @override
  String get unknownErrorOccurred => 'حدث خطأ غير معروف';

  @override
  String get tryAgain => 'حاول مرة أخرى';

  @override
  String get weekLessons => 'دروس الأسبوع';

  @override
  String get addLesson => 'إضافة درس';

  @override
  String get noLessonsAssignedToWeek => 'لا توجد دروس مخصصة لهذا الأسبوع';

  @override
  String get singleLesson => 'درس';

  @override
  String get multipleLessons => 'دروس';

  @override
  String get singleItem => 'عنصر';

  @override
  String get multipleItems => 'عناصر';

  // Content Management
  @override
  String get subjectsManagement => 'إدارة المواد';

  @override
  String get manageAndOrganizeSubjects => 'إدارة وتنظيم مواد هذا الفصل الدراسي';

  @override
  String get noSubjectsAvailable => 'لا توجد مواد متاحة';

  @override
  String get startByAddingFirstSubject => 'ابدأ بإضافة مادتك الأولى';

  @override
  String get manageCourseContent => 'إدارة محتوى المقرر';

  @override
  String get addLessonButton => 'إضافة درس';

  @override
  String get noLessonsYet => 'لا توجد دروس بعد';

  @override
  String get startByAddingFirstLesson => 'ابدأ بإضافة درسك الأول';

  @override
  String get selectLessonToViewContent => 'اختر درساً لعرض المحتوى';

  @override
  String get mediaContent => 'المحتوى الإعلامي';

  @override
  String get quizzesTab => 'الاختبارات';

  @override
  String get noQuizzesForLesson => 'لا توجد اختبارات لهذا الدرس';

  @override
  String get createQuizToTestKnowledge => 'أنشئ اختباراً لاختبار معرفة الطلاب';

  @override
  String get deleteQuizTitle => 'حذف الاختبار';

  @override
  String get deleteQuizConfirmation => 'هل أنت متأكد من أنك تريد حذف "{0}"؟';

  @override
  String get quizDeletedSuccessfully => 'تم حذف الاختبار بنجاح';

  @override
  String get noMediaContentYet => 'لا يوجد محتوى إعلامي بعد';

  @override
  String get videoType => 'فيديو';

  @override
  String get pdfType => 'PDF';

  @override
  String get audioType => 'صوت';

  @override
  String get addMedia => 'إضافة وسائط';

  @override
  String get subjectInformation => 'معلومات المادة';

  @override
  String get subjectCode => 'رمز المادة';

  @override
  String get close => 'إغلاق';

  @override
  String get enterLessonName => 'أدخل اسم الدرس';

  @override
  String get addButton => 'إضافة';

  @override
  String get subjectName => 'اسم المادة';

  @override
  String get addPdf => 'إضافة PDF';

  @override
  String get pdfTitle => 'عنوان PDF';

  @override
  String get enterPdfTitle => 'أدخل عنوان PDF';

  @override
  String get noFileSelected => 'لم يتم اختيار ملف';

  @override
  String get choosePdf => 'اختر PDF';

  @override
  String get upload => 'رفع';

  @override
  String get addAudio => 'إضافة صوت';

  @override
  String get audioTitle => 'عنوان الصوت';

  @override
  String get enterAudioTitle => 'أدخل عنوان الصوت';

  @override
  String get chooseAudio => 'اختر صوت';

  @override
  String get pleaseEnterTitle => 'يرجى إدخال عنوان';

  @override
  String get audioUploadedSuccessfully => 'تم رفع الصوت بنجاح';

  @override
  String get addVideoUrl => 'إضافة رابط فيديو';

  @override
  String get videoTitle => 'عنوان الفيديو';

  @override
  String get enterVideoTitle => 'أدخل عنوان الفيديو';

  @override
  String get enterVideoUrl => 'أدخل رابط الفيديو';

  @override
  String get videoAddedSuccessfully => 'تم إضافة الفيديو بنجاح';

  @override
  String get errorAddingVideo => 'خطأ في إضافة الفيديو';

  @override
  String get deleteMediaConfirmation => 'هل أنت متأكد من أنك تريد حذف "{0}"؟';

  @override
  String get actionCannotBeUndone => 'لا يمكن التراجع عن هذا الإجراء';

  @override
  String get addNewSemesterTemplate => 'إضافة قالب فصل دراسي جديد';

  @override
  String get addSemester => 'إضافة فصل دراسي';

  @override
  String get enterSemesterNumber => 'أدخل رقم الفصل الدراسي';

  // Admin Login Screen
  @override
  String get aripsalinAdminDashboard => 'لوحة تحكم أريبسالين الإدارية';

  @override
  String get signInToAccessAdminPanel => 'سجل الدخول للوصول إلى لوحة الإدارة';

  @override
  String get username => 'اسم المستخدم';

  @override
  String get enterYourUsername => 'أدخل اسم المستخدم';

  @override
  String get pleaseEnterUsername => 'يرجى إدخال اسم المستخدم';

  @override
  String get password => 'كلمة المرور';

  @override
  String get enterYourPassword => 'أدخل كلمة المرور';

  @override
  String get pleaseEnterPassword => 'يرجى إدخال كلمة المرور';

  @override
  String get rememberMe => 'تذكرني';

  @override
  String get signingIn => 'جاري تسجيل الدخول...';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get aripsalinAdminDashboardVersion => 'لوحة تحكم أريبسالين الإدارية الإصدار 1.0';

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

  @override
  String get studentApprovedSuccessfully => 'Student approved successfully';

  @override
  String get studentDeclinedSuccessfully => 'Student declined successfully';

  @override
  String get confirmApproval => 'Confirm Approval';

  @override
  String get confirmDecline => 'Confirm Decline';

  @override
  String get approveStudentConfirmation => 'Are you sure you want to approve this student request?';

  @override
  String get declineStudentConfirmation => 'Are you sure you want to decline this student request? This action cannot be undone.';

  @override
  String get approve => 'Approve';

  @override
  String get decline => 'Decline';

  @override
  String get pendingVerification => 'Pending Verification';

  @override
  String get academicInformation => 'Academic Information';

  @override
  String get academicYear => 'Year';

  @override
  String get currentSemesterName => 'Semester';

  @override
  String get personalInformation => 'Personal Information';

  @override
  String get dateOfBirth => 'Date of Birth';

  @override
  String get emailAddress => 'Email';

  @override
  String get phoneContact => 'Phone';

  @override
  String get studentAddress => 'Address';

  @override
  String get viewTazkia => 'View Tazkia';

  @override
  String get viewIdFront => 'View ID Front';

  @override
  String get viewIdBack => 'View ID Back';

  @override
  String get additionalInformation => 'Additional Information';

  @override
  String get studentQualifications => 'Qualifications';

  @override
  String get churchService => 'Church Service';

  @override
  String get deaconLevel => 'Deacon Level';

  @override
  String get verifiedStatus => 'Verified';

  @override
  String get pendingApproval => 'Pending Approval';

  @override
  String get studentName => 'Name';

  @override
  String get studentId => 'ID';

  @override
  String get notAvailable => 'N/A';

  @override
  String get pendingRequests => 'Pending Requests';

  @override
  String get noPendingRequestsFound => 'No pending requests found';

  @override
  String get studentDetailsColon => 'Student Details:';

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

  @override
  String get createTasmi3 => 'Create Tasmi3';

  @override
  String get type => 'Type';

  @override
  String get attempts => 'Attempts';

  @override
  String get timeLimit => 'Time Limit';

  @override
  String get format => 'Format';

  @override
  String get audioRecording => 'Audio Recording';

  @override
  String get audioRecordingAssessment => 'Audio Recording Assessment';

  @override
  String get audioRecordingQuestion => 'Audio Recording Question';

  @override
  String get noTimeLimit => 'No Time Limit';

  @override
  String get noTimeLimitForRecording => 'No time limit for recording';

  @override
  String get maxDuration => 'Max Duration';

  @override
  String get maxDurationSeconds => 'Max Duration: {duration} seconds';

  @override
  String get addRedo => 'Add Redo';

  @override
  String get viewSubmissions => 'View Submissions';

  @override
  String get selectStudentForRedo => 'Select Student for Redo';

  @override
  String get addingRedo => 'Adding redo for {studentName}...';

  @override
  String get selectSemester => 'Select Semester';

  @override
  String get noSemestersAvailable => 'No semesters available';

  @override
  String get noStudentsFoundInSemester => 'No students found in this semester';

  @override
  String get errorLoadingStudents => 'Error loading students: {error}';

  @override
  String get errorLoadingSemesters => 'Error loading semesters: {error}';

  @override
  String get errorAddingRedo => 'Error adding redo: {error}';

  @override
  String get redoAddedSuccessfully => 'Redo added successfully';

  @override
  String get allQuizzes => 'All Quizzes';

  @override
  String get regularQuizzes => 'Regular Quizzes';

  @override
  String get recordingQuizzesTasmi3 => 'Recording Quizzes (Tasmi3)';

  @override
  String get quizType => 'Quiz Type';

  @override
  String get answerOptions => 'Answer Options';

  @override
  String get correctAnswer => 'Correct Answer';

  @override
  String get correct => 'CORRECT';

  @override
  String get audio => 'AUDIO';

  @override
  String get points => 'points';

  @override
  String get min => 'min';

  @override
  String get seconds => 'seconds';

  // Semesters
  @override
  String get semesterOverview => 'Semester Overview';

  @override
  String get subjects => 'Subjects';

  @override
  String get subject => 'Subject';

  @override
  String get students => 'Students';

  @override
  String get startDate => 'Start Date';

  @override
  String get endDate => 'End Date';

  @override
  String get semestersManagement => 'Semesters Management';

  @override
  String get addNewSemester => 'Add New Semester';

  @override
  String get selectTemplate => 'Select Template';

  @override
  String get selectSemesterTemplate => 'Select a semester template';

  @override
  String get semesterNumber => 'Semester';

  @override
  String get pleaseSelectStartDateFirst => 'Please select start date first';

  @override
  String get pleaseFillAllFields => 'Please fill all fields';

  @override
  String get semesterCreatedSuccessfully => 'Semester created successfully';

  @override
  String get create => 'Create';

  @override
  String get allYears => 'All Years';

  @override
  String get semesterName => 'Semester Name';

  @override
  String get current => 'Current';

  @override
  String get noSemestersFoundForSelectedYear => 'No semesters found for the selected year';

  @override
  String get weeks => 'Weeks';

  @override
  String get week => 'Week';

  @override
  String get addWeek => 'Add Week';

  @override
  String get noWeeksAvailableForSemester => 'No weeks available for this semester';

  @override
  String get addStudent => 'Add Student';

  @override
  String get noStudentsEnrolledInSemester => 'No students enrolled in this semester';

  @override
  String get viewGrades => 'View Grades';

  @override
  String get removeStudent => 'Remove Student';

  @override
  String get addStudentToSemester => 'Add Student to Semester';

  @override
  String get searchStudents => 'Search students';

  @override
  String get noStudentsFoundInSearch => 'No students found';

  @override
  String get studentAddedSuccessfully => 'Student added successfully';

  @override
  String get removeStudentTitle => 'Remove Student';

  @override
  String get removeStudentConfirmation => 'Are you sure you want to remove this student from the semester?';

  @override
  String get remove => 'Remove';

  @override
  String get studentRemovedSuccessfully => 'Student removed successfully';

  @override
  String get addNewWeek => 'Add New Week';

  @override
  String get weekNumber => 'Week Number';

  @override
  String get weekAddedSuccessfully => 'Week added successfully';

  @override
  String get failedToAddWeek => 'Failed to add week';

  @override
  String get editWeek => 'Edit Week';

  @override
  String get weekUpdatedSuccessfully => 'Week updated successfully';

  @override
  String get failedToUpdateWeek => 'Failed to update week';

  @override
  String get update => 'Update';

  @override
  String get invalidDate => 'Invalid date';

  // Week Content
  @override
  String get uncategorized => 'Uncategorized';

  @override
  String get deleteLesson => 'Delete Lesson';

  @override
  String get deleteLessonConfirmation => 'Are you sure you want to remove this lesson from the week?';

  @override
  String get lessonSuccessfullyRemovedFromWeek => 'Lesson successfully removed from week';

  @override
  String get addLessonToWeek => 'Add Lesson to Week';

  @override
  String get noSubjectsFound => 'No subjects found';

  @override
  String get unnamedSubject => 'Unnamed Subject';

  @override
  String get noLessonsAvailable => 'No lessons available';

  @override
  String get lessonAddedSuccessfully => 'Lesson added successfully';

  @override
  String get weekQuizzes => 'Week Quizzes';

  @override
  String get noQuizzesAssignedToWeek => 'No quizzes assigned to this week';

  @override
  String get untitledQuiz => 'Untitled Quiz';

  @override
  String get noSubject => 'No Subject';

  @override
  String get unknown => 'Unknown';

  @override
  String get removeQuiz => 'Remove Quiz';

  @override
  String get removeQuizConfirmation => 'Are you sure you want to remove this quiz from the week?';

  @override
  String get quizRemovedSuccessfully => 'Quiz removed successfully';

  @override
  String get errorLoadingContent => 'Error Loading Content';

  @override
  String get unknownErrorOccurred => 'Unknown error occurred';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get weekLessons => 'Week Lessons';

  @override
  String get addLesson => 'Add Lesson';

  @override
  String get noLessonsAssignedToWeek => 'No lessons assigned to this week';

  @override
  String get singleLesson => 'Lesson';

  @override
  String get multipleLessons => 'Lessons';

  @override
  String get singleItem => 'item';

  @override
  String get multipleItems => 'items';

  // Content Management
  @override
  String get subjectsManagement => 'Subjects Management';

  @override
  String get manageAndOrganizeSubjects => 'Manage and organize subjects for this semester';

  @override
  String get noSubjectsAvailable => 'No subjects available';

  @override
  String get startByAddingFirstSubject => 'Start by adding your first subject';

  @override
  String get manageCourseContent => 'Manage your course content';

  @override
  String get addLessonButton => 'Add Lesson';

  @override
  String get noLessonsYet => 'No lessons yet';

  @override
  String get startByAddingFirstLesson => 'Start by adding your first lesson';

  @override
  String get selectLessonToViewContent => 'Select a lesson to view content';

  @override
  String get mediaContent => 'Media Content';

  @override
  String get quizzesTab => 'Quizzes';

  @override
  String get noQuizzesForLesson => 'No quizzes for this lesson';

  @override
  String get createQuizToTestKnowledge => 'Create a quiz to test student knowledge';

  @override
  String get deleteQuizTitle => 'Delete Quiz';

  @override
  String get deleteQuizConfirmation => 'Are you sure you want to delete "{0}"?';

  @override
  String get quizDeletedSuccessfully => 'Quiz deleted successfully';

  @override
  String get noMediaContentYet => 'No media content yet';

  @override
  String get videoType => 'Video';

  @override
  String get pdfType => 'PDF';

  @override
  String get audioType => 'Audio';

  @override
  String get addMedia => 'Add Media';

  @override
  String get subjectInformation => 'Subject Information';

  @override
  String get subjectName => 'Subject Name';

  @override
  String get subjectCode => 'Subject Code';

  @override
  String get close => 'Close';

  @override
  String get enterLessonName => 'Enter lesson name';

  @override
  String get addButton => 'Add';

  @override
  String get addPdf => 'Add PDF';

  @override
  String get pdfTitle => 'PDF Title';

  @override
  String get enterPdfTitle => 'Enter PDF title';

  @override
  String get noFileSelected => 'No file selected';

  @override
  String get choosePdf => 'Choose PDF';

  @override
  String get upload => 'Upload';

  @override
  String get addAudio => 'Add Audio';

  @override
  String get audioTitle => 'Audio Title';

  @override
  String get enterAudioTitle => 'Enter audio title';

  @override
  String get chooseAudio => 'Choose Audio';

  @override
  String get pleaseEnterTitle => 'Please enter a title';

  @override
  String get audioUploadedSuccessfully => 'Audio uploaded successfully';

  @override
  String get addVideoUrl => 'Add Video URL';

  @override
  String get videoTitle => 'Video Title';

  @override
  String get enterVideoTitle => 'Enter video title';

  @override
  String get enterVideoUrl => 'Enter video URL';

  @override
  String get videoAddedSuccessfully => 'Video added successfully';

  @override
  String get errorAddingVideo => 'Error adding video';

  @override
  String get deleteMediaConfirmation => 'Are you sure you want to delete "{0}"?';

  @override
  String get actionCannotBeUndone => 'This action cannot be undone';

  @override
  String get addNewSemesterTemplate => 'Add New Semester Template';

  @override
  String get addSemester => 'Add Semester';

  @override
  String get enterSemesterNumber => 'Enter Semester Number';

  // Admin Login Screen
  @override
  String get aripsalinAdminDashboard => 'Aripsalin Admin Dashboard';

  @override
  String get signInToAccessAdminPanel => 'Sign in to access the admin panel';

  @override
  String get username => 'Username';

  @override
  String get enterYourUsername => 'Enter your username';

  @override
  String get pleaseEnterUsername => 'Please enter your username';

  @override
  String get password => 'Password';

  @override
  String get enterYourPassword => 'Enter your password';

  @override
  String get pleaseEnterPassword => 'Please enter your password';

  @override
  String get rememberMe => 'Remember me';

  @override
  String get signingIn => 'Signing in...';

  @override
  String get signIn => 'Sign In';

  @override
  String get aripsalinAdminDashboardVersion => 'Aripsalin Admin Dashboard v1.0';

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
