import 'dart:convert';

import 'package:admin_dashboard/Constants/globals.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../Models/Subject_Template.dart';
import '../Models/semester_template.dart';

class SemestersTemplatesProvider with ChangeNotifier {
  List<SemesterTemplate> _semesters = [];
  SemesterTemplate? _selectedSemester;

  List<SemesterTemplate> get semesters => _semesters;
  SemesterTemplate? get selectedSemester => _selectedSemester;
  // Fetch semesters (in a real app, this could be an API call)
  Future<void> fetchSemesters() async {
    try {
      final response = await http.get(Uri.parse('${Globals.baseUrl}/semester/templates'),
        headers: {
          'Content-Type': 'application/json',
          // Add other headers if necessary
        },
      );
      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);
        print(jsonData);
        _semesters = jsonData.map((item) => SemesterTemplate.fromJson(item)).toList();
        _semesters.sort((a, b) => a.semesterNo.compareTo(b.semesterNo));
      } else {
        throw Exception('Failed to load semesters');

      }
    } catch (e) {
      throw Exception('Error fetching semesters: $e');
    }
    notifyListeners();
  }


  // Add a semester
  Future<void> addSemester(int semesterNumber) async {
    try {
      final response = await http.post(
        Uri.parse('${Globals.baseUrl}/semester/template'), // Adjust endpoint if needed
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'semesterNo': semesterNumber, // Send semesterNo in the request body
        }),
      );
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (response.statusCode == 201) {
        await fetchSemesters();
   // Optionally refresh the semesters list after adding
      } else {
        throw Exception('Failed to add semester');
      }
    } catch (e) {
      throw Exception('Error adding semester: $e');
    }
    notifyListeners();
  }

  // Remove a semester
  void removeSemester(int index) {

    notifyListeners();
  }
  Future<void> addSubject(int semesterId, String subjectName, String subjectCode) async {
    final url = Uri.parse("${Globals.baseUrl}/semester/template/$semesterId/add-subject");

    final body = jsonEncode({
      "name": subjectName,
      "code": subjectCode
    });

    try {
      final response = await http.post(
        url,
        body: body,
        headers: {
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);

        // Ensure response contains valid subject data
        if (responseData["data"] != null) {
          final newSubject = Subject.fromJson(responseData["data"]); // ✅ Convert to Subject
          _selectedSemester?.subjects.add(newSubject); // ✅ Add correctly
          notifyListeners();
        } else {
          throw Exception("Invalid response data");
        }
      } else {
        throw Exception("Failed to add subject: ${response.body}");
      }
    } catch (e) {
      print("Error adding subject: $e");
    }
  }


  void setSelectedSemester(SemesterTemplate semester) {
    _selectedSemester = semester;
    notifyListeners();
  }
}
