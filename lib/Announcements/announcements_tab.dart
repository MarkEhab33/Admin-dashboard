import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
// import 'package:flutter_animate/flutter_animate.dart'; // Removed to fix mouse tracker issue
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'dart:html' as html;

import '../Theme.dart';
import '../provider/announcements_provider.dart';
import '../services/cloudinary_service.dart';
import 'models/announcement_model.dart';
import 'announcement_detail_screen.dart';

class AnnouncementsTab extends StatefulWidget {
  const AnnouncementsTab({super.key});

  @override
  State<AnnouncementsTab> createState() => _AnnouncementsTabState();
}

class _AnnouncementsTabState extends State<AnnouncementsTab> with SingleTickerProviderStateMixin {
  late final AnimationController _fabAnimationController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final CloudinaryService _cloudinaryService = CloudinaryService();

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // Fetch announcements when the tab is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<AnnouncementsProvider>(context, listen: false);
      provider.fetchAllAnnouncements();
    });
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

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
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildSearchBar(),
            const SizedBox(height: 24),
            Expanded(
              child: _buildAnnouncementsList(),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildAnimatedFAB(),
    );
  }

  Widget _buildAnimatedFAB() {
    return AnimatedBuilder(
      animation: _fabAnimationController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_fabAnimationController.value * 0.1),
          child: FloatingActionButton.extended(
            onPressed: () => _showAddAnnouncementDialog(context),
            backgroundColor: AppTheme.primaryColor,
            icon: const Icon(Icons.add),
            label: const Text('New Announcement'),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Announcements',
          style: AppTheme.headingLarge,
        ),
        Consumer<AnnouncementsProvider>(
          builder: (context, provider, _) {
            return IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: provider.isLoading
                ? null
                : () => provider.fetchAllAnnouncements(),
              tooltip: 'Refresh announcements',
            );
          },
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search announcements...',
          prefixIcon: const Icon(Icons.search),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
          });
        },
      ),
    );
  }

  Widget _buildAnnouncementsList() {
    return Consumer<AnnouncementsProvider>(
      builder: (context, provider, _) {
        // Show loading indicator
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // Show error message if there is an error
        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 100,
                  color: Colors.red[300],
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading announcements',
                  style: AppTheme.headingMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  provider.error!,
                  style: AppTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    provider.fetchAllAnnouncements();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final announcements = provider.announcements.where((announcement) {
          return announcement.title.toLowerCase().contains(_searchQuery) ||
              announcement.description.toLowerCase().contains(_searchQuery);
        }).toList();

        if (announcements.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.announcement_outlined,
                  size: 100,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No announcements found',
                  style: AppTheme.headingMedium,
                ),
              ],
            ),
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final isWideScreen = constraints.maxWidth > 900;
            return isWideScreen
                ? _buildAnnouncementsGrid(announcements)
                : _buildAnnouncementsListView(announcements);
          },
        );
      },
    );
  }

  Widget _buildAnnouncementsGrid(List<Announcement> announcements) {
    return AnimationLimiter(
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1.2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: announcements.length,
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredGrid(
            position: index,
            duration: const Duration(milliseconds: 500),
            columnCount: 3,
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: _buildAnnouncementCard(announcements[index]),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnnouncementsListView(List<Announcement> announcements) {
    return AnimationLimiter(
      child: ListView.separated(
        itemCount: announcements.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 500),
            child: SlideAnimation(
              horizontalOffset: 50.0,
              child: FadeInAnimation(
                child: _buildAnnouncementListItem(announcements[index]),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnnouncementCard(Announcement announcement) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AnnouncementDetailScreen(
                announcementId: announcement.id,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (announcement.imageUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: Image.network(
                  announcement.imageUrl!,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 120,
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
                    height: 120,
                    color: Colors.grey[200],
                    child: const Icon(Icons.error),
                  ),
                ),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      announcement.title,
                      style: AppTheme.headingMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      announcement.description,
                      style: AppTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDate(announcement.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                        if (announcement.meetingLink != null)
                          Icon(
                            Icons.videocam,
                            size: 16,
                            color: AppTheme.primaryColor,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnnouncementListItem(Announcement announcement) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      leading: announcement.imageUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                announcement.imageUrl!,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: 60,
                    height: 60,
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
                  width: 60,
                  height: 60,
                  color: Colors.grey[200],
                  child: const Icon(Icons.error),
                ),
              ),
            )
          : Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.announcement,
                color: AppTheme.primaryColor,
              ),
            ),
      title: Text(
        announcement.title,
        style: AppTheme.headingMedium,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            announcement.description,
            style: AppTheme.bodyMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                _formatDate(announcement.createdAt),
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              if (announcement.meetingLink != null) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.videocam,
                  size: 16,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: 4),
                Text(
                  'Zoom Meeting Available',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: AppTheme.textSecondaryColor,
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AnnouncementDetailScreen(
              announcementId: announcement.id,
            ),
          ),
        );
      },
    );
  }

  void _showAddAnnouncementDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final meetingLinkController = TextEditingController();
    String? imageUrl;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation1, animation2) {
        return StatefulBuilder(
          builder: (context, setState) {
            print('=== DIALOG REBUILD ===');
            print('Current imageUrl: $imageUrl');
            return AlertDialog(
              title: Text('Add New Announcement', style: AppTheme.headingMedium),
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
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'Enter announcement description',
                      ),
                      maxLines: 5,
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
                              print('=== CREATE ANNOUNCEMENT IMAGE UPLOAD DEBUG ===');
                              print('Starting image selection...');

                              // Use HTML file input for web
                              final input = html.FileUploadInputElement()
                                ..accept = 'image/jpeg,image/png,image/webp'
                                ..click();

                              input.onChange.listen((event) async {
                                if (input.files?.isNotEmpty ?? false) {
                                  final file = input.files![0];
                                  print('File selected: ${file.name}');
                                  print('File size: ${file.size} bytes');
                                  print('File type: ${file.type}');

                                  try {
                                    // Show loading indicator
                                    if (context.mounted) {
                                      print('Showing loading indicator...');
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

                                    print('Starting upload to backend...');
                                    // Upload the image using the backend endpoint
                                    final uploadedUrl = await _cloudinaryService.uploadImageFile(file);
                                    print('Upload successful! URL: $uploadedUrl');

                                    if (context.mounted) {
                                      // Hide loading indicator
                                      ScaffoldMessenger.of(context).hideCurrentSnackBar();

                                      setState(() {
                                        print('Setting imageUrl in setState: $uploadedUrl');
                                        imageUrl = uploadedUrl;
                                      });

                                      print('Image URL set in state: $imageUrl');
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Image uploaded successfully!'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    }
                                  } catch (uploadError) {
                                    print('Upload error: $uploadError');
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
                                } else {
                                  print('No file selected');
                                }
                              });
                            } catch (e) {
                              print('Error in file selection: $e');
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
                        constraints: const BoxConstraints(maxHeight: 120),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            imageUrl!,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                height: 120,
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
                              height: 120,
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
                    print('=== CREATE ANNOUNCEMENT SAVE BUTTON CLICKED ===');
                    print('Title: ${titleController.text}');
                    print('Description: ${descriptionController.text}');
                    print('Image URL: $imageUrl');
                    print('Meeting Link: ${meetingLinkController.text}');

                    if (titleController.text.isEmpty || descriptionController.text.isEmpty) {
                      print('Validation failed: Missing required fields');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please fill in all required fields'),
                        ),
                      );
                      return;
                    }

                    final provider = Provider.of<AnnouncementsProvider>(context, listen: false);

                    // Create announcement data
                    final Map<String, dynamic> announcementData = {
                      'title': titleController.text,
                      'description': descriptionController.text,
                    };

                    if (imageUrl != null) {
                      print('Adding image URL to announcement data: $imageUrl');
                      announcementData['imageUrl'] = imageUrl;
                    } else {
                      print('No image URL to add');
                    }

                    if (meetingLinkController.text.isNotEmpty) {
                      print('Adding meeting link to announcement data: ${meetingLinkController.text}');
                      announcementData['meetingLink'] = meetingLinkController.text;
                    } else {
                      print('No meeting link to add');
                    }

                    print('Final announcement data: $announcementData');

                    // For API compatibility, we need to create a temporary announcement
                    // The actual ID, createdAt, and updatedAt will be set by the server
                    final tempAnnouncement = Announcement(
                      id: 0, // Temporary ID
                      title: titleController.text,
                      description: descriptionController.text,
                      imageUrl: imageUrl,
                      meetingLink: meetingLinkController.text.isEmpty ? null : meetingLinkController.text,
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                    );

                    print('Creating announcement with provider...');
                    provider.createAnnouncement(tempAnnouncement);
                    print('Closing dialog...');
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
}
