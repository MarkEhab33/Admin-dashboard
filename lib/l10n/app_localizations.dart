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
  String get viewQualifications;
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

  // Quiz Creation
  String get createRecordQuiz;
  String get basicInformation;
  String get recordQuizName;
  String get totalGrade;
  String get numberOfAttempts;
  String get recordingQuestion;
  String get addQuestion;
  String get editRecordingQuestion;
  String get question;
  String get maxDurationSecondsOptional;
  String get studentsWillRecordAudio;
  String get weekLabel;
  String get finalLabel;
  String get lessonLabel;
  String get editQuiz;
  String get createNewQuiz;
  String get quizInformation;
  String get quizName;
  String get questionRequirements;
  String get easyQuestions;
  String get mediumQuestions;
  String get hardQuestions;
  String get easyQuestionsDescription;
  String get mediumQuestionsDescription;
  String get hardQuestionsDescription;
  String get questionsProgress;
  String get addQuestionsToMeetRequirements;
  String get addEasy;
  String get addMedium;
  String get addHard;
  String get currentTotal;
  String get noQuestionsAddedYet;
  String get addQuestionsUsingButtonsAbove;
  String get questionType;
  String get option;
  String get addOption;
  String get correctAnswerOptional;
  String get totalGradePoints;
  String get creatingQuiz;
  String get updatingQuiz;
  String get quizCreatedSuccessfully;
  String get quizUpdatedSuccessfully;
  String get errorCreatingQuiz;
  String get errorUpdatingQuiz;
  String get pleaseAddRequiredQuestions;
  String get mustBeNonNegative;
  String get invalidNumber;

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
  String get trySearchingWithDifferentTerm;
  String get allMatchingStudentsAlreadyEnrolled;
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
  String get editLesson;
  String get editLessonTitle;
  String get lessonUpdatedSuccessfully;
  String get editLessonItem;
  String get editLessonItemTitle;
  String get lessonItemUpdatedSuccessfully;
  String get enterItemTitle;
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

  // Subject Delete
  String get deleteSubject;
  String get deleteSubjectTitle;
  String get deleteSubjectConfirmation;
  String get subjectDeletedSuccessfully;
  String get cannotDeleteSubjectWithContent;
  String get subjectContainsContent;
  String get deleteContentFirst;
  String get errorDeletingSubject;

  // Quiz Answer Delete
  String get deleteQuizAnswer;
  String get deleteQuizAnswerTitle;
  String get deleteQuizAnswerConfirmation;
  String get quizAnswerDeletedSuccessfully;
  String get errorDeletingQuizAnswer;

  // Search
  String get searchByStudentName;

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

  // Password Reset
  String get resetPassword;
  String get resetPasswordTitle;
  String get resetPasswordDescription;
  String get newPassword;
  String get confirmNewPassword;
  String get enterNewPassword;
  String get confirmPassword;
  String get passwordsDoNotMatch;
  String get passwordResetSuccess;
  String get passwordResetFailed;
  String get passwordResetInProgress;

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

  // Coptic Keyboard
  String get copticKeyboard;
  String get showCopticKeyboard;
  String get hideCopticKeyboard;

  // CSV Download
  String get downloadStudentData;
  String get downloadSemesterStudents;
  String get email;
  String get phone;
  String get address;
  String get verificationStatus;
  String get registrationDate;
  String get verified;
  String get pending;
  String get semesterLabel;
  String get subjectLabel;
  String get gradeLabel;
  String get noData;
  String get studentDataDownloadedSuccessfully;
  String get failedToDownloadStudentData;
  String get semesterStudentsDownloadedSuccessfully;
  String get failedToDownloadSemesterStudents;
  
  // Image Download
  String get downloadImage;
  String get downloadProfilePicture;
  String get downloadTazkia;
  String get downloadIdFront;
  String get downloadIdBack;
  String get downloadQualifications;
  String get imageDownloadedSuccessfully;
  String get failedToDownloadImage;

  // Student Edit
  String get editStudent;
  String get editStudentProfile;
  String get updateProfile;
  String get updatingProfile;
  String get profileUpdatedSuccessfully;
  String get failedToUpdateProfile;
  String get uploadNewDocument;
  String get uploadProfilePicture;
  String get uploadIdFront;
  String get uploadIdBack;
  String get uploadTazkia;
  String get uploadQualifications;
  String get selectFile;
  String get uploading;
  String get nationality;
  String get gender;
  String get male;
  String get female;
  String get abEle3traf;
  String get city;

  // Bulk Grading
  String get addBulkGrades;
  String get bulkGradeInfo;
  String get bulkGradeDescription;
  String get quiz;
  String get gradesToAdd;
  String get enterGradesToAdd;
  String get gradeRangeHelper;
  String get bulkGradeNote;
  String get bulkGradeNegativeNote;
  String get addGrades;
  String get gradeCannotBeZero;
  String get gradeMustBeBetweenRange;
  String get semesterIdRequired;
  String get bulkGradeSuccess;
  String get studentsUpdated;
  String get gradesAdded;
  String get updatedStudentsList;
  String get ok;

  // Manual Grade Override
  String get manualGradeOverride;
  String get manualGradeEntry;
  String get manualGradeDescription;
  String get enterGrade;
  String get maxGrade;
  String get saveGrade;
  String get pleaseEnterGrade;
  String get invalidGradeFormat;
  String get gradeCannotBeNegative;
  String get gradeCannotExceedMax;
  String get gradeUpdatedSuccessfully;
  String get failedToUpdateGrade;
  String get errorUpdatingGrade;

  // Quick Grade (Direct Grade Entry)
  String get quickGrade;
  String get quickGradeDescription;
  String get quickGradeNote;
  String get currentGrade;
  String get autoGraded;
  String get manuallyGraded;
  String get calculateFromAnswers;
  String get calculateFromAnswersDescription;

  // Quiz Answer Comments
  String get comment;
  String get addComment;
  String get editComment;
  String get saveComment;
  String get commentPlaceholder;
  String get commentSavedSuccessfully;
  String get failedToSaveComment;
  String get noComment;
  String get instructorComment;
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
  String get viewQualifications => 'عرض المؤهلات';

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
  String get trySearchingWithDifferentTerm => 'جرب البحث بمصطلح مختلف';

  @override
  String get allMatchingStudentsAlreadyEnrolled => 'جميع الطلاب المطابقين مسجلون بالفعل في هذا الفصل الدراسي';

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
  String get editLesson => 'تعديل الدرس';

  @override
  String get editLessonTitle => 'تعديل الدرس';

  @override
  String get lessonUpdatedSuccessfully => 'تم تحديث الدرس بنجاح';

  @override
  String get editLessonItem => 'تعديل عنصر الدرس';

  @override
  String get editLessonItemTitle => 'تعديل عنصر الدرس';

  @override
  String get lessonItemUpdatedSuccessfully => 'تم تحديث عنصر الدرس بنجاح';

  @override
  String get enterItemTitle => 'أدخل عنوان العنصر';

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

  // Subject Delete
  @override
  String get deleteSubject => 'حذف المادة';

  @override
  String get deleteSubjectTitle => 'حذف المادة';

  @override
  String get deleteSubjectConfirmation => 'هل أنت متأكد من أنك تريد حذف هذه المادة؟ لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get subjectDeletedSuccessfully => 'تم حذف المادة بنجاح';

  @override
  String get cannotDeleteSubjectWithContent => 'لا يمكن حذف المادة التي تحتوي على محتوى';

  @override
  String get subjectContainsContent => 'تحتوي هذه المادة على دروس أو اختبارات. يجب حذف جميع المحتويات أولاً.';

  @override
  String get deleteContentFirst => 'احذف جميع الدروس والاختبارات أولاً';

  @override
  String get errorDeletingSubject => 'خطأ في حذف المادة';

  // Quiz Answer Delete
  @override
  String get deleteQuizAnswer => 'حذف إجابة الاختبار';

  @override
  String get deleteQuizAnswerTitle => 'حذف إجابة الاختبار';

  @override
  String get deleteQuizAnswerConfirmation => 'هل أنت متأكد من أنك تريد حذف إجابة هذا الطالب؟ لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get quizAnswerDeletedSuccessfully => 'تم حذف إجابة الاختبار بنجاح';

  @override
  String get errorDeletingQuizAnswer => 'خطأ في حذف إجابة الاختبار';

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

  // Password Reset
  @override
  String get resetPassword => 'إعادة تعيين كلمة المرور';

  @override
  String get resetPasswordTitle => 'إعادة تعيين كلمة المرور';

  @override
  String get resetPasswordDescription => 'أدخل كلمة مرور جديدة للمستخدم';

  @override
  String get newPassword => 'كلمة المرور الجديدة';

  @override
  String get confirmNewPassword => 'تأكيد كلمة المرور الجديدة';

  @override
  String get enterNewPassword => 'أدخل كلمة المرور الجديدة';

  @override
  String get confirmPassword => 'تأكيد كلمة المرور';

  @override
  String get passwordsDoNotMatch => 'كلمات المرور غير متطابقة';

  @override
  String get passwordResetSuccess => 'تم إعادة تعيين كلمة المرور بنجاح';

  @override
  String get passwordResetFailed => 'فشل في إعادة تعيين كلمة المرور';

  @override
  String get passwordResetInProgress => 'جاري إعادة تعيين كلمة المرور...';

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

  // Coptic Keyboard
  @override
  String get copticKeyboard => 'لوحة المفاتيح القبطية';

  @override
  String get showCopticKeyboard => 'إظهار لوحة المفاتيح القبطية';

  @override
  String get hideCopticKeyboard => 'إخفاء لوحة المفاتيح القبطية';

  // CSV Download
  @override
  String get downloadStudentData => 'تحميل بيانات الطالب';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get phone => 'الهاتف';

  @override
  String get address => 'العنوان';

  @override
  String get verificationStatus => 'حالة التحقق';

  @override
  String get registrationDate => 'تاريخ التسجيل';

  @override
  String get verified => 'محقق';

  @override
  String get pending => 'في الانتظار';

  @override
  String get semesterLabel => 'الفصل الدراسي';

  @override
  String get subjectLabel => 'المادة';

  @override
  String get gradeLabel => 'الدرجة';

  @override
  String get noData => 'لا توجد بيانات';

  @override
  String get studentDataDownloadedSuccessfully => 'تم تحميل بيانات الطالب بنجاح!';

  @override
  String get failedToDownloadStudentData => 'فشل في تحميل بيانات الطالب';

  @override
  String get downloadSemesterStudents => 'تحميل بيانات طلاب الفصل الدراسي';

  @override
  String get semesterStudentsDownloadedSuccessfully => 'تم تحميل بيانات طلاب الفصل الدراسي بنجاح!';

  @override
  String get failedToDownloadSemesterStudents => 'فشل في تحميل بيانات طلاب الفصل الدراسي';
  
  // Image Download
  @override
  String get downloadImage => 'تحميل الصورة';
  
  @override
  String get downloadProfilePicture => 'تحميل صورة الملف الشخصي';
  
  @override
  String get downloadTazkia => 'تحميل صورة التزكية';
  
  @override
  String get downloadIdFront => 'تحميل صورة الهوية الأمامية';
  
  @override
  String get downloadIdBack => 'تحميل صورة الهوية الخلفية';
  
  @override
  String get downloadQualifications => 'تحميل صورة المؤهلات';
  
  @override
  String get imageDownloadedSuccessfully => 'تم تحميل الصورة بنجاح!';

  @override
  String get failedToDownloadImage => 'فشل في تحميل الصورة';

  // Student Edit
  @override
  String get editStudent => 'تعديل الطالب';

  @override
  String get editStudentProfile => 'تعديل ملف الطالب';

  @override
  String get updateProfile => 'تحديث الملف';

  @override
  String get updatingProfile => 'جاري تحديث الملف...';

  @override
  String get profileUpdatedSuccessfully => 'تم تحديث الملف بنجاح!';

  @override
  String get failedToUpdateProfile => 'فشل في تحديث الملف';

  @override
  String get uploadNewDocument => 'رفع مستند جديد';

  @override
  String get uploadProfilePicture => 'رفع صورة شخصية';

  @override
  String get uploadIdFront => 'رفع صورة الهوية الأمامية';

  @override
  String get uploadIdBack => 'رفع صورة الهوية الخلفية';

  @override
  String get uploadTazkia => 'رفع التزكية';

  @override
  String get uploadQualifications => 'رفع المؤهلات';

  @override
  String get selectFile => 'اختر ملف';

  @override
  String get uploading => 'جاري الرفع...';

  @override
  String get nationality => 'الجنسية';

  @override
  String get gender => 'النوع';

  @override
  String get male => 'ذكر';

  @override
  String get female => 'أنثى';

  @override
  String get abEle3traf => 'أب الاعتراف';

  @override
  String get city => 'المدينة';

  // Quiz Creation
  @override
  String get createRecordQuiz => 'إنشاء اختبار تسجيل';

  @override
  String get basicInformation => 'المعلومات الأساسية';

  @override
  String get recordQuizName => 'اسم اختبار التسجيل';

  @override
  String get totalGrade => 'الدرجة الإجمالية';

  @override
  String get numberOfAttempts => 'عدد المحاولات';

  @override
  String get recordingQuestion => 'سؤال التسجيل';

  @override
  String get addQuestion => 'إضافة سؤال';

  @override
  String get editRecordingQuestion => 'تعديل سؤال التسجيل';

  @override
  String get question => 'السؤال';

  @override
  String get maxDurationSecondsOptional => 'المدة القصوى (ثوانٍ) - اختياري';

  @override
  String get studentsWillRecordAudio => 'سيقوم الطلاب بتسجيل إجابات صوتية لهذا السؤال.';

  @override
  String get weekLabel => 'أسبوع';

  @override
  String get finalLabel => 'نهائي';

  @override
  String get lessonLabel => 'الدرس';

  @override
  String get editQuiz => 'تعديل الاختبار';

  @override
  String get createNewQuiz => 'إنشاء اختبار جديد';

  @override
  String get quizInformation => 'معلومات الاختبار';

  @override
  String get quizName => 'اسم الاختبار';

  @override
  String get questionRequirements => 'متطلبات الأسئلة';

  @override
  String get easyQuestions => 'أسئلة سهلة';

  @override
  String get easyQuestionsDescription => 'أسئلة سهلة (نقطة واحدة لكل سؤال)';

  @override
  String get mediumQuestions => 'أسئلة متوسطة';

  @override
  String get mediumQuestionsDescription => 'أسئلة متوسطة (3 نقاط لكل سؤال)';

  @override
  String get hardQuestions => 'أسئلة صعبة';

  @override
  String get hardQuestionsDescription => 'أسئلة صعبة (5 نقاط لكل سؤال)';

  @override
  String get questionsProgress => 'تقدم الأسئلة';

  @override
  String get addQuestionsToMeetRequirements => 'أضف أسئلة لتلبية المتطلبات المحددة أعلاه:';

  @override
  String get addEasy => 'إضافة سهل';

  @override
  String get addMedium => 'إضافة متوسط';

  @override
  String get addHard => 'إضافة صعب';

  @override
  String get currentTotal => 'المجموع الحالي';

  @override
  String get noQuestionsAddedYet => 'لم يتم إضافة أسئلة بعد.';

  @override
  String get addQuestionsUsingButtonsAbove => 'أضف أسئلة باستخدام الأزرار أعلاه.';

  @override
  String get questionType => 'نوع السؤال';

  @override
  String get option => 'خيار';

  @override
  String get addOption => 'إضافة خيار';

  @override
  String get correctAnswerOptional => 'الإجابة الصحيحة (اختياري)';

  @override
  String get totalGradePoints => 'الدرجة الإجمالية: {points} نقطة';

  @override
  String get creatingQuiz => 'إنشاء الاختبار...';

  @override
  String get updatingQuiz => 'تحديث الاختبار...';

  @override
  String get quizCreatedSuccessfully => 'تم إنشاء الاختبار بنجاح!';

  @override
  String get quizUpdatedSuccessfully => 'تم تحديث الاختبار بنجاح!';

  @override
  String get errorCreatingQuiz => 'خطأ في إنشاء الاختبار';

  @override
  String get errorUpdatingQuiz => 'خطأ في تحديث الاختبار';

  @override
  String get pleaseAddRequiredQuestions => 'يرجى إضافة العدد المطلوب من الأسئلة لكل مستوى صعوبة';

  @override
  String get mustBeNonNegative => 'يجب أن تكون غير سالبة';

  @override
  String get invalidNumber => 'رقم غير صحيح';

  @override
  String get searchByStudentName => 'البحث باسم الطالب';

  // Bulk Grading
  @override
  String get addBulkGrades => 'إضافة درجات جماعية';

  @override
  String get bulkGradeInfo => 'إضافة درجات لجميع الطلاب';

  @override
  String get bulkGradeDescription => 'سيتم إضافة الدرجات المحددة لجميع الطلاب الذين أجابوا على هذا الاختبار في الفصل الدراسي المحدد';

  @override
  String get quiz => 'الاختبار';

  @override
  String get gradesToAdd => 'الدرجات المراد إضافتها';

  @override
  String get enterGradesToAdd => 'أدخل عدد الدرجات';

  @override
  String get gradeRangeHelper => 'النطاق: -100 إلى 100 (القيم السالبة للخصم)';

  @override
  String get bulkGradeNote => 'ملاحظة: لن تتجاوز الدرجة النهائية الحد الأقصى للاختبار';

  @override
  String get bulkGradeNegativeNote => 'استخدم قيم سالبة لخصم الدرجات (الحد الأدنى صفر)';

  @override
  String get addGrades => 'إضافة الدرجات';

  @override
  String get gradeCannotBeZero => 'لا يمكن أن تكون الدرجة صفر';

  @override
  String get gradeMustBeBetweenRange => 'يجب أن تكون الدرجة بين -100 و 100';

  @override
  String get semesterIdRequired => 'معرف الفصل الدراسي مطلوب';

  @override
  String get bulkGradeSuccess => 'تم إضافة الدرجات بنجاح';

  @override
  String get studentsUpdated => 'الطلاب المحدثون';

  @override
  String get gradesAdded => 'الدرجات المضافة';

  @override
  String get updatedStudentsList => 'قائمة الطلاب المحدثين';

  @override
  String get ok => 'موافق';

  // Manual Grade Override
  @override
  String get manualGradeOverride => 'تعديل الدرجة يدوياً';

  @override
  String get manualGradeEntry => 'إدخال الدرجة يدوياً';

  @override
  String get manualGradeDescription => 'يمكنك تعديل الدرجة يدوياً حتى للاختبارات المصححة تلقائياً';

  @override
  String get enterGrade => 'أدخل الدرجة';

  @override
  String get maxGrade => 'الدرجة القصوى';

  @override
  String get saveGrade => 'حفظ الدرجة';

  @override
  String get pleaseEnterGrade => 'يرجى إدخال الدرجة';

  @override
  String get invalidGradeFormat => 'صيغة الدرجة غير صحيحة';

  @override
  String get gradeCannotBeNegative => 'لا يمكن أن تكون الدرجة سالبة';

  @override
  String get gradeCannotExceedMax => 'لا يمكن أن تتجاوز الدرجة الحد الأقصى';

  @override
  String get gradeUpdatedSuccessfully => 'تم تحديث الدرجة بنجاح';

  @override
  String get failedToUpdateGrade => 'فشل في تحديث الدرجة';

  @override
  String get errorUpdatingGrade => 'خطأ في تحديث الدرجة';

  // Quick Grade (Direct Grade Entry)
  @override
  String get quickGrade => 'تقييم سريع';

  @override
  String get quickGradeDescription => 'أدخل الدرجة مباشرة بدون حساب من الإجابات';

  @override
  String get quickGradeNote => 'ملاحظة: هذه الدرجة ستحل محل أي درجة موجودة بما في ذلك التصحيح التلقائي';

  @override
  String get currentGrade => 'الدرجة الحالية';

  @override
  String get autoGraded => 'تصحيح تلقائي';

  @override
  String get manuallyGraded => 'تصحيح يدوي';

  @override
  String get calculateFromAnswers => 'حساب من الإجابات';

  @override
  String get calculateFromAnswersDescription => 'احسب الدرجة من إجابات الأسئلة الفردية';

  // Quiz Answer Comments
  @override
  String get comment => 'تعليق';

  @override
  String get addComment => 'إضافة تعليق';

  @override
  String get editComment => 'تعديل التعليق';

  @override
  String get saveComment => 'حفظ التعليق';

  @override
  String get commentPlaceholder => 'اكتب تعليقك هنا...';

  @override
  String get commentSavedSuccessfully => 'تم حفظ التعليق بنجاح';

  @override
  String get failedToSaveComment => 'فشل في حفظ التعليق';

  @override
  String get noComment => 'لا يوجد تعليق';

  @override
  String get instructorComment => 'تعليق المصحح';
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
  String get viewQualifications => 'View Qualifications';

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
  String get trySearchingWithDifferentTerm => 'Try searching with a different term';

  @override
  String get allMatchingStudentsAlreadyEnrolled => 'All matching students are already enrolled in this semester';

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
  String get editLesson => 'Edit Lesson';

  @override
  String get editLessonTitle => 'Edit Lesson';

  @override
  String get lessonUpdatedSuccessfully => 'Lesson updated successfully';

  @override
  String get editLessonItem => 'Edit Lesson Item';

  @override
  String get editLessonItemTitle => 'Edit Lesson Item';

  @override
  String get lessonItemUpdatedSuccessfully => 'Lesson item updated successfully';

  @override
  String get enterItemTitle => 'Enter item title';

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

  // Subject Delete
  @override
  String get deleteSubject => 'Delete Subject';

  @override
  String get deleteSubjectTitle => 'Delete Subject';

  @override
  String get deleteSubjectConfirmation => 'Are you sure you want to delete this subject? This action cannot be undone.';

  @override
  String get subjectDeletedSuccessfully => 'Subject deleted successfully';

  @override
  String get cannotDeleteSubjectWithContent => 'Cannot delete subject with content';

  @override
  String get subjectContainsContent => 'This subject contains lessons or quizzes. Please delete all content first.';

  @override
  String get deleteContentFirst => 'Delete all lessons and quizzes first';

  @override
  String get errorDeletingSubject => 'Error deleting subject';

  // Quiz Answer Delete
  @override
  String get deleteQuizAnswer => 'Delete Quiz Answer';

  @override
  String get deleteQuizAnswerTitle => 'Delete Quiz Answer';

  @override
  String get deleteQuizAnswerConfirmation => 'Are you sure you want to delete this student\'s quiz answer? This action cannot be undone.';

  @override
  String get quizAnswerDeletedSuccessfully => 'Quiz answer deleted successfully';

  @override
  String get errorDeletingQuizAnswer => 'Error deleting quiz answer';

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

  // Password Reset
  @override
  String get resetPassword => 'Reset Password';

  @override
  String get resetPasswordTitle => 'Reset Password';

  @override
  String get resetPasswordDescription => 'Enter a new password for the user';

  @override
  String get newPassword => 'New Password';

  @override
  String get confirmNewPassword => 'Confirm New Password';

  @override
  String get enterNewPassword => 'Enter new password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get passwordResetSuccess => 'Password reset successfully';

  @override
  String get passwordResetFailed => 'Password reset failed';

  @override
  String get passwordResetInProgress => 'Resetting password...';



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

  // Coptic Keyboard
  @override
  String get copticKeyboard => 'Coptic Keyboard';

  @override
  String get showCopticKeyboard => 'Show Coptic Keyboard';

  @override
  String get hideCopticKeyboard => 'Hide Coptic Keyboard';

  // CSV Download
  @override
  String get downloadStudentData => 'Download Student Data';

  @override
  String get email => 'Email';

  @override
  String get phone => 'Phone';

  @override
  String get address => 'Address';

  @override
  String get verificationStatus => 'Verification Status';

  @override
  String get registrationDate => 'Registration Date';

  @override
  String get verified => 'Verified';

  @override
  String get pending => 'Pending';

  @override
  String get semesterLabel => 'Semester';

  @override
  String get subjectLabel => 'Subject';

  @override
  String get gradeLabel => 'Grade';

  @override
  String get noData => 'No Data';

  @override
  String get studentDataDownloadedSuccessfully => 'Student data downloaded successfully!';

  @override
  String get failedToDownloadStudentData => 'Failed to download student data';

  @override
  String get downloadSemesterStudents => 'Download Semester Students Data';

  @override
  String get semesterStudentsDownloadedSuccessfully => 'Semester students data downloaded successfully!';

  @override
  String get failedToDownloadSemesterStudents => 'Failed to download semester students data';
  
  // Image Download
  @override
  String get downloadImage => 'Download Image';
  
  @override
  String get downloadProfilePicture => 'Download Profile Picture';
  
  @override
  String get downloadTazkia => 'Download Tazkia';
  
  @override
  String get downloadIdFront => 'Download ID Front';
  
  @override
  String get downloadIdBack => 'Download ID Back';
  
  @override
  String get downloadQualifications => 'Download Qualifications';
  
  @override
  String get imageDownloadedSuccessfully => 'Image downloaded successfully!';

  @override
  String get failedToDownloadImage => 'Failed to download image';

  // Student Edit
  @override
  String get editStudent => 'Edit Student';

  @override
  String get editStudentProfile => 'Edit Student Profile';

  @override
  String get updateProfile => 'Update Profile';

  @override
  String get updatingProfile => 'Updating profile...';

  @override
  String get profileUpdatedSuccessfully => 'Profile updated successfully!';

  @override
  String get failedToUpdateProfile => 'Failed to update profile';

  @override
  String get uploadNewDocument => 'Upload New Document';

  @override
  String get uploadProfilePicture => 'Upload Profile Picture';

  @override
  String get uploadIdFront => 'Upload ID Front';

  @override
  String get uploadIdBack => 'Upload ID Back';

  @override
  String get uploadTazkia => 'Upload Tazkia';

  @override
  String get uploadQualifications => 'Upload Qualifications';

  @override
  String get selectFile => 'Select File';

  @override
  String get uploading => 'Uploading...';

  @override
  String get nationality => 'Nationality';

  @override
  String get gender => 'Gender';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get abEle3traf => 'Confession Father';

  @override
  String get city => 'City';

  // Quiz Creation
  @override
  String get createRecordQuiz => 'Create Record Quiz';

  @override
  String get basicInformation => 'Basic Information';

  @override
  String get recordQuizName => 'Record Quiz Name';

  @override
  String get totalGrade => 'Total Grade';

  @override
  String get numberOfAttempts => 'Number of Attempts';

  @override
  String get recordingQuestion => 'Recording Question';

  @override
  String get addQuestion => 'Add Question';

  @override
  String get editRecordingQuestion => 'Edit Recording Question';

  @override
  String get question => 'Question';

  @override
  String get maxDurationSecondsOptional => 'Max Duration (seconds) - Optional';

  @override
  String get studentsWillRecordAudio => 'Students will record audio responses to this question.';

  @override
  String get weekLabel => 'Week';

  @override
  String get finalLabel => 'Final';

  @override
  String get lessonLabel => 'Lesson';

  @override
  String get editQuiz => 'Edit Quiz';

  @override
  String get createNewQuiz => 'Create New Quiz';

  @override
  String get quizInformation => 'Quiz Information';

  @override
  String get quizName => 'Quiz Name';

  @override
  String get questionRequirements => 'Question Requirements';

  @override
  String get easyQuestions => 'Easy Questions';

  @override
  String get easyQuestionsDescription => 'Easy Questions (1 pt each)';

  @override
  String get mediumQuestions => 'Medium Questions';

  @override
  String get mediumQuestionsDescription => 'Medium Questions (3 pts each)';

  @override
  String get hardQuestions => 'Hard Questions';

  @override
  String get hardQuestionsDescription => 'Hard Questions (5 pts each)';

  @override
  String get questionsProgress => 'Questions Progress';

  @override
  String get addQuestionsToMeetRequirements => 'Add questions to meet the requirements specified above:';

  @override
  String get addEasy => 'Add Easy';

  @override
  String get addMedium => 'Add Medium';

  @override
  String get addHard => 'Add Hard';

  @override
  String get currentTotal => 'Current Total';

  @override
  String get noQuestionsAddedYet => 'No questions added yet.';

  @override
  String get addQuestionsUsingButtonsAbove => 'Add questions using the buttons above.';

  @override
  String get questionType => 'Question Type';

  @override
  String get option => 'Option';

  @override
  String get addOption => 'Add Option';

  @override
  String get correctAnswerOptional => 'Correct Answer (Optional)';

  @override
  String get totalGradePoints => 'Total Grade: {points} points';

  @override
  String get creatingQuiz => 'Creating quiz...';

  @override
  String get updatingQuiz => 'Updating quiz...';

  @override
  String get quizCreatedSuccessfully => 'Quiz created successfully!';

  @override
  String get quizUpdatedSuccessfully => 'Quiz updated successfully!';

  @override
  String get errorCreatingQuiz => 'Error creating quiz';

  @override
  String get errorUpdatingQuiz => 'Error updating quiz';

  @override
  String get pleaseAddRequiredQuestions => 'Please add the required number of questions for each difficulty level';

  @override
  String get mustBeNonNegative => 'Must be non-negative';

  @override
  String get invalidNumber => 'Invalid number';

  @override
  String get searchByStudentName => 'Search by student name';

  // Bulk Grading
  @override
  String get addBulkGrades => 'Add Bulk Grades';

  @override
  String get bulkGradeInfo => 'Add grades to all students';

  @override
  String get bulkGradeDescription => 'The specified grades will be added to all students who answered this quiz in the selected semester';

  @override
  String get quiz => 'Quiz';

  @override
  String get gradesToAdd => 'Grades to Add';

  @override
  String get enterGradesToAdd => 'Enter number of grades';

  @override
  String get gradeRangeHelper => 'Range: -100 to 100 (negative values for deductions)';

  @override
  String get bulkGradeNote => 'Note: Final grade will not exceed the quiz maximum grade';

  @override
  String get bulkGradeNegativeNote => 'Use negative values to deduct grades (minimum is 0)';

  @override
  String get addGrades => 'Add Grades';

  @override
  String get gradeCannotBeZero => 'Grade cannot be zero';

  @override
  String get gradeMustBeBetweenRange => 'Grade must be between -100 and 100';

  @override
  String get semesterIdRequired => 'Semester ID is required';

  @override
  String get bulkGradeSuccess => 'Grades added successfully';

  @override
  String get studentsUpdated => 'Students Updated';

  @override
  String get gradesAdded => 'Grades Added';

  @override
  String get updatedStudentsList => 'Updated Students List';

  @override
  String get ok => 'OK';

  // Manual Grade Override
  @override
  String get manualGradeOverride => 'Manual Grade Override';

  @override
  String get manualGradeEntry => 'Manual Grade Entry';

  @override
  String get manualGradeDescription => 'You can manually override the grade even for auto-graded quizzes';

  @override
  String get enterGrade => 'Enter Grade';

  @override
  String get maxGrade => 'Max Grade';

  @override
  String get saveGrade => 'Save Grade';

  @override
  String get pleaseEnterGrade => 'Please enter a grade';

  @override
  String get invalidGradeFormat => 'Invalid grade format';

  @override
  String get gradeCannotBeNegative => 'Grade cannot be negative';

  @override
  String get gradeCannotExceedMax => 'Grade cannot exceed maximum';

  @override
  String get gradeUpdatedSuccessfully => 'Grade updated successfully';

  @override
  String get failedToUpdateGrade => 'Failed to update grade';

  @override
  String get errorUpdatingGrade => 'Error updating grade';

  // Quick Grade (Direct Grade Entry)
  @override
  String get quickGrade => 'Quick Grade';

  @override
  String get quickGradeDescription => 'Enter grade directly without calculating from answers';

  @override
  String get quickGradeNote => 'Note: This grade will override any existing grade including auto-grading';

  @override
  String get currentGrade => 'Current Grade';

  @override
  String get autoGraded => 'Auto Graded';

  @override
  String get manuallyGraded => 'Manually Graded';

  @override
  String get calculateFromAnswers => 'Calculate from Answers';

  @override
  String get calculateFromAnswersDescription => 'Calculate grade from individual question answers';

  // Quiz Answer Comments
  @override
  String get comment => 'Comment';

  @override
  String get addComment => 'Add Comment';

  @override
  String get editComment => 'Edit Comment';

  @override
  String get saveComment => 'Save Comment';

  @override
  String get commentPlaceholder => 'Write your comment here...';

  @override
  String get commentSavedSuccessfully => 'Comment saved successfully';

  @override
  String get failedToSaveComment => 'Failed to save comment';

  @override
  String get noComment => 'No comment';

  @override
  String get instructorComment => 'Instructor Comment';
}
