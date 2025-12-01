import 'package:admin_dashboard/Models/student.dart';
import 'package:flutter/material.dart';
import '../Theme.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import '../Models/student_summary.dart';
import '../provider/student_provider.dart';
import '../widgets/password_reset_dialog.dart';
import '../services/cloudinary_service.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import 'dart:convert';


class StudentDetailsScreen extends StatefulWidget {
  final Student student;
  StudentDetailsScreen({required this.student});

  @override
  _StudentDetailsScreenState createState() => _StudentDetailsScreenState();
}

class _StudentDetailsScreenState extends State<StudentDetailsScreen> {
  bool _isProcessing = false;
  StudentSummary? _studentSummary;
  bool _isLoadingGrades = false;
  String _gradesError = '';

  // Current student data (can be updated after edit)
  late Student _currentStudent;

  @override
  void initState() {
    super.initState();
    _currentStudent = widget.student;
    if (widget.student.isVerified) {
      _loadStudentGrades();
    }
  }

  Future<void> _loadStudentGrades() async {
    setState(() {
      _isLoadingGrades = true;
      _gradesError = '';
    });

    try {
      final provider = Provider.of<StudentsProvider>(context, listen: false);
      final summary = await provider.fetchStudentSummaryGrades(widget.student.id);

      if (mounted) {
        setState(() {
          _studentSummary = summary;
          _isLoadingGrades = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _gradesError = e.toString();
          _isLoadingGrades = false;
        });
      }
    }
  }

  Future<void> _handleVerification(BuildContext context, String action) async {
    final provider = Provider.of<StudentsProvider>(context, listen: false);
    
    try {
      setState(() => _isProcessing = true);
      
      await provider.verifyStudent(widget.student.id, action);
      
      if (!mounted) return;

      // Show success message
      if (mounted) {
        final localizations = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              action == 'approve'
                ? localizations.studentApprovedSuccessfully
                : localizations.studentDeclinedSuccessfully
            ),
            backgroundColor: action == 'approve' ? Colors.green : Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
      
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
                action == 'approve' ? AppLocalizations.of(context)!.confirmApproval : AppLocalizations.of(context)!.confirmDecline,
                style: AppTheme.headingMedium,
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.studentDetailsColon,
                style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('${AppLocalizations.of(context)!.studentName}: ${widget.student.user.name}'),
              Text('${AppLocalizations.of(context)!.studentId}: ${widget.student.studentCode}'),
              SizedBox(height: 16),
              Text(
                action == 'approve'
                    ? AppLocalizations.of(context)!.approveStudentConfirmation
                    : AppLocalizations.of(context)!.declineStudentConfirmation,
                style: AppTheme.bodyMedium,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: _isProcessing 
                ? null 
                : () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.cancel),
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
                : Text(action == 'approve' ? AppLocalizations.of(context)!.approve : AppLocalizations.of(context)!.decline),
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
        title: Text(AppLocalizations.of(context)!.studentDetails,
          style: AppTheme.headingMedium.copyWith(color: Colors.white)
        ),
        backgroundColor: AppTheme.primaryColor,
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: Colors.white),
            tooltip: AppLocalizations.of(context)!.editStudent,
            onPressed: _isProcessing ? null : () => _showEditStudentDialog(context),
          ),
        ],
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
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 600,
                      maxHeight: 700,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: InteractiveViewer(
                            child: Image.network(
                              widget.student.user.profilePicture ?? 'https://picsum.photos/200/300',
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
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              if (widget.student.user.profilePicture != null && 
                                  widget.student.user.profilePicture!.isNotEmpty) {
                                _downloadImage(
                                  widget.student.user.profilePicture!,
                                  'profile_${widget.student.user.name}_${DateTime.now().millisecondsSinceEpoch}.jpg'
                                );
                              }
                            },
                            icon: Icon(Icons.download, color: Colors.white),
                            label: Text(
                              AppLocalizations.of(context)!.downloadProfilePicture,
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                            ),
                          ),
                        ),
                      ],
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
                widget.student.user.profilePicture ?? 'https://picsum.photos/200/300'
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
        SizedBox(height: 20),
        _buildDownloadButton(),
        if (!widget.student.isVerified) ...[
          SizedBox(height: 20),
          Text(
            AppLocalizations.of(context)!.pendingVerification,
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
              buildSectionTitle(AppLocalizations.of(context)!.academicInformation),
              buildInfoGrid([
                {'title': AppLocalizations.of(context)!.academicYear, 'value': widget.student.semesters.isNotEmpty ? widget.student.semesters.first.year.toString() : AppLocalizations.of(context)!.notAvailable},
                {'title': AppLocalizations.of(context)!.currentSemesterName, 'value': widget.student.semesters.isNotEmpty ? widget.student.semesters.first.name : AppLocalizations.of(context)!.notAvailable},
                {'title': AppLocalizations.of(context)!.church, 'value': widget.student.church},
              ], crossAxisCount),
              SizedBox(height: 30),
              buildSectionTitle(AppLocalizations.of(context)!.personalInformation),
              buildInfoGrid([
                {'title': AppLocalizations.of(context)!.dateOfBirth, 'value': DateFormat('MMM d, y').format(widget.student.user.birthday)},
                {'title': AppLocalizations.of(context)!.emailAddress, 'value': widget.student.user.email},
                {'title': AppLocalizations.of(context)!.phoneContact, 'value': widget.student.user.phone},
                {'title': AppLocalizations.of(context)!.studentAddress, 'value': widget.student.city},
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
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxWidth: 600,
                                maxHeight: 700,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Expanded(
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
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        if (widget.student.tazkia != null && 
                                            widget.student.tazkia!.isNotEmpty) {
                                          _downloadImage(
                                            widget.student.tazkia!,
                                            'tazkia_${widget.student.user.name}_${DateTime.now().millisecondsSinceEpoch}.jpg'
                                          );
                                        }
                                      },
                                      icon: Icon(Icons.download, color: Colors.white),
                                      label: Text(
                                        AppLocalizations.of(context)!.downloadTazkia,
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.primaryColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: Text(
                      AppLocalizations.of(context)!.viewTazkia,
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
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxWidth: 600,
                                maxHeight: 700,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Expanded(
                                    child: InteractiveViewer(
                                      child: Image.network(
                                        widget.student.personalIDFront ?? 'https://picsum.photos/200/300',
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
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        if (widget.student.personalIDFront != null && 
                                            widget.student.personalIDFront!.isNotEmpty) {
                                          _downloadImage(
                                            widget.student.personalIDFront!,
                                            'id_front_${widget.student.user.name}_${DateTime.now().millisecondsSinceEpoch}.jpg'
                                          );
                                        }
                                      },
                                      icon: Icon(Icons.download, color: Colors.white),
                                      label: Text(
                                        AppLocalizations.of(context)!.downloadIdFront,
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.primaryColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: Text(
                      AppLocalizations.of(context)!.viewIdFront,
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
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxWidth: 600,
                                maxHeight: 700,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Expanded(
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
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        if (widget.student.personalIDBack != null && 
                                            widget.student.personalIDBack!.isNotEmpty) {
                                          _downloadImage(
                                            widget.student.personalIDBack!,
                                            'id_back_${widget.student.user.name}_${DateTime.now().millisecondsSinceEpoch}.jpg'
                                          );
                                        }
                                      },
                                      icon: Icon(Icons.download, color: Colors.white),
                                      label: Text(
                                        AppLocalizations.of(context)!.downloadIdBack,
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.primaryColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: Text(
                      AppLocalizations.of(context)!.viewIdBack,
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.primaryColor,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  if (widget.student.qualifications.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return Dialog(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 600,
                                  maxHeight: 700,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Expanded(
                                      child: InteractiveViewer(
                                        child: Image.network(
                                          widget.student.qualifications,
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
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          if (widget.student.qualifications.isNotEmpty) {
                                            _downloadImage(
                                              widget.student.qualifications,
                                              'qualifications_${widget.student.user.name}_${DateTime.now().millisecondsSinceEpoch}.jpg'
                                            );
                                          }
                                        },
                                        icon: Icon(Icons.download, color: Colors.white),
                                        label: Text(
                                          AppLocalizations.of(context)!.downloadQualifications,
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppTheme.primaryColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                      child: Text(
                        AppLocalizations.of(context)!.viewQualifications,
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.primaryColor,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  SizedBox(width: 20),
                  TextButton(
                    onPressed: () => _showPasswordResetDialog(),
                    child: Text(
                      AppLocalizations.of(context)!.resetPassword,
                      style: AppTheme.bodyMedium.copyWith(
                        color: Colors.orange,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
              if (widget.student.churchService.isNotEmpty || widget.student.deaconLevel.isNotEmpty) ...[
                SizedBox(height: 30),
                buildSectionTitle(AppLocalizations.of(context)!.additionalInformation),
                buildInfoGrid([
                  {'title': AppLocalizations.of(context)!.churchService, 'value': widget.student.churchService},
                  {'title': AppLocalizations.of(context)!.deaconLevel, 'value': widget.student.deaconLevel},
                ], crossAxisCount),
              ],
              // Add grades section for verified students
              if (widget.student.isVerified) ...[
                SizedBox(height: 30),
                _buildGradesSection(),
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
    final statusText = isVerified ? AppLocalizations.of(context)!.verifiedStatus : AppLocalizations.of(context)!.pendingApproval;
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

  Widget _buildGradesSection() {
    final localizations = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionTitle(localizations.academicPerformance),
        if (_isLoadingGrades)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_gradesError.isNotEmpty)
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    localizations.errorLoadingData,
                    style: AppTheme.bodyMedium.copyWith(color: Colors.red),
                  ),
                ),
              ],
            ),
          )
        else if (_studentSummary == null || _studentSummary!.semesters.isEmpty)
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppTheme.textSecondaryColor),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    localizations.noGradesAvailable,
                    style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondaryColor),
                  ),
                ),
              ],
            ),
          )
        else
          ..._buildSemesterGrades(localizations),
      ],
    );
  }

  List<Widget> _buildSemesterGrades(AppLocalizations localizations) {
    if (_studentSummary == null) return [];

    return _studentSummary!.semesters.map((semester) {
      return Container(
        margin: EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.school, color: AppTheme.primaryColor),
                  SizedBox(width: 8),
                  Text(
                    '${localizations.semester} ${semester.semesterNo}: ${semester.name}',
                    style: AppTheme.headingMedium.copyWith(color: AppTheme.primaryColor),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: semester.subjects.map((subject) => _buildSubjectGradeCard(subject, localizations)).toList(),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildSubjectGradeCard(SubjectGrades subject, AppLocalizations localizations) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject.name,
                      style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      subject.code,
                      style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondaryColor),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getGradeColor(subject.gradeLevel).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _getGradeColor(subject.gradeLevel)),
                ),
                child: Text(
                  subject.gradeLevel,
                  style: AppTheme.bodyMedium.copyWith(
                    color: _getGradeColor(subject.gradeLevel),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildQuizGradeItem(subject.weekQuizzes, localizations.weeklyQuizzes, Icons.assignment)),
              SizedBox(width: 16),
              Expanded(child: _buildQuizGradeItem(subject.finalQuizzes, localizations.finalQuizzes, Icons.quiz)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuizGradeItem(QuizGrades quizGrades, String title, IconData icon) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppTheme.primaryColor),
              SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondaryColor),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          if (quizGrades.hasQuizzes) ...[
            Text(
              '${quizGrades.totalScore.toStringAsFixed(1)}/${quizGrades.finalScore.toStringAsFixed(1)}',
              style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              '${quizGrades.percentage.toStringAsFixed(1)}%',
              style: AppTheme.bodyMedium.copyWith(color: _getGradeColor(_getGradeFromPercentage(quizGrades.percentage))),
            ),
          ] else
            Text(
              AppLocalizations.of(context)!.noDataAvailable,
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondaryColor),
            ),
        ],
      ),
    );
  }

  Color _getGradeColor(String grade) {
    switch (grade) {
      case 'A+':
      case 'A':
        return Colors.green;
      case 'B+':
      case 'B':
        return Colors.blue;
      case 'C+':
      case 'C':
        return Colors.orange;
      case 'D':
        return Colors.red.shade300;
      case 'F':
        return Colors.red;
      default:
        return AppTheme.textSecondaryColor;
    }
  }

  String _getGradeFromPercentage(double percentage) {
    if (percentage >= 90) return 'A+';
    if (percentage >= 85) return 'A';
    if (percentage >= 80) return 'B+';
    if (percentage >= 75) return 'B';
    if (percentage >= 70) return 'C+';
    if (percentage >= 65) return 'C';
    if (percentage >= 60) return 'D';
    return 'F';
  }

  Widget _buildDownloadButton() {
    return Container(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(Icons.download, color: Colors.white),
        label: Text(
          AppLocalizations.of(context)!.downloadStudentData,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: _isProcessing ? null : _downloadStudentDataAsCSV,
      ),
    );
  }

  Future<void> _downloadStudentDataAsCSV() async {
    try {
      setState(() => _isProcessing = true);
      
      // Generate CSV data
      final csvData = await _generateCSVData();
      
      // Handle web platform differently
      if (kIsWeb) {
                        // For web, create a download link with proper UTF-8 encoding
                final bytes = utf8.encode('\uFEFF$csvData'); // Add BOM for better Arabic support
                final blob = html.Blob([bytes], 'text/csv;charset=utf-8');
                final url = html.Url.createObjectUrlFromBlob(blob);
                html.AnchorElement(href: url)
                  ..setAttribute('download', 'student_${widget.student.user.name}_${widget.student.studentCode}_${DateTime.now().millisecondsSinceEpoch}.csv')
                  ..click();
                html.Url.revokeObjectUrl(url);
        
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.studentDataDownloadedSuccessfully),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        // For mobile/desktop platforms
        final directory = await getApplicationDocumentsDirectory();
        final fileName = 'student_${widget.student.user.name}_${widget.student.studentCode}_${DateTime.now().millisecondsSinceEpoch}.csv';
        final file = File('${directory.path}/$fileName');
        
                        // Write CSV data to file with BOM for better Arabic support
                await file.writeAsString('\uFEFF$csvData', encoding: utf8);
        
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.studentDataDownloadedSuccessfully),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
        
        // Try to open the file location (platform specific)
        if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
          final uri = Uri.file(directory.path);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri);
          }
        }
      }
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.failedToDownloadStudentData}: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<String> _generateCSVData() async {
    final List<List<dynamic>> rows = [];
    
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
      AppLocalizations.of(context)!.currentSemester,
      AppLocalizations.of(context)!.verificationStatus,
      AppLocalizations.of(context)!.registrationDate
    ]);
    
    // Add student data row
    rows.add([
      widget.student.studentCode,
      widget.student.user.name,
      widget.student.user.email,
      widget.student.user.phone,
      DateFormat('yyyy-MM-dd').format(widget.student.user.birthday),
      widget.student.city,
      widget.student.church,
      widget.student.churchService,
      widget.student.deaconLevel,
      widget.student.semesters.isNotEmpty ? widget.student.semesters.first.year.toString() : 'N/A',
      widget.student.semesters.isNotEmpty ? widget.student.semesters.first.name : 'N/A',
      widget.student.isVerified ? AppLocalizations.of(context)!.verified : AppLocalizations.of(context)!.pending,
      DateFormat('yyyy-MM-dd').format(DateTime.now()),
    ]);
    

    
    // Convert to CSV string
    return const ListToCsvConverter().convert(rows);
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
                label: Text(AppLocalizations.of(context)!.decline),
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
                label: Text(AppLocalizations.of(context)!.approve),
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

  void _showPasswordResetDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => PasswordResetDialog(
        userEmail: widget.student.user.email,
        userName: widget.student.user.name,
      ),
    );
  }

  void _showEditStudentDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return _EditStudentDialog(
          student: _currentStudent,
          onSave: (updatedStudent) {
            setState(() {
              _currentStudent = updatedStudent;
            });
          },
        );
      },
    );
  }

  // Image download helper method
  Future<void> _downloadImage(String imageUrl, String fileName) async {
    try {
      if (kIsWeb) {
        // For web, fetch the image as a blob and create a download link
        final response = await html.HttpRequest.request(
          imageUrl,
          responseType: 'blob',
        );
        
        if (response.status == 200) {
          final blob = response.response as html.Blob;
          final url = html.Url.createObjectUrlFromBlob(blob);
          
          html.AnchorElement(href: url)
            ..download = fileName
            ..click();
          
          html.Url.revokeObjectUrl(url);
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.imageDownloadedSuccessfully),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          throw Exception('Failed to fetch image: ${response.status}');
        }
      } else {
        // For mobile/desktop, show a message that this feature is not available
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image download is only available on web platform'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppLocalizations.of(context)!.failedToDownloadImage}: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

// Edit Student Dialog Widget
class _EditStudentDialog extends StatefulWidget {
  final Student student;
  final Function(Student) onSave;

  const _EditStudentDialog({
    required this.student,
    required this.onSave,
  });

  @override
  _EditStudentDialogState createState() => _EditStudentDialogState();
}

class _EditStudentDialogState extends State<_EditStudentDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isUploadingDocument = false;
  String _uploadingDocumentType = '';

  // Form controllers
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _churchController;
  late TextEditingController _churchServiceController;
  late TextEditingController _deaconLevelController;
  late TextEditingController _abEle3trafController;
  late TextEditingController _nationalityController;

  // Document URLs (can be updated via upload)
  late String _profilePictureUrl;
  late String _personalIDFrontUrl;
  late String _personalIDBackUrl;
  late String _tazkiaUrl;
  late String _qualificationsUrl;

  // Selected gender
  late String _selectedGender;

  // Birthday
  late DateTime _birthday;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with current student data
    _nameController = TextEditingController(text: widget.student.user.name);
    _phoneController = TextEditingController(text: widget.student.user.phone);
    _addressController = TextEditingController(text: widget.student.user.address);
    _cityController = TextEditingController(text: widget.student.city);
    _churchController = TextEditingController(text: widget.student.church);
    _churchServiceController = TextEditingController(text: widget.student.churchService);
    _deaconLevelController = TextEditingController(text: widget.student.deaconLevel);
    _abEle3trafController = TextEditingController(text: widget.student.abEle3traf);
    _nationalityController = TextEditingController(text: widget.student.user.nationality);

    _profilePictureUrl = widget.student.user.profilePicture;
    _personalIDFrontUrl = widget.student.personalIDFront ?? '';
    _personalIDBackUrl = widget.student.personalIDBack ?? '';
    _tazkiaUrl = widget.student.tazkia ?? '';
    _qualificationsUrl = widget.student.qualifications;

    _selectedGender = widget.student.user.gender;
    _birthday = widget.student.user.birthday;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _churchController.dispose();
    _churchServiceController.dispose();
    _deaconLevelController.dispose();
    _abEle3trafController.dispose();
    _nationalityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 700,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.edit, color: Colors.white),
                  SizedBox(width: 12),
                  Text(
                    localizations.editStudentProfile,
                    style: AppTheme.headingMedium.copyWith(color: Colors.white),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            // Form content
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Picture Section
                      _buildSectionTitle(localizations.uploadProfilePicture),
                      _buildDocumentUploadField(
                        label: localizations.uploadProfilePicture,
                        currentUrl: _profilePictureUrl,
                        documentType: 'profilePicture',
                        onUpload: (url) => setState(() => _profilePictureUrl = url),
                      ),
                      SizedBox(height: 24),

                      // Personal Information
                      _buildSectionTitle(localizations.personalInformation),
                      _buildTextField(
                        controller: _nameController,
                        label: localizations.studentName,
                        validator: (value) => value?.isEmpty == true ? localizations.pleaseEnterUsername : null,
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _phoneController,
                              label: localizations.phone,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: _nationalityController,
                              label: localizations.nationality,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDateField(
                              label: localizations.dateOfBirth,
                              value: _birthday,
                              onChanged: (date) => setState(() => _birthday = date),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: _buildGenderDropdown(localizations),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      _buildTextField(
                        controller: _addressController,
                        label: localizations.address,
                      ),
                      SizedBox(height: 24),

                      // Location Information
                      _buildSectionTitle(localizations.church),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _cityController,
                              label: localizations.city,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: _churchController,
                              label: localizations.church,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _churchServiceController,
                              label: localizations.churchService,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: _deaconLevelController,
                              label: localizations.deaconLevel,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      _buildTextField(
                        controller: _abEle3trafController,
                        label: localizations.abEle3traf,
                      ),
                      SizedBox(height: 24),

                      // Documents Section
                      _buildSectionTitle(localizations.uploadNewDocument),
                      _buildDocumentUploadField(
                        label: localizations.uploadIdFront,
                        currentUrl: _personalIDFrontUrl,
                        documentType: 'personalIDFront',
                        onUpload: (url) => setState(() => _personalIDFrontUrl = url),
                      ),
                      SizedBox(height: 12),
                      _buildDocumentUploadField(
                        label: localizations.uploadIdBack,
                        currentUrl: _personalIDBackUrl,
                        documentType: 'personalIDBack',
                        onUpload: (url) => setState(() => _personalIDBackUrl = url),
                      ),
                      SizedBox(height: 12),
                      _buildDocumentUploadField(
                        label: localizations.uploadTazkia,
                        currentUrl: _tazkiaUrl,
                        documentType: 'tazkia',
                        onUpload: (url) => setState(() => _tazkiaUrl = url),
                      ),
                      SizedBox(height: 12),
                      _buildDocumentUploadField(
                        label: localizations.uploadQualifications,
                        currentUrl: _qualificationsUrl,
                        documentType: 'qualifications',
                        onUpload: (url) => setState(() => _qualificationsUrl = url),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Action buttons
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    child: Text(localizations.cancel),
                  ),
                  SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            localizations.updateProfile,
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: AppTheme.headingMedium.copyWith(
          color: AppTheme.primaryColor,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime value,
    required Function(DateTime) onChanged,
  }) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value,
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (picked != null) {
          onChanged(picked);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(DateFormat('yyyy-MM-dd').format(value)),
            Icon(Icons.calendar_today, size: 20, color: AppTheme.primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderDropdown(AppLocalizations localizations) {
    return DropdownButtonFormField<String>(
      value: _selectedGender.isNotEmpty ? _selectedGender : null,
      decoration: InputDecoration(
        labelText: localizations.gender,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      items: [
        DropdownMenuItem(value: 'male', child: Text(localizations.male)),
        DropdownMenuItem(value: 'female', child: Text(localizations.female)),
      ],
      onChanged: (value) {
        if (value != null) {
          setState(() => _selectedGender = value);
        }
      },
    );
  }

  Widget _buildDocumentUploadField({
    required String label,
    required String currentUrl,
    required String documentType,
    required Function(String) onUpload,
  }) {
    final localizations = AppLocalizations.of(context)!;
    final bool isUploading = _isUploadingDocument && _uploadingDocumentType == documentType;

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Preview thumbnail
          if (currentUrl.isNotEmpty)
            GestureDetector(
              onTap: () => _showImagePreview(currentUrl),
              child: Container(
                width: 50,
                height: 50,
                margin: EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: NetworkImage(currentUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTheme.bodyMedium),
                SizedBox(height: 4),
                Text(
                  currentUrl.isNotEmpty ? 'Document uploaded' : 'No document',
                  style: AppTheme.bodyMedium.copyWith(
                    color: currentUrl.isNotEmpty ? Colors.green : Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (isUploading)
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            ElevatedButton.icon(
              onPressed: () => _uploadDocument(documentType, onUpload),
              icon: Icon(Icons.upload, size: 18),
              label: Text(localizations.selectFile),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
        ],
      ),
    );
  }

  void _showImagePreview(String url) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InteractiveViewer(
              child: Image.network(
                url,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 300,
                  height: 300,
                  color: Colors.grey.shade200,
                  child: Icon(Icons.image_not_supported, size: 50),
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.close),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadDocument(String documentType, Function(String) onUpload) async {
    try {
      // Create file input element
      final uploadInput = html.FileUploadInputElement();
      uploadInput.accept = 'image/*';
      uploadInput.click();

      await uploadInput.onChange.first;

      if (uploadInput.files?.isNotEmpty == true) {
        final file = uploadInput.files!.first;

        setState(() {
          _isUploadingDocument = true;
          _uploadingDocumentType = documentType;
        });

        // Use CloudinaryService for upload
        final cloudinaryService = CloudinaryService();
        final url = await cloudinaryService.uploadImageFile(file);

        onUpload(url);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Document uploaded successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload document: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingDocument = false;
          _uploadingDocumentType = '';
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final provider = Provider.of<StudentsProvider>(context, listen: false);
      final localizations = AppLocalizations.of(context)!;

      // Build profile update data according to API spec
      final profileData = {
        'name': _nameController.text,
        'birthday': DateFormat('yyyy-MM-dd').format(_birthday),
        'nationality': _nationalityController.text,
        'Address': _addressController.text,
        'gender': _selectedGender,
        'phone': _phoneController.text,
        'city': _cityController.text,
        'church': _churchController.text,
        'AbEle3traf': _abEle3trafController.text,
        'deaconLevel': _deaconLevelController.text,
        'churchService': _churchServiceController.text,
        'qualifications': _qualificationsUrl,
        'personalIDFront': _personalIDFrontUrl,
        'personalIDBack': _personalIDBackUrl,
        'Tazkia': _tazkiaUrl,
        'profilePicture': _profilePictureUrl,
      };

      final updatedStudent = await provider.updateStudentProfile(
        widget.student.user.id,
        profileData,
      );

      if (mounted) {
        widget.onSave(updatedStudent);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.profileUpdatedSuccessfully),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.failedToUpdateProfile}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
