import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Models/student.dart';
import '../provider/student_provider.dart';
import 'student_details_screen.dart';
import '../Theme.dart';
import '../l10n/app_localizations.dart';

class StudentRequestsTab extends StatefulWidget {
  @override
  _StudentRequestsTabState createState() => _StudentRequestsTabState();
}

class _StudentRequestsTabState extends State<StudentRequestsTab> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
      Provider.of<StudentsProvider>(context, listen: false).fetchStudents(isVerified: false)
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
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            AppLocalizations.of(context)!.studentRequests,
            style: AppTheme.headingLarge,
          ),
          Text(
            '${AppLocalizations.of(context)!.pendingRequests}: ${provider.students.length}',
            style: AppTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(StudentsProvider provider) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: TextField(
        onChanged: provider.updateSearchQuery,
        decoration: InputDecoration(
          hintText: 'Search by name or student code',
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
        child: Text(AppLocalizations.of(context)!.noPendingRequestsFound, style: AppTheme.bodyLarge),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.all(20),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 3 : 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
      ),
      itemCount: provider.filteredStudents.length,
      itemBuilder: (context, index) => _buildStudentCard(provider.filteredStudents[index]),
    );
  }

  Widget _buildStudentCard(Student student) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.orange.withOpacity(0.3), width: 1),
      ),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StudentDetailsScreen(student: student),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.orange, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.2),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.orange.shade50,
                      child: Text(
                        student.user.name.substring(0, 2).toUpperCase(),
                        style: TextStyle(
                          color: Colors.orange.shade700,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student.user.name,
                          style: AppTheme.headingMedium.copyWith(
                            fontSize: 18,
                            color: AppTheme.textPrimaryColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.badge_outlined, 
                              size: 16, 
                              color: Colors.grey.shade600
                            ),
                            SizedBox(width: 4),
                            Text(
                              student.studentCode,
                              style: AppTheme.bodyMedium.copyWith(
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.email_outlined, 
                              size: 16, 
                              color: Colors.grey.shade600
                            ),
                            SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                student.user.email,
                                style: AppTheme.bodyMedium.copyWith(
                                  color: Colors.grey.shade600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.pending_outlined,
                          size: 16,
                          color: Colors.orange.shade700,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Pending',
                          style: TextStyle(
                            color: Colors.orange.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (student.city != null && student.city.isNotEmpty) ...[
                SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, 
                      size: 16, 
                      color: Colors.grey.shade600
                    ),
                    SizedBox(width: 4),
                    Text(
                      student.city,
                      style: AppTheme.bodyMedium.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}


