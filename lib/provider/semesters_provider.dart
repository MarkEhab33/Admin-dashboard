import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../Constants/globals.dart';
import '../Models/semester.dart';

class SemestersProvider with ChangeNotifier {
  List<Semester> _semesters = [];
  bool _isLoading = false;
  String? _error;

  List<Semester> get semesters => _semesters;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchSemesters() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('${Globals.baseUrl}/semester/all'),
        headers: {'Content-Type': 'application/json'},
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> responseData = jsonResponse['data'] as List<dynamic>;
        
        if (responseData.isNotEmpty) {
          _semesters = responseData
              .map((semesterJson) => Semester.fromJson(semesterJson))
              .toList();
        } else {
          _semesters = [];
          _error = 'No semester data available';
          print(_error);
        }
      } else {
        _error = 'Failed to fetch semesters: ${response.statusCode}';
        print(_error);
      }
    } catch (e, stackTrace) {
      _error = 'Error fetching semesters: $e';
      print(_error);
      print('Stack trace: $stackTrace');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}


