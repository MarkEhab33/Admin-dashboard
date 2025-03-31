import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart'; // for file picking
import 'package:provider/provider.dart';
import '../Models/Subject_Template.dart';
import '../provider/subject_provider.dart';
import '../Theme.dart';

class SubjectDetailsScreen extends StatelessWidget {
  final Subject subject;

  const SubjectDetailsScreen({Key? key, required this.subject}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Fetch lessons after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LessonProvider>(context, listen: false)
          .fetchLessons(subject.subjectId!); // Pass the subject id to fetch lessons
    });

    // Function to show a dialog for adding media (video, PDF, or audio)
    void _showAddMediaDialog(BuildContext context) {
      String selectedType = '';
      final TextEditingController urlController = TextEditingController();
      File? selectedFile;

      showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: Text('Add Media', style: AppTheme.headingMedium),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButton<String>(
                  value: selectedType.isEmpty ? null : selectedType,
                  hint: Text('Select Media Type', style: AppTheme.bodyMedium),
                  onChanged: (value) {
                    selectedType = value ?? '';
                  },
                  items: <String>['Video', 'PDF', 'Audio']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: AppTheme.bodyMedium),
                    );
                  }).toList(),
                ),
                if (selectedType == 'Video')
                  TextField(
                    controller: urlController,
                    decoration: AppTheme.inputDecoration('Video URL'),
                  ),
                if (selectedType == 'PDF' || selectedType == 'Audio')
                  ElevatedButton(
                    onPressed: () async {
                      FilePickerResult? result = await FilePicker.platform.pickFiles(
                        type: selectedType == 'PDF' ? FileType.custom : FileType.audio,
                        allowedExtensions: selectedType == 'PDF' ? ['pdf'] : ['mp3'],
                      );
                      if (result != null) {
                        selectedFile = File(result.files.single.path!);
                      }
                    },
                    style: AppTheme.primaryButtonStyle,
                    child: Text(selectedType == 'PDF' ? 'Upload PDF' : 'Upload MP3'),
                  ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text('Cancel',
                    style: TextStyle(color: AppTheme.textSecondaryColor)),
              ),
              ElevatedButton(
                onPressed: () {
                  if (selectedType.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please select media type',
                            style: AppTheme.bodyMedium.copyWith(color: Colors.white)),
                        backgroundColor: AppTheme.primaryColor,
                      ),
                    );
                    return;
                  }
                  if (selectedType == 'Video' && urlController.text.isNotEmpty) {
                    Navigator.of(ctx).pop();
                  } else if (selectedType != 'Video' && selectedFile != null) {
                    Navigator.of(ctx).pop();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please provide valid input',
                            style: AppTheme.bodyMedium.copyWith(color: Colors.white)),
                        backgroundColor: AppTheme.primaryColor,
                      ),
                    );
                  }
                },
                style: AppTheme.primaryButtonStyle,
                child: const Text('Add Media'),
              ),
            ],
          );
        },
      );
    }

    void _showAddLessonDialog(BuildContext context) {
      final TextEditingController lessonNameController = TextEditingController();
      final lessonProvider = Provider.of<LessonProvider>(context, listen: false);

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Add New Lesson', style: AppTheme.headingMedium),
          content: TextField(
            controller: lessonNameController,
            decoration: AppTheme.inputDecoration('Lesson Name'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('Cancel', 
                style: TextStyle(color: AppTheme.textSecondaryColor)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (lessonNameController.text.trim().isNotEmpty) {
                  try {
                    await lessonProvider.addLesson(
                      lessonNameController.text.trim(),
                      subject.subjectId!,
                    );
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Lesson added successfully',
                          style: AppTheme.bodyMedium.copyWith(color: Colors.white)),
                        backgroundColor: AppTheme.primaryColor,
                      ),
                    );
                  } catch (error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to add lesson: $error',
                          style: AppTheme.bodyMedium.copyWith(color: Colors.white)),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: AppTheme.primaryButtonStyle,
              child: const Text('Add'),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          subject.subjectName ?? "NA",
          style: AppTheme.headingMedium.copyWith(color: Colors.white),
        ),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Row(
        children: [
          // Left side list of lessons and add button
          Container(
            width: 300,
            color: AppTheme.surfaceColor,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedButton(
                    onPressed: () => _showAddLessonDialog(context),
                    style: AppTheme.primaryButtonStyle,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, size: 20),
                        SizedBox(width: 8),
                        Text('Add Lesson'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20), // Space between button and list
                  Text(
                    'Lessons',
                    style: AppTheme.headingLarge,
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: Consumer<LessonProvider>(
                      builder: (context, lessonProvider, _) {
                        if (lessonProvider.isLoading) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (lessonProvider.lessons.isEmpty) {
                          return Center(
                            child: Text('No lessons found.', style: AppTheme.bodyLarge),
                          );
                        } else {
                          return ListView.builder(
                            itemCount: lessonProvider.lessons.length,
                            itemBuilder: (context, index) {
                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                decoration: AppTheme.cardDecoration,
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  title: Text(
                                    lessonProvider.lessons[index].name,
                                    style: AppTheme.bodyLarge.copyWith(
                                      color: lessonProvider.selectedLesson ==
                                              lessonProvider.lessons[index]
                                          ? AppTheme.primaryColor
                                          : AppTheme.textPrimaryColor,
                                    ),
                                  ),
                                  tileColor: lessonProvider.selectedLesson ==
                                          lessonProvider.lessons[index]
                                      ? AppTheme.primaryColor.withOpacity(0.1)
                                      : Colors.white,
                                  onTap: () => lessonProvider
                                      .selectLesson(lessonProvider.lessons[index]),
                                ),
                              );
                            },
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Right side details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject.subjectName ?? "NA",
                    style: AppTheme.headingLarge,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Subject Code: ${subject.code}",
                    style: AppTheme.bodyLarge,
                  ),
                  const SizedBox(height: 20),
                  Expanded(  // Wrap the Consumer in Expanded
                    child: Consumer<LessonProvider>(
                      builder: (context, lessonProvider, _) {
                        if (lessonProvider.selectedLesson == null) {
                          return Center(
                            child: Text(
                              'Select a lesson to see details',
                              style: AppTheme.bodyLarge,
                            ),
                          );
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Lesson: ${lessonProvider.selectedLesson?.name}',
                              style: AppTheme.headingMedium,
                            ),
                            const SizedBox(height: 20),
                            Expanded(  // Wrap ListView.builder in Expanded
                              child: lessonProvider.isLoading
                                  ? const Center(child: CircularProgressIndicator())
                                  : ListView.builder(
                                      itemCount: lessonProvider.items.length,
                                      itemBuilder: (context, index) {
                                        final item = lessonProvider.items[index];
                                        return Card(
                                          margin: const EdgeInsets.symmetric(vertical: 8),
                                          child: ListTile(
                                            title: Text(item.title),
                                            subtitle: Text('Type: ${item.itemType}'),
                                            trailing: IconButton(
                                              icon: Icon(
                                                item.itemType == 'video'
                                                    ? Icons.video_library
                                                    : item.itemType == 'pdf'
                                                        ? Icons.picture_as_pdf
                                                        : Icons.audio_file,
                                                color: AppTheme.primaryColor,
                                              ),
                                              onPressed: () {
                                                // Handle item interaction
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      // Floating Action Button to show media dialog
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMediaDialog(context),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
