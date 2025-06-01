// Assuming navigation is set up in your app:
import 'package:admin_dashboard/Models/student.dart';
import 'package:admin_dashboard/Students/student_semester_grades.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Models/semester.dart';
import '../Models/week.dart';
import '../Theme.dart';
import 'package:provider/provider.dart';
import 'week_content_page.dart';


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
  late TabController _tabController;


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
          tabs: const [
            Tab(text: 'Weeks'),
            Tab(text: 'Students')
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
                        'Weeks',
                        style: AppTheme.headingMedium,
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _showAddWeekDialog(context),
                        icon: const Icon(Icons.add, size: 18, color: Colors.white),
                        label: const Text('Add Week'),
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
                                'No weeks available for this semester',
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
                        'Students',
                        style: AppTheme.headingMedium,
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _showAddStudentDialog(context),
                        icon: const Icon(Icons.add, size: 18, color: Colors.white),
                        label: const Text('Add Student'),
                        style: AppTheme.primaryButtonStyle,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
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
            'Semester Overview',
            style: AppTheme.headingLarge,
          ),
          SizedBox(height: 20),
          Row(
            children: [
              _buildInfoCard(
                'Subjects',
                '${widget.semester.semesterTemplate.subjects.length}',
                Icons.book,
              ),
              SizedBox(width: 16),
              _buildInfoCard(
                'Students',
                '${widget.semester.students.length}',
                Icons.people,
              ),
              SizedBox(width: 16),
              _buildInfoCard(
                'Start Date',
                _formatDate(widget.semester.startDate),
                Icons.calendar_today,
              ),
              SizedBox(width: 16),
              _buildInfoCard(
                'End Date',
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
                'Week ${week.weekNo}',
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
      return 'Invalid date';
    }
  }

  Widget _buildStudentsList() {
    if (widget.semester.students.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Text(
            'No students enrolled in this semester',
            style: AppTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: widget.semester.students.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final student = widget.semester.students[index];
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
                tooltip: 'View Grades',
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
                tooltip: 'Remove Student',
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
        title: Text('Add Student to Semester'),
        content: Container(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: searchController,
                decoration: InputDecoration(
                  labelText: 'Search students',
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

                    final students = provider.filteredStudents;

                    if (students.isEmpty) {
                      return Center(
                        child: Text('No students found'),
                      );
                    }

                    return ListView.builder(
                      itemCount: students.length,
                      itemBuilder: (context, index) {
                        final student = students[index];
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
                              final semestersProvider = Provider.of<SemestersProvider>(
                                context,
                                listen: false
                              );

                              await semestersProvider.addStudentToSemester(
                                widget.semester.id.toString(),
                                student.id.toString(),
                              );

                              Navigator.pop(context);

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Student added successfully'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to add student: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
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
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showRemoveStudentDialog(BuildContext context, Student student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove Student'),
        content: Text(
          'Are you sure you want to remove ${student.user.name} from this semester?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                final semestersProvider = Provider.of<SemestersProvider>(
                  context,
                  listen: false
                );

                await semestersProvider.removeStudentFromSemester(
                  widget.semester.id.toString(),
                  student.id.toString(),
                );

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Student removed successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to remove student: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text(
              'Remove',
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
        title: Text('Add New Week', style: AppTheme.headingMedium),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _weekNoController,
              decoration: AppTheme.inputDecoration('Week Number'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _startDateController,
              decoration: AppTheme.inputDecoration('Start Date').copyWith(
                suffixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true,
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: now,
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
                if (date != null) {
                  setState(() {
                    startDate = date;
                    _startDateController.text = DateFormat('MMM d, y').format(date);
                    // Clear end date if it's before new start date
                    if (endDate != null && endDate!.isBefore(date)) {
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
              decoration: AppTheme.inputDecoration('End Date').copyWith(
                suffixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true,
              onTap: () async {
                if (startDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please select start date first')),
                  );
                  return;
                }

                final suggestedEndDate = startDate!.add(Duration(days: 7));
                final initialEndDate = suggestedEndDate.isBefore(lastDate)
                    ? suggestedEndDate
                    : lastDate;

                final date = await showDatePicker(
                  context: context,
                  initialDate: initialEndDate,
                  firstDate: startDate!,
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
                if (date != null) {
                  setState(() {
                    endDate = date;
                    _endDateController.text = DateFormat('MMM d, y').format(date);
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
            child: Text('Cancel'),
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
                    SnackBar(content: Text('Week added successfully')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to add week: $e')),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please fill all fields')),
                );
              }
            },
            style: AppTheme.primaryButtonStyle,
            child: Text('Add Week'),
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

  void _showEditWeekDialog(Week week) {
    final weekNoController = TextEditingController(text: week.weekNo.toString());
    final startDateController = TextEditingController(
      text: DateFormat('MMM d, y').format(week.startDate),
    );
    final endDateController = TextEditingController(
      text: DateFormat('MMM d, y').format(week.endDate),
    );
    DateTime? startDate = week.startDate;
    DateTime? endDate = week.endDate;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Week', style: AppTheme.headingMedium),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: weekNoController,
              decoration: AppTheme.inputDecoration('Week Number'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: startDateController,
              decoration: AppTheme.inputDecoration('Start Date').copyWith(
                suffixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true,
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: startDate!,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.light(
                          primary: AppTheme.primaryColor,
                          onPrimary: Colors.white,
                          surface: Colors.white,
                          onSurface: Colors.black,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (date != null) {
                  setState(() {
                    startDate = date;
                    startDateController.text = DateFormat('MMM d, y').format(date);
                    if (endDate != null && endDate!.isBefore(date)) {
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
              decoration: AppTheme.inputDecoration('End Date').copyWith(
                suffixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true,
              onTap: () async {
                if (startDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please select start date first')),
                  );
                  return;
                }

                final date = await showDatePicker(
                  context: context,
                  initialDate: endDate ?? startDate!.add(Duration(days: 1)),
                  firstDate: startDate!.add(Duration(days: 1)),
                  lastDate: DateTime(2030),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.light(
                          primary: AppTheme.primaryColor,
                          onPrimary: Colors.white,
                          surface: Colors.white,
                          onSurface: Colors.black,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (date != null) {
                  setState(() {
                    endDate = date;
                    endDateController.text = DateFormat('MMM d, y').format(date);
                  });
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (weekNoController.text.isEmpty ||
                  startDate == null ||
                  endDate == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please fill all fields')),
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
                  SnackBar(content: Text('Week updated successfully')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to update week: $e')),
                );
              }
            },
            style: AppTheme.primaryButtonStyle,
            child: Text('Update'),
          ),
        ],
      ),
    );
  }
}


