// Assuming navigation is set up in your app:
import 'package:admin_dashboard/Models/student.dart';
import 'package:admin_dashboard/Students/student_semester_grades.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Models/semester.dart';
import '../Models/week.dart';
import '../Theme.dart';
import '../l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'week_content_page.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import 'dart:convert';

import '../provider/semesters_provider.dart';
import '../provider/student_provider.dart';

class SemesterDetailPage extends StatefulWidget {
  final Semester semester;

  const SemesterDetailPage({Key? key, required this.semester}) : super(key: key);

  @override
  State<SemesterDetailPage> createState() => _SemesterDetailPageState();
}

class _SemesterDetailPageState extends State<SemesterDetailPage> with SingleTickerProviderStateMixin {
  final TextEditingController _weekNoController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _studentSearchController = TextEditingController();
  late TabController _tabController;
  String _studentSearchQuery = '';


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

  }

  @override
  void dispose() {
    _weekNoController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _studentSearchController.dispose();
    _tabController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.semester.name),
        backgroundColor: AppTheme.primaryColor,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: AppLocalizations.of(context)!.weeks),
            Tab(text: AppLocalizations.of(context)!.students)
          ],
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Weeks Tab
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.weeks,
                        style: AppTheme.headingMedium,
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _showAddWeekDialog(context),
                        icon: const Icon(Icons.add, size: 18, color: Colors.white),
                        label: Text(AppLocalizations.of(context)!.addWeek),
                        style: AppTheme.primaryButtonStyle,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: AppTheme.cardDecoration,
                    child: widget.semester.weeks.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Text(
                                AppLocalizations.of(context)!.noWeeksAvailableForSemester,
                                style: AppTheme.bodyLarge,
                              ),
                            ),
                          )
                        : _buildWeeksList(),
                  ),
                ],
              ),
            ),
          ),
          // Students Tab
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.students,
                        style: AppTheme.headingMedium,
                      ),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => _downloadSemesterStudentsAsCSV(),
                            icon: const Icon(Icons.download, size: 18, color: Colors.white),
                            label: Text(AppLocalizations.of(context)!.downloadSemesterStudents),
                            style: AppTheme.primaryButtonStyle,
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton.icon(
                            onPressed: () => _showAddStudentDialog(context),
                            icon: const Icon(Icons.add, size: 18, color: Colors.white),
                            label: Text(AppLocalizations.of(context)!.addStudent),
                            style: AppTheme.primaryButtonStyle,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Search bar for students
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: TextField(
                      controller: _studentSearchController,
                      decoration: AppTheme.inputDecoration(AppLocalizations.of(context)!.searchStudents).copyWith(
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _studentSearchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    _studentSearchController.clear();
                                    _studentSearchQuery = '';
                                  });
                                },
                              )
                            : null,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _studentSearchQuery = value;
                        });
                      },
                    ),
                  ),
                  Container(
                    decoration: AppTheme.cardDecoration,
                    child: _buildStudentsList(),
                  ),
                ],
              ),
            ),
          ),


        ],
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
            AppLocalizations.of(context)!.semesterOverview,
            style: AppTheme.headingLarge,
          ),
          SizedBox(height: 20),
          Row(
            children: [
              _buildInfoCard(
                AppLocalizations.of(context)!.subjects,
                '${widget.semester.semesterTemplate.subjects.length}',
                Icons.book,
              ),
              SizedBox(width: 16),
              _buildInfoCard(
                AppLocalizations.of(context)!.students,
                '${widget.semester.students.length}',
                Icons.people,
              ),
              SizedBox(width: 16),
              _buildInfoCard(
                AppLocalizations.of(context)!.startDate,
                _formatDate(widget.semester.startDate),
                Icons.calendar_today,
              ),
              SizedBox(width: 16),
              _buildInfoCard(
                AppLocalizations.of(context)!.endDate,
                _formatDate(widget.semester.endDate),
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
    // Sort weeks by weekNo before building the list
    final sortedWeeks = List<Week>.from(widget.semester.weeks)
      ..sort((a, b) => a.weekNo.compareTo(b.weekNo));

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(16),
      itemCount: sortedWeeks.length,
      itemBuilder: (context, index) {
        final week = sortedWeeks[index];
        return InkWell(
          child: Card(
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
                '${AppLocalizations.of(context)!.week} ${week.weekNo}',
                style: AppTheme.headingMedium,
              ),
              subtitle: Text(
                '${_formatDate(week.startDate)} - ${_formatDate(week.endDate)}',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              trailing: IconButton(
                icon: Icon(Icons.edit),
                onPressed: () => _showEditWeekDialog(week),
              ),
            ),
          ),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WeekContentPage(week: week,semesterId: widget.semester.id,),
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
      return AppLocalizations.of(context)!.invalidDate;
    }
  }

  Future<void> _downloadSemesterStudentsAsCSV() async {
    try {
      final csvData = _generateSemesterStudentsCSV();
      
      if (kIsWeb) {
        // For web, create a download link with proper UTF-8 encoding
        final bytes = utf8.encode('\uFEFF$csvData'); // Add BOM for better Arabic support
        final blob = html.Blob([bytes], 'text/csv;charset=utf-8');
        final url = html.Url.createObjectUrlFromBlob(blob);
        html.AnchorElement(href: url)
          ..setAttribute('download', '${widget.semester.name}_طلاب_${DateTime.now().millisecondsSinceEpoch}.csv')
          ..click();
        html.Url.revokeObjectUrl(url);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.semesterStudentsDownloadedSuccessfully),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // For mobile/desktop platforms
        final directory = await getApplicationDocumentsDirectory();
        final fileName = '${widget.semester.name}_طلاب_${DateTime.now().millisecondsSinceEpoch}.csv';
        final file = File('${directory.path}/$fileName');
        
        // Write CSV data to file with BOM for better Arabic support
        await file.writeAsString('\uFEFF$csvData', encoding: utf8);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.semesterStudentsDownloadedSuccessfully),
            backgroundColor: Colors.green,
          ),
        );
        
        // Open the file location
        final uri = Uri.file(directory.path);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppLocalizations.of(context)!.failedToDownloadSemesterStudents}: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _generateSemesterStudentsCSV() {
    final rows = <List<dynamic>>[];
    
    // Add header row
    rows.add([
      AppLocalizations.of(context)!.studentId,
      AppLocalizations.of(context)!.studentName,
      AppLocalizations.of(context)!.email,
      AppLocalizations.of(context)!.phone,
      AppLocalizations.of(context)!.dateOfBirth,
      AppLocalizations.of(context)!.address,
      AppLocalizations.of(context)!.church,
      AppLocalizations.of(context)!.churchService,
      AppLocalizations.of(context)!.deaconLevel,
      AppLocalizations.of(context)!.academicYear,
      AppLocalizations.of(context)!.verificationStatus,
      AppLocalizations.of(context)!.registrationDate
    ]);
    
    // Add student data rows
    for (final student in widget.semester.students) {
      rows.add([
        student.studentCode,
        student.user.name,
        student.user.email,
        student.user.phone,
        DateFormat('yyyy-MM-dd').format(student.user.birthday),
        student.city,
        student.church,
        student.churchService,
        student.deaconLevel,
        student.semesters.isNotEmpty ? student.semesters.first.year.toString() : 'N/A',
        student.isVerified ? AppLocalizations.of(context)!.verified : AppLocalizations.of(context)!.pending,
        DateFormat('yyyy-MM-dd').format(DateTime.now()),
      ]);
    }
    
    // Convert to CSV string
    return const ListToCsvConverter().convert(rows);
  }

  Widget _buildStudentsList() {
    if (widget.semester.students.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Text(
            AppLocalizations.of(context)!.noStudentsEnrolledInSemester,
            style: AppTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // Sort students by name before displaying
    final sortedStudents = List<Student>.from(widget.semester.students)
      ..sort((a, b) => a.user.name.toLowerCase().compareTo(b.user.name.toLowerCase()));

    // Filter students based on search query
    final filteredStudents = sortedStudents.where((student) {
      if (_studentSearchQuery.isEmpty) return true;

      final searchLower = _studentSearchQuery.toLowerCase();
      return student.user.name.toLowerCase().contains(searchLower) ||
             student.studentCode.toLowerCase().contains(searchLower);
    }).toList();

    // Show message if no students match the search
    if (filteredStudents.isEmpty && _studentSearchQuery.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 48,
                color: AppTheme.textSecondaryColor,
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.noStudentsFoundInSearch,
                style: AppTheme.bodyLarge.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.trySearchingWithDifferentTerm,
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: filteredStudents.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final student = filteredStudents[index];
        // Safe way to get initials
        final initials = student.user.name.isNotEmpty
            ? student.user.name.characters.first.toUpperCase()
            : '?';

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: AppTheme.primaryColor,
            child: Text(
              initials,
              style: TextStyle(color: Colors.white),
            ),
          ),
          title: Text(student.user.name),
          subtitle: Text(student.studentCode),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.assessment, color: AppTheme.primaryColor),
                tooltip: AppLocalizations.of(context)!.viewGrades,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StudentSemesterGrades(
                        student: student,
                        semester: widget.semester,
                      ),
                    ),
                  );
                },
              ),
              IconButton(
                icon: Icon(Icons.remove_circle_outline, color: Colors.red),
                tooltip: AppLocalizations.of(context)!.removeStudent,
                onPressed: () => _showRemoveStudentDialog(context, student),
              ),
            ],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StudentSemesterGrades(
                  student: student,
                  semester: widget.semester,
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAddStudentDialog(BuildContext context) {
    final studentsProvider = Provider.of<StudentsProvider>(context, listen: false);
    final searchController = TextEditingController();

    // Fetch students summary when dialog opens
    studentsProvider.fetchStudentsSummary();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.addStudentToSemester),
        content: Container(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: searchController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.searchStudents,
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  studentsProvider.updateSearchQuery(value);
                },
              ),
              const SizedBox(height: 16),
              Container(
                height: 300,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Consumer<StudentsProvider>(
                  builder: (context, provider, _) {
                    if (provider.isLoading) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (provider.error.isNotEmpty) {
                      return Center(
                        child: Text(
                          provider.error,
                          style: TextStyle(color: Colors.red),
                        ),
                      );
                    }

                    // Get filtered students and exclude those already in the semester
                    final allFilteredStudents = provider.filteredStudents;

                    // Get list of user IDs already enrolled in this semester
                    final enrolledUserIds = widget.semester.students
                        .map((student) => student.user.id)
                        .toSet();

                    // Filter out students already enrolled in this semester and only show verified students
                    final availableStudents = allFilteredStudents
                        .where((student) => !enrolledUserIds.contains(student.user.id) )
                        .toList();

                    // Sort available students by name
                    availableStudents.sort((a, b) =>
                        a.user.name.toLowerCase().compareTo(b.user.name.toLowerCase()));

                    if (availableStudents.isEmpty) {
                      return Center(
                        child: Text(
                          allFilteredStudents.isEmpty
                              ? AppLocalizations.of(context)!.noStudentsFoundInSearch
                              : AppLocalizations.of(context)!.allMatchingStudentsAlreadyEnrolled,
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: availableStudents.length,
                      itemBuilder: (context, index) {
                        final student = availableStudents[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppTheme.primaryColor,
                            child: Text(
                              student.user.name.isNotEmpty
                                  ? student.user.name[0].toUpperCase()
                                  : '?',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(student.user.name),
                          subtitle: Text(student.studentCode),
                          onTap: () async {
                            try {
                              // Debug: Print student information
                              print('Selected student: ${student.user.name}');
                              print('Student ID: ${student.id}');
                              print('User ID: ${student.user.id}');
                              print('Student Code: ${student.studentCode}');

                              if (student.user.id == 0) {
                                throw Exception('Cannot add student: User ID is 0. Please check the API response.');
                              }

                              final semestersProvider = Provider.of<SemestersProvider>(
                                context,
                                listen: false
                              );

                              // Store context references before async operations
                              final navigator = Navigator.of(context);
                              final scaffoldMessenger = ScaffoldMessenger.of(context);
                              final successMessage = AppLocalizations.of(context)!.studentAddedSuccessfully;

                              await semestersProvider.addStudentToSemester(
                                widget.semester.id.toString(),
                                student.user.id.toString(),
                              );

                              // Refresh the semester data to update the student list
                              await semestersProvider.fetchSemesters();

                              navigator.pop();

                              if (mounted) {
                                scaffoldMessenger.showSnackBar(
                                  SnackBar(
                                    content: Text(successMessage),
                                    backgroundColor: Colors.green,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                );

                                // Trigger a rebuild of the widget to show updated data
                                setState(() {});
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Failed to add student: $e'),
                                    backgroundColor: Colors.red,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
        ],
      ),
    );
  }

  void _showRemoveStudentDialog(BuildContext context, Student student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.removeStudentTitle),
        content: Text(
          '${AppLocalizations.of(context)!.removeStudentConfirmation}\n\n${AppLocalizations.of(context)!.studentName}: ${student.user.name}'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () async {
              try {
                final semestersProvider = Provider.of<SemestersProvider>(
                  context,
                  listen: false
                );

                // Store context references before async operations
                final navigator = Navigator.of(context);
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                final successMessage = AppLocalizations.of(context)!.studentRemovedSuccessfully;

                await semestersProvider.removeStudentFromSemester(
                  widget.semester.id.toString(),
                  student.user.id.toString(),
                );

                // Refresh the semester data to update the student list
                await semestersProvider.fetchSemesters();

                navigator.pop();

                if (mounted) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text(successMessage),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );

                  // Trigger a rebuild of the widget to show updated data
                  setState(() {});
                }
              } catch (e) {
                if (mounted) {
                  final scaffoldMessenger = ScaffoldMessenger.of(context);
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text('Failed to remove student: $e'),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                }
              }
            },
            child: Text(
              AppLocalizations.of(context)!.remove,
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddWeekDialog(BuildContext context) {
    DateTime? startDate;
    DateTime? endDate;
    final now = DateTime.now();
    final firstDate = DateTime(now.year);
    final lastDate = DateTime(now.year + 1, 12, 31);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.addNewWeek, style: AppTheme.headingMedium),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _weekNoController,
              decoration: AppTheme.inputDecoration(AppLocalizations.of(context)!.weekNumber),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _startDateController,
              decoration: AppTheme.inputDecoration(AppLocalizations.of(context)!.startDate).copyWith(
                suffixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true,
              onTap: () async {
                final dateTime = await _selectDateAndTime(
                  context,
                  initialDate: now,
                  firstDate: firstDate,
                  lastDate: lastDate,
                );
                if (dateTime != null) {
                  setState(() {
                    startDate = dateTime;
                    _startDateController.text = _formatDateTimeWithAmPm(dateTime);
                    // Clear end date if it's before new start date
                    if (endDate != null && endDate!.isBefore(dateTime)) {
                      endDate = null;
                      _endDateController.text = '';
                    }
                  });
                }
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _endDateController,
              decoration: AppTheme.inputDecoration(AppLocalizations.of(context)!.endDate).copyWith(
                suffixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true,
              onTap: () async {
                if (startDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppLocalizations.of(context)!.pleaseSelectStartDateFirst)),
                  );
                  return;
                }

                final suggestedEndDate = startDate!.add(Duration(days: 7));
                final initialEndDate = suggestedEndDate.isBefore(lastDate)
                    ? suggestedEndDate
                    : lastDate;

                final dateTime = await _selectDateAndTime(
                  context,
                  initialDate: initialEndDate,
                  firstDate: startDate!,
                  lastDate: lastDate,
                );
                if (dateTime != null) {
                  setState(() {
                    endDate = dateTime;
                    _endDateController.text = _formatDateTimeWithAmPm(dateTime);
                  });
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _clearControllers();
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_weekNoController.text.isNotEmpty &&
                  startDate != null &&
                  endDate != null) {
                try {
                  final semestersProvider = Provider.of<SemestersProvider>(context, listen: false);

                  await semestersProvider.addWeek(
                    widget.semester.id,
                    int.parse(_weekNoController.text),
                    startDate!,
                    endDate!,
                  );

                  // Refresh semester data after adding a week
                  final updatedSemester = await semestersProvider.fetchSemesterById(widget.semester.id);

                  // Update the state with the new semester data
                  setState(() {
                    widget.semester.weeks.clear();
                    widget.semester.weeks.addAll(updatedSemester.weeks);
                    widget.semester.weeks.sort((a, b) => a.weekNo.compareTo(b.weekNo));
                  });

                  _clearControllers();
                  Navigator.pop(context);

                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppLocalizations.of(context)!.weekAddedSuccessfully)),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${AppLocalizations.of(context)!.failedToAddWeek}: $e')),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppLocalizations.of(context)!.pleaseFillAllFields)),
                );
              }
            },
            style: AppTheme.primaryButtonStyle,
            child: Text(AppLocalizations.of(context)!.addWeek),
          ),
        ],
      ),
    );
  }

  void _clearControllers() {
    _weekNoController.text = '';
    _startDateController.text = '';
    _endDateController.text = '';
  }

  // Helper method to select date and time
  Future<DateTime?> _selectDateAndTime(BuildContext context, {
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
  }) async {
    // First, select the date
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (date == null) return null;

    // Then, select the time
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (time == null) return null;

    // Combine date and time
    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }

  // Helper method to format date and time with AM/PM
  String _formatDateTimeWithAmPm(DateTime dateTime) {
    return DateFormat('MMM d, y - h:mm a').format(dateTime);
  }

  void _showEditWeekDialog(Week week) {
    final weekNoController = TextEditingController(text: week.weekNo.toString());
    final startDateController = TextEditingController(
      text: _formatDateTimeWithAmPm(week.startDate),
    );
    final endDateController = TextEditingController(
      text: _formatDateTimeWithAmPm(week.endDate),
    );
    DateTime? startDate = week.startDate;
    DateTime? endDate = week.endDate;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.editWeek, style: AppTheme.headingMedium),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: weekNoController,
              decoration: AppTheme.inputDecoration(AppLocalizations.of(context)!.weekNumber),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: startDateController,
              decoration: AppTheme.inputDecoration(AppLocalizations.of(context)!.startDate).copyWith(
                suffixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true,
              onTap: () async {
                final dateTime = await _selectDateAndTime(
                  context,
                  initialDate: startDate!,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (dateTime != null) {
                  setState(() {
                    startDate = dateTime;
                    startDateController.text = _formatDateTimeWithAmPm(dateTime);
                    if (endDate != null && endDate!.isBefore(dateTime)) {
                      endDate = null;
                      endDateController.text = '';
                    }
                  });
                }
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: endDateController,
              decoration: AppTheme.inputDecoration(AppLocalizations.of(context)!.endDate).copyWith(
                suffixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true,
              onTap: () async {
                if (startDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppLocalizations.of(context)!.pleaseSelectStartDateFirst)),
                  );
                  return;
                }

                final dateTime = await _selectDateAndTime(
                  context,
                  initialDate: endDate ?? startDate!.add(Duration(days: 1)),
                  firstDate: startDate!.add(Duration(days: 1)),
                  lastDate: DateTime(2030),
                );
                if (dateTime != null) {
                  setState(() {
                    endDate = dateTime;
                    endDateController.text = _formatDateTimeWithAmPm(dateTime);
                  });
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              if (weekNoController.text.isEmpty ||
                  startDate == null ||
                  endDate == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppLocalizations.of(context)!.pleaseFillAllFields)),
                );
                return;
              }

              try {
                final semestersProvider = Provider.of<SemestersProvider>(
                  context,
                  listen: false,
                );

                await semestersProvider.updateWeek(
                  weekId: week.id,
                  weekNo: int.parse(weekNoController.text),
                  startDate: startDate!,
                  endDate: endDate!,
                );

                // Refresh the semester data after updating the week
                final updatedSemester = await semestersProvider.fetchSemesterById(widget.semester.id);

                // Update the state with the new semester data
                setState(() {
                  widget.semester.weeks.clear();
                  widget.semester.weeks.addAll(updatedSemester.weeks);
                  widget.semester.weeks.sort((a, b) => a.weekNo.compareTo(b.weekNo));
                });

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppLocalizations.of(context)!.weekUpdatedSuccessfully)),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${AppLocalizations.of(context)!.failedToUpdateWeek}: $e')),
                );
              }
            },
            style: AppTheme.primaryButtonStyle,
            child: Text(AppLocalizations.of(context)!.update),
          ),
        ],
      ),
    );
  }
}


