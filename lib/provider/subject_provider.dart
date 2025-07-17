import 'dart:convert';
import 'dart:io';
import 'dart:html' as html;
import 'package:admin_dashboard/Constants/globals.dart';
import 'package:admin_dashboard/utils/string_extensions.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../Models/subject.dart';
import '../Models/lesson_item.dart';
import '../services/cloudinary_service.dart';

class LessonProvider with ChangeNotifier {
  List<Lesson> _lessons = [];
  Lesson? _selectedLesson;
  bool _isLoading = false;
  bool _isUploading = false;
  bool _isDeleting = false;
  double _uploadProgress = 0.0;
  List<LessonItem> _items = [];
  final CloudinaryService _cloudinaryService = CloudinaryService();

  List<Lesson> get lessons => _lessons;
  Lesson? get selectedLesson => _selectedLesson;
  bool get isLoading => _isLoading;
  bool get isUploading => _isUploading;
  bool get isDeleting => _isDeleting;
  double get uploadProgress => _uploadProgress;
  List<LessonItem> get items => _items;

  Future<void> fetchLessons(int subjectId) async {
    _isLoading = true;
    notifyListeners();

    final url = Uri.parse(Globals.getApiUrl('/subject/$subjectId/lessons'));
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final extractedData = json.decode(response.body) as Map<String, dynamic>;
        final List<Lesson> loadedLessons = [];
        for (var lessonData in extractedData['data']) {
          loadedLessons.add(Lesson.fromJson(lessonData));
        }
        _lessons = loadedLessons;
        _isLoading = false;
        notifyListeners();
      } else {
        throw Exception('Failed to load lessons');
      }
    } catch (error) {
      _isLoading = false;
      notifyListeners();
      throw error;
    }
  }

  Future<void> addLesson(String lessonName, int subjectId) async {
    final url = Uri.parse('${Globals.baseUrl}/subject/lesson');

    try {
      // Set loading state while adding lesson
      _isLoading = true;
      notifyListeners();

      // Prepare data to send in POST request
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'name': lessonName,
          'subjectId': subjectId,
        }),
      );
      final responseData = json.decode(response.body);
      // Handle response
      if (response.statusCode == 200 || response.statusCode == 201) {
          await fetchLessons(subjectId);
        } else {
        throw Exception('Failed to add lesson. Response message: ${responseData['message']}');
        }

    } catch (error) {
      _isLoading = false;
      notifyListeners();
      throw error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchLessonItems(int lessonId) async {
    _isLoading = true;
    notifyListeners();

    final url = Uri.parse('${Globals.baseUrl}/subject/lesson/$lessonId/items');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final extractedData = json.decode(response.body) as Map<String, dynamic>;
        final List<LessonItem> loadedItems = [];
        if (extractedData['data'] != null) {
          for (var itemData in extractedData['data']) {
            try {
              final item = LessonItem.fromJson(itemData);
              loadedItems.add(item);
            } catch (e, stackTrace) {
              print('Error parsing item: $e');
              print('Stack trace: $stackTrace');
              print('Problem data: $itemData');
              continue;
            }
          }
        }
        _items = loadedItems;
      } else {
        print('Failed to load items: ${response.statusCode}');
        print('Response body: ${response.body}');
        _items = [];
      }
    } catch (error, stackTrace) {
      print('Error fetching items: $error');
      print('Stack trace: $stackTrace');
      _items = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectLesson(Lesson lesson) {
    if (lesson.id != null) {
      _selectedLesson = lesson;
      fetchLessonItems(lesson.id);
      notifyListeners();
    } else {
      print('Error: Lesson ID is null');
    }
  }
void setLessonNull(){
    _selectedLesson =null;
    notifyListeners();
}
  Future<void> uploadPdfItem({
    required int lessonId,
    required String title,
    required html.File file,
  }) async {
    try {
      // Validate file type
      if (!file.name.toLowerCase().endsWith('.pdf')) {
        throw Exception('Invalid file type. Only PDF files are allowed.');
      }

      // Validate file size (max 20MB as per backend API)
      if (file.size > 20 * 1024 * 1024) {
        throw Exception('File size exceeds 20MB limit');
      }

      _isUploading = true;
      _uploadProgress = 0.1;
      notifyListeners();

      // Upload file using new backend endpoint
      _uploadProgress = 0.3;
      notifyListeners();

      print('=== Subject Provider PDF Upload ===');
      print('About to call uploadPdfFile...');
      final fileUrl = await _cloudinaryService.uploadPdfFile(file);
      print('Upload completed, received URL: $fileUrl');
      
      _uploadProgress = 0.7;
      notifyListeners();

      // Create lesson item with PDF URL
      await uploadLessonItem(
        lessonId: lessonId,
        title: title.trim(),
        itemType: 'pdf',
        itemContent: fileUrl,
      );

      _uploadProgress = 1.0;
      notifyListeners();

      // Refresh lesson items
      await fetchLessonItems(lessonId);
    } catch (error) {
      print('Error in uploadPdfItem: $error');
      throw Exception('Error uploading PDF: $error');
    } finally {
      _isUploading = false;
      _uploadProgress = 0.0;
      notifyListeners();
    }
  }

  Future<void> uploadAudioItem({
    required int lessonId,
    required String title,
    required html.File file,
  }) async {
    try {
      // Validate file type (as per backend API)
      final validAudioTypes = ['.mp3', '.wav', '.ogg', '.m4a'];
      if (!validAudioTypes.any((type) => file.name.toLowerCase().endsWith(type))) {
        throw Exception('Invalid file type. Allowed types: ${validAudioTypes.join(", ")}');
      }

      // Validate file size (max 50MB as per backend API for audio)
      if (file.size > 50 * 1024 * 1024) {
        throw Exception('File size exceeds 50MB limit');
      }

      _isUploading = true;
      _uploadProgress = 0.1;
      notifyListeners();

      // Upload file using new backend endpoint
      _uploadProgress = 0.3;
      notifyListeners();

      print('=== Subject Provider Audio Upload ===');
      print('About to call uploadAudioFile...');
      final fileUrl = await _cloudinaryService.uploadAudioFile(file);
      print('Upload completed, received URL: $fileUrl');

      _uploadProgress = 0.8;
      notifyListeners();

      // Create lesson item with audio URL
      await uploadLessonItem(
        lessonId: lessonId,
        title: title.trim(),
        itemType: 'audio',
        itemContent: fileUrl,
      );

      _uploadProgress = 1.0;
      notifyListeners();

      // Refresh lesson items
      await fetchLessonItems(lessonId);
    } catch (error) {
      print('Error in uploadAudioItem: $error');
      throw Exception('Error uploading audio: $error');
    } finally {
      _isUploading = false;
      _uploadProgress = 0.0;
      notifyListeners();
    }
  }

  Future<void> uploadLessonItem({
    required int lessonId,
    required String title,
    required String itemType,
    required String itemContent,
  }) async {
    try {
      // Validate inputs
      if (title.isEmpty) {
        throw Exception('Title cannot be empty');
      }
      if (itemContent.isEmpty) {
        throw Exception('Item content cannot be empty');
      }
      if (!['pdf', 'audio', 'video'].contains(itemType.toLowerCase())) {
        throw Exception('Invalid item type');
      }

      // Log request data for debugging
      print('Uploading lesson item:');
      print('LessonId: $lessonId');
      print('Title: $title');
      print('Type: $itemType');
      print('Content URL: $itemContent');

      final response = await http.post(
        Uri.parse('${Globals.baseUrl}/subject/lesson/item'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'lessonId': lessonId,
          'title': title.trim(),
          'itemType': itemType.toLowerCase(),
          'itemContent': itemContent,
        }),
      );

      // Log response for debugging
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to create item');
      }
    } catch (error) {
      print('Error in uploadLessonItem: $error');
      throw Exception('Error creating item: $error');
    }
  }

  Future<void> deleteLessonItem(LessonItem item) async {
    try {
      _isDeleting = true;
      notifyListeners();

      // Delete from database
      final response = await http.delete(
        Uri.parse('${Globals.baseUrl}/subject/lesson/item/${item.id}'),
      );

      final responseData = json.decode(response.body);

      switch (response.statusCode) {
        case 200:
          // Delete from backend storage if it's a file (not a video URL)
          if (!item.itemContent.contains('youtube.com') &&
              !item.itemContent.contains('vimeo.com')) {
            // Try to delete from new backend first, fallback to Cloudinary
            final backendDeleted = await _cloudinaryService.deleteFileFromBackend(item.itemContent);
            if (!backendDeleted) {
              // Fallback to Cloudinary for existing files
              await _cloudinaryService.deleteFile(item.itemContent);
            }
          }

          // Refresh items list
          if (_selectedLesson != null) {
            await fetchLessonItems(_selectedLesson!.id);
          }
          break;

        case 404:
          throw Exception(responseData['message'] ?? 'Item not found');

        case 500:
          throw Exception(responseData['message'] ?? 'Server error occurred');

        default:
          throw Exception('Failed to delete item: ${responseData['message'] ?? 'Unknown error'}');
      }
    } catch (error) {
      throw Exception('Error deleting item: $error');
    } finally {
      _isDeleting = false;
      notifyListeners();
    }
  }
}
