import 'dart:convert';
import 'package:admin_dashboard/Constants/globals.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../Models/subject.dart';
import '../Models/lesson_item.dart';

class LessonProvider with ChangeNotifier {
  List<Lesson> _lessons = [];
  Lesson? _selectedLesson;
  bool _isLoading = false;
  List<LessonItem> _items = [];

  List<Lesson> get lessons => _lessons;
  Lesson? get selectedLesson => _selectedLesson;
  bool get isLoading => _isLoading;
  List<LessonItem> get items => _items;

  Future<void> fetchLessons(int subjectId) async {
    _isLoading = true;
    notifyListeners();

    final url = Uri.parse('${Globals.baseUrl}/subject/$subjectId/lessons');
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
}
