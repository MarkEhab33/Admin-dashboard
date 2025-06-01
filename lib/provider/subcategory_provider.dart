import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../Constants/globals.dart';
import '../Models/Subject_Template.dart';

class SubcategoryProvider with ChangeNotifier {
  List<SubCategory> _subcategories = [];
  bool _isLoading = false;
  String _error = '';

  List<SubCategory> get subcategories => _subcategories;
  bool get isLoading => _isLoading;
  String get error => _error;

  // Fetch subcategories for a specific subject
  Future<void> fetchSubcategories(int subjectId) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      final response = await http.get(
        Uri.parse('${Globals.baseUrl}/subject/$subjectId/subcategories'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null && data['data']['subCategories'] != null) {
          _subcategories = (data['data']['subCategories'] as List)
              .map((item) => SubCategory.fromJson(item))
              .toList();
        } else {
          _subcategories = [];
        }
        _error = '';
      } else {
        _error = 'Failed to load subcategories: ${response.body}';
      }
    } catch (e) {
      _error = 'Exception fetching subcategories: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add a new subcategory
  Future<bool> addSubcategory(int subjectId, String name) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      final response = await http.post(
        Uri.parse('${Globals.baseUrl}/subject/$subjectId/subcategory'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'name': name,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Refresh the subcategories list
        await fetchSubcategories(subjectId);
        return true;
      } else {
        _error = 'Failed to add subcategory: ${response.body}';
        return false;
      }
    } catch (e) {
      _error = 'Exception adding subcategory: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete a subcategory
  Future<bool> deleteSubcategory(int subjectId, int subcategoryId) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      final response = await http.delete(
        Uri.parse('${Globals.baseUrl}/subject/$subjectId/subcategory/$subcategoryId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Refresh the subcategories list
        await fetchSubcategories(subjectId);
        return true;
      } else {
        _error = 'Failed to delete subcategory: ${response.body}';
        return false;
      }
    } catch (e) {
      _error = 'Exception deleting subcategory: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear subcategories
  void clearSubcategories() {
    _subcategories = [];
    _error = '';
    notifyListeners();
  }
}
