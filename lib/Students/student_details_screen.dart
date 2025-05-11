import 'package:admin_dashboard/Models/student.dart';
import 'package:flutter/material.dart';
import '../Theme.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../provider/student_provider.dart';


class StudentDetailsScreen extends StatefulWidget {
  final Student student;
  StudentDetailsScreen({required this.student});

  @override
  _StudentDetailsScreenState createState() => _StudentDetailsScreenState();
}

class _StudentDetailsScreenState extends State<StudentDetailsScreen> {
  bool _isProcessing = false;

  Future<void> _handleVerification(BuildContext context, String action) async {
    final provider = Provider.of<StudentsProvider>(context, listen: false);
    
    try {
      setState(() => _isProcessing = true);
      
      await provider.verifyStudent(widget.student.id, action);
      
      if (!mounted) return;
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            action == 'approve' 
              ? 'Student approved successfully'
              : 'Student declined successfully'
          ),
          backgroundColor: action == 'approve' ? Colors.green : Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      
      // Return to previous screen
      Navigator.pop(context);
      
    } catch (e) {
      // Show error message
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to ${action} student: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _showVerificationDialog(BuildContext context, String action) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              Icon(
                action == 'approve' ? Icons.check_circle : Icons.cancel,
                color: action == 'approve' ? Colors.green : Colors.red,
              ),
              SizedBox(width: 10),
              Text(
                action == 'approve' ? 'Confirm Approval' : 'Confirm Decline',
                style: AppTheme.headingMedium,
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Student Details:',
                style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('Name: ${widget.student.user.name}'),
              Text('ID: ${widget.student.studentCode}'),
              SizedBox(height: 16),
              Text(
                action == 'approve'
                    ? 'Are you sure you want to approve this student request?'
                    : 'Are you sure you want to decline this student request? This action cannot be undone.',
                style: AppTheme.bodyMedium,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: _isProcessing 
                ? null 
                : () => Navigator.pop(context),
              child: Text('Cancel'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey,
              ),
            ),
            ElevatedButton(
              onPressed: _isProcessing
                ? null
                : () {
                    Navigator.pop(context);
                    _handleVerification(context, action);
                  },
              style: ElevatedButton.styleFrom(
                backgroundColor: action == 'approve' 
                  ? Colors.green 
                  : Colors.red,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: _isProcessing
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(action == 'approve' ? 'Approve' : 'Decline'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Details', 
          style: AppTheme.headingMedium.copyWith(color: Colors.white)
        ),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWideScreen = constraints.maxWidth > 800;
          return Stack(
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.all(25.0),
                child: Column(
                  children: [
                    Container(
                      decoration: AppTheme.cardDecoration,
                      child: Padding(
                        padding: const EdgeInsets.all(25.0),
                        child: isWideScreen 
                          ? buildWideLayout(context) 
                          : buildNarrowLayout(context),
                      ),
                    ),
                    // Add padding at bottom only if showing verification buttons
                    SizedBox(height: !widget.student.isVerified ? 100 : 20),
                  ],
                ),
              ),
              // Show verification buttons only for pending students
              if (!widget.student.isVerified)
                _buildVerificationButtons(),
            ],
          );
        },
      ),
    );
  }

  Widget buildWideLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: buildProfileSection(context),  // Pass context here
        ),
        SizedBox(width: 40),
        Expanded(
          flex: 2,
          child: buildDetailsSection(),
        ),
      ],
    );
  }

  Widget buildNarrowLayout(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        buildProfileSection(context),  // Pass context here
        SizedBox(height: 40),
        buildDetailsSection(),
      ],
    );
  }

  Widget buildProfileSection(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return Dialog(
                  child: InteractiveViewer(
                    child: Image.network(
                      widget.student.personalIDFront ?? 'https://picsum.photos/200/300',
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 200,
                          height: 300,
                          color: Colors.grey.shade200,
                          child: Icon(Icons.person, size: 100, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                );
              },
            );
          },
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: widget.student.isVerified 
                  ? AppTheme.primaryColor 
                  : Colors.orange,
                width: 3
              ),
              boxShadow: [
                BoxShadow(
                  color: (widget.student.isVerified 
                    ? AppTheme.primaryColor 
                    : Colors.orange).withOpacity(0.2),
                  blurRadius: 15,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 80,
              backgroundColor: Colors.grey.shade200,
              backgroundImage: NetworkImage(
                widget.student.personalIDFront ?? 'https://picsum.photos/200/300'
              ),
              onBackgroundImageError: (exception, stackTrace) {},
            ),
          ),
        ),
        SizedBox(height: 20),
        Text(
          widget.student.user.name,
          style: AppTheme.headingLarge,
          textAlign: TextAlign.center,
        ),
        Text(
          'ID: ${widget.student.studentCode}',
          style: AppTheme.bodyMedium,
        ),
        SizedBox(height: 20),
        buildVerificationStatus(),
        if (!widget.student.isVerified) ...[
          SizedBox(height: 20),
          Text(
            'Pending Verification',
            style: AppTheme.bodyMedium.copyWith(
              color: Colors.orange,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }

  Widget buildDetailsSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth < 600 ? 1 : 2;
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildSectionTitle('Academic Information'),
              buildInfoGrid([
                {'title': 'Year', 'value': widget.student.semesters.isNotEmpty ? widget.student.semesters.first.year.toString() : 'N/A'},
                {'title': 'Semester', 'value': widget.student.semesters.isNotEmpty ? widget.student.semesters.first.name : 'N/A'},
                {'title': 'Church', 'value': widget.student.church},
              ], crossAxisCount),
              SizedBox(height: 30),
              buildSectionTitle('Personal Information'),
              buildInfoGrid([
                {'title': 'Date of Birth', 'value': DateFormat('MMM d, y').format(widget.student.user.birthday)},
                {'title': 'Email', 'value': widget.student.user.email},
                {'title': 'Phone', 'value': widget.student.user.phone},
                {'title': 'Address', 'value': widget.student.city},
              ], crossAxisCount),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Dialog(
                            child: InteractiveViewer(
                              child: Image.network(
                                widget.student.tazkia ?? 'https://picsum.photos/200/300',
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 200,
                                    height: 300,
                                    color: Colors.grey.shade200,
                                    child: Icon(Icons.image_not_supported, size: 100, color: Colors.grey),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: Text(
                      'View Tazkia',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.primaryColor,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Dialog(
                            child: InteractiveViewer(
                              child: Image.network(
                                widget.student.personalIDBack ?? 'https://picsum.photos/200/300',
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 200,
                                    height: 300,
                                    color: Colors.grey.shade200,
                                    child: Icon(Icons.image_not_supported, size: 100, color: Colors.grey),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: Text(
                      'View ID Back',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.primaryColor,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
              if (widget.student.qualifications.isNotEmpty) ...[
                SizedBox(height: 30),
                buildSectionTitle('Additional Information'),
                buildInfoGrid([
                  {'title': 'Qualifications', 'value': widget.student.qualifications},
                  {'title': 'Church Service', 'value': widget.student.churchService},
                  {'title': 'Deacon Level', 'value': widget.student.deaconLevel},
                ], crossAxisCount),
              ],
            ],
          ),
        );
      }
    );
  }

  Widget buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTheme.headingMedium.copyWith(color: AppTheme.primaryColor),
        ),
        Divider(color: AppTheme.primaryColor.withOpacity(0.2), thickness: 2),
        SizedBox(height: 20),
      ],
    );
  }

  Widget buildInfoGrid(List<Map<String, String>> items, int crossAxisCount) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: crossAxisCount == 1 ? 8 : 5,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        mainAxisExtent: 80, // Fixed height for each item
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return buildInfoTile(items[index]['title']!, items[index]['value']!);
      },
    );
  }

  Widget buildInfoTile(String title, String value) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondaryColor,
              fontSize: 14,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4),
          Expanded(
            child: Text(
              value,
              style: AppTheme.bodyLarge.copyWith(
                color: AppTheme.textPrimaryColor,
                fontSize: 16,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildVerificationStatus() {
    final bool isVerified = widget.student.isVerified ?? false;
    final statusColor = isVerified ? Colors.green : Colors.orange;
    final backgroundColor = isVerified ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1);
    final statusText = isVerified ? 'Verified' : 'Pending Approval';
    final IconData statusIcon = isVerified ? Icons.verified_user : Icons.pending_outlined;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: statusColor,
          width: isVerified ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 2,
          )
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusIcon,
            color: statusColor,
            size: isVerified ? 24 : 20,
          ),
          SizedBox(width: 8),
          Text(
            statusText,
            style: AppTheme.bodyMedium.copyWith(
              color: statusColor,
              fontWeight: FontWeight.bold,
              fontSize: isVerified ? 16 : 14,
            ),
          ),
          if (isVerified) ...[
            SizedBox(width: 8),
            Icon(
              Icons.check_circle,
              color: statusColor,
              size: 16,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVerificationButtons() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 25.0,
          vertical: 16.0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: ElevatedButton.icon(
                icon: Icon(Icons.close),
                label: Text('Decline'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade50,
                  foregroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.red.shade200),
                  ),
                ),
                onPressed: _isProcessing
                  ? null
                  : () => _showVerificationDialog(context, 'decline'),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                icon: Icon(Icons.check),
                label: Text('Approve'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade50,
                  foregroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.green.shade200),
                  ),
                ),
                onPressed: _isProcessing
                  ? null
                  : () => _showVerificationDialog(context, 'approve'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
