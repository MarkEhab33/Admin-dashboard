import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:flutter_animate/flutter_animate.dart'; // Removed to fix mouse tracker issue
import 'dart:html' as html;

import '../Theme.dart';
import '../provider/announcements_provider.dart';
import '../services/cloudinary_service.dart';
import 'models/announcement_model.dart';

class AnnouncementDetailScreen extends StatelessWidget {
  final int announcementId;
  final CloudinaryService _cloudinaryService = CloudinaryService();

  AnnouncementDetailScreen({
    super.key,
    required this.announcementId,
  });

  // Format date to a readable format
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays < 1) {
      if (difference.inHours < 1) {
        return '${difference.inMinutes} minutes ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('MMM d, y').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AnnouncementsProvider>(
      builder: (context, provider, _) {
        final announcement = provider.getAnnouncementById(announcementId);

        return Scaffold(
          appBar: AppBar(
            title: Text(announcement.title),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _showEditAnnouncementDialog(context, announcement),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _showDeleteConfirmation(context, announcement),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (announcement.imageUrl != null)
                  Hero(
                    tag: 'announcement-image-${announcement.id}',
                    child: Image.network(
                      announcement.imageUrl!,
                      height: 300,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 300,
                          color: Colors.grey[200],
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 300,
                        color: Colors.grey[200],
                        child: const Icon(Icons.error),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        announcement.title,
                        style: AppTheme.headingLarge,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: AppTheme.textSecondaryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(announcement.createdAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        announcement.description,
                        style: AppTheme.bodyLarge,
                      ),
                      if (announcement.meetingLink != null) ...[
                        const SizedBox(height: 32),
                        _buildZoomMeetingCard(context, announcement.meetingLink!),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildZoomMeetingCard(BuildContext context, String zoomLink) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.withAlpha(75),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.videocam,
                color: Colors.blue[700],
              ),
              const SizedBox(width: 8),
              Text(
                'Zoom Meeting',
                style: AppTheme.headingMedium.copyWith(
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Join the Zoom meeting by clicking the button below:',
            style: AppTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              final Uri url = Uri.parse(zoomLink);
              launchUrl(url).then((success) {
                if (!success) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Could not launch $zoomLink'),
                    ),
                  );
                }
              });
            },
            icon: const Icon(Icons.video_call),
            label: const Text('Join Meeting'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditAnnouncementDialog(BuildContext context, Announcement announcement) {
    final titleController = TextEditingController(text: announcement.title);
    final descriptionController = TextEditingController(text: announcement.description);
    final meetingLinkController = TextEditingController(text: announcement.meetingLink ?? '');
    String? imageUrl = announcement.imageUrl;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation1, animation2) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Edit Announcement', style: AppTheme.headingMedium),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.8,
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        hintText: 'Enter announcement title',
                      ),
                    ),
                    const SizedBox(height: 16),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 100),
                      child: TextField(
                        controller: descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          hintText: 'Enter announcement description',
                        ),
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: meetingLinkController,
                      decoration: const InputDecoration(
                        labelText: 'Zoom Meeting Link (Optional)',
                        hintText: 'Enter Zoom meeting link',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Image (Optional)', style: AppTheme.bodyMedium),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () async {
                            try {
                              // Use HTML file input for web
                              final input = html.FileUploadInputElement()
                                ..accept = 'image/jpeg,image/png,image/webp'
                                ..click();

                              input.onChange.listen((event) async {
                                if (input.files?.isNotEmpty ?? false) {
                                  final file = input.files![0];

                                  try {
                                    // Show loading indicator
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Row(
                                            children: [
                                              CircularProgressIndicator(strokeWidth: 2),
                                              SizedBox(width: 16),
                                              Text('Uploading image...'),
                                            ],
                                          ),
                                          duration: Duration(seconds: 30),
                                        ),
                                      );
                                    }

                                    // Upload the image using the backend endpoint
                                    final uploadedUrl = await _cloudinaryService.uploadImageFile(file);

                                    if (context.mounted) {
                                      // Hide loading indicator
                                      ScaffoldMessenger.of(context).hideCurrentSnackBar();

                                      setState(() {
                                        imageUrl = uploadedUrl;
                                      });

                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Image uploaded successfully!'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    }
                                  } catch (uploadError) {
                                    if (context.mounted) {
                                      // Hide loading indicator
                                      ScaffoldMessenger.of(context).hideCurrentSnackBar();

                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Upload failed: $uploadError'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                }
                              });
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error selecting image: $e')),
                                );
                              }
                            }
                          },
                          icon: const Icon(Icons.image),
                          label: const Text('Choose Image'),
                        ),
                        const SizedBox(width: 8),
                        if (imageUrl != null)
                          Expanded(
                            child: Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.green, size: 16),
                                SizedBox(width: 4),
                                Text(
                                  'Image uploaded successfully',
                                  style: AppTheme.bodyMedium.copyWith(color: Colors.green),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Supported formats: JPEG, PNG, WebP • Max size: 5MB',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textSecondaryColor,
                        fontSize: 12,
                      ),
                    ),
                    if (imageUrl != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        constraints: const BoxConstraints(maxHeight: 100),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            imageUrl!,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                height: 100,
                                color: Colors.grey[200],
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) => Container(
                              height: 100,
                              color: Colors.grey[200],
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.error, color: Colors.red),
                                  SizedBox(height: 8),
                                  Text('Failed to load image'),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (titleController.text.isEmpty || descriptionController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please fill in all required fields'),
                        ),
                      );
                      return;
                    }

                    final provider = Provider.of<AnnouncementsProvider>(context, listen: false);
                    final updatedAnnouncement = announcement.copyWith(
                      title: titleController.text,
                      description: descriptionController.text,
                      imageUrl: imageUrl,
                      meetingLink: meetingLinkController.text.isEmpty ? null : meetingLinkController.text,
                    );

                    provider.updateAnnouncement(updatedAnnouncement);
                    Navigator.pop(context);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          ),
          child: child,
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, Announcement announcement) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation1, animation2) {
        return AlertDialog(
          title: const Text('Delete Announcement'),
          content: const Text('Are you sure you want to delete this announcement?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final provider = Provider.of<AnnouncementsProvider>(context, listen: false);
                provider.deleteAnnouncement(announcement.id);
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to announcements list
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          ),
          child: child,
        );
      },
    );
  }
}
