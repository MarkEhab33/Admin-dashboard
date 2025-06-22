import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Models/student.dart';
import '../provider/student_provider.dart';
import 'student_details_screen.dart';
import '../Theme.dart';
import '../l10n/app_localizations.dart';


class StudentsSemesterTab extends StatefulWidget {
  @override
  _StudentsSemesterTabState createState() => _StudentsSemesterTabState();
}

class _StudentsSemesterTabState extends State<StudentsSemesterTab> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
      Provider.of<StudentsProvider>(context, listen: false).fetchStudents(isVerified: true)
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentsProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          body: Column(
            children: [
              _buildHeader(provider),
              _buildSearchBar(provider),
              Expanded(
                child: _buildStudentsList(provider),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(StudentsProvider provider) {
    final localizations = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            localizations.studentsAndSemesters,
            style: AppTheme.headingLarge,
          ),
          Text(
            '${localizations.students}: ${provider.students.length}',
            style: AppTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(StudentsProvider provider) {
    final localizations = AppLocalizations.of(context)!;

    return Padding(
      padding: EdgeInsets.all(20),
      child: TextField(
        onChanged: provider.updateSearchQuery,
        decoration: InputDecoration(
          hintText: localizations.searchByNameOrCode,
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildStudentsList(StudentsProvider provider) {
    final localizations = AppLocalizations.of(context)!;

    if (provider.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (provider.error.isNotEmpty) {
      return Center(
        child: Text(provider.error, style: TextStyle(color: Colors.red)),
      );
    }

    if (provider.filteredStudents.isEmpty) {
      return Center(
        child: Text(localizations.noStudentsFound, style: AppTheme.bodyLarge),
      );
    }

    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            border: Border(
              bottom: BorderSide(
                color: AppTheme.primaryColor.withValues(alpha: 0.2),
                width: 2,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  localizations.name,
                  style: AppTheme.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  localizations.currentSemester,
                  style: AppTheme.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  localizations.church,
                  style: AppTheme.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  localizations.phoneNumber,
                  style: AppTheme.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
              SizedBox(width: 50), // Space for action button
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: provider.filteredStudents.length,
            itemBuilder: (context, index) {
              final student = provider.filteredStudents[index];
              return _buildStudentListItem(student);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStudentListItem(Student student) {
    final localizations = AppLocalizations.of(context)!;

    // Safe way to get current semester
    final currentSemester = student.semesters.isNotEmpty
        ? (student.semesters.firstWhere(
            (sem) => sem.isCurrent,
            orElse: () => student.semesters.first,
          ))
        : null;

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StudentDetailsScreen(student: student),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(student.user.profilePicture),
                    backgroundColor: AppTheme.primaryColor,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student.user.name,
                          style: AppTheme.bodyMedium.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          student.studentCode,
                          style: AppTheme.bodyMedium.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                currentSemester?.name ?? localizations.notAssigned,
                style: AppTheme.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                student.church,
                style: AppTheme.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                 student.user.phone,
                style: AppTheme.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(
              width: 50,
              child: IconButton(
                icon: Icon(Icons.arrow_forward_ios, size: 18),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StudentDetailsScreen(student: student),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
