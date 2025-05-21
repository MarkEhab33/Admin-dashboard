import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../Announcements/models/announcement_model.dart';
import '../Constants/globals.dart';

class AnnouncementsProvider with ChangeNotifier {
  List<Announcement> _generalAnnouncements = [];
  List<Announcement> _weekAnnouncements = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Announcement> get announcements => [..._generalAnnouncements, ..._weekAnnouncements];
  List<Announcement> get generalAnnouncements => [..._generalAnnouncements];
  List<Announcement> get weekAnnouncements => [..._weekAnnouncements];
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fetch all general announcements
  Future<void> fetchGeneralAnnouncements() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('${Globals.baseUrl}/announcement/general'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> responseData = jsonResponse['data'] as List<dynamic>;

        if (responseData.isNotEmpty) {
          _generalAnnouncements = responseData
              .map((announcementJson) => Announcement.fromJson(announcementJson))
              .toList();
        } else {
          _generalAnnouncements = [];
        }
      } else {
        _error = 'Failed to fetch general announcements: ${response.statusCode}';
        print(_error);
      }
    } catch (e) {
      _error = 'Error fetching general announcements: $e';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch all week announcements
  Future<void> fetchWeekAnnouncements() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('${Globals.baseUrl}/announcement/week'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> responseData = jsonResponse['data'] as List<dynamic>;

        if (responseData.isNotEmpty) {
          _weekAnnouncements = responseData
              .map((announcementJson) => Announcement.fromJson(announcementJson))
              .toList();
        } else {
          _weekAnnouncements = [];
        }
      } else {
        _error = 'Failed to fetch week announcements: ${response.statusCode}';
        print(_error);
      }
    } catch (e) {
      _error = 'Error fetching week announcements: $e';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch announcements for a specific week
  Future<List<Announcement>> fetchAnnouncementsForWeek(int weekId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('${Globals.baseUrl}/announcement/week/$weekId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> responseData = jsonResponse['data'] as List<dynamic>;

        final weekAnnouncements = responseData
            .map((announcementJson) => Announcement.fromJson(announcementJson))
            .toList();

        _isLoading = false;
        notifyListeners();
        return weekAnnouncements;
      } else {
        _error = 'Failed to fetch week announcements: ${response.statusCode}';
        print(_error);
        _isLoading = false;
        notifyListeners();
        return [];
      }
    } catch (e) {
      _error = 'Error fetching week announcements: $e';
      print(_error);
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }

  // Fetch all announcements (both general and week)
  Future<void> fetchAllAnnouncements() async {
    await fetchGeneralAnnouncements();
    await fetchWeekAnnouncements();
  }

  // Get announcement by id
  Announcement getAnnouncementById(int id) {
    return announcements.firstWhere(
      (announcement) => announcement.id == id,
      orElse: () => throw Exception('Announcement not found'),
    );
  }

  // Create a new announcement
  Future<void> createAnnouncement(Announcement announcement, {List<int>? weekIds}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Create the request body
      final Map<String, dynamic> requestBody = {
        'title': announcement.title,
        'description': announcement.description,
      };

      // Add optional fields if they exist
      if (announcement.meetingLink != null) {
        requestBody['meetingLink'] = announcement.meetingLink;
      }

      if (announcement.imageUrl != null) {
        requestBody['imageUrl'] = announcement.imageUrl;
      }

      // Add weekIds if provided
      if (weekIds != null && weekIds.isNotEmpty) {
        requestBody['weekIds'] = weekIds;
      } else if (announcement.weeks != null && announcement.weeks!.isNotEmpty) {
        // Extract weekIds from the announcement's weeks if available
        requestBody['weekIds'] = announcement.weeks!
            .map((week) => week.week.id)
            .toList();
      }

      final response = await http.post(
        Uri.parse('${Globals.baseUrl}/announcement'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Refresh the announcements list
        await fetchAllAnnouncements();
      } else {
        final errorData = json.decode(response.body);
        _error = errorData['message'] ?? 'Failed to create announcement';
        // Use logger instead of print in production
        _error != null ? debugPrint(_error) : null;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Error creating announcement: $e';
      // Use logger instead of print in production
      debugPrint(_error);
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update an existing announcement
  Future<void> updateAnnouncement(Announcement updatedAnnouncement, {List<int>? weekIds}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Create the request body
      final Map<String, dynamic> requestBody = {
        'title': updatedAnnouncement.title,
        'description': updatedAnnouncement.description,
      };

      // Add optional fields if they exist
      if (updatedAnnouncement.meetingLink != null) {
        requestBody['meetingLink'] = updatedAnnouncement.meetingLink;
      }

      if (updatedAnnouncement.imageUrl != null) {
        requestBody['imageUrl'] = updatedAnnouncement.imageUrl;
      }

      // Add weekIds if provided
      if (weekIds != null && weekIds.isNotEmpty) {
        requestBody['weekIds'] = weekIds;
      } else if (updatedAnnouncement.weeks != null && updatedAnnouncement.weeks!.isNotEmpty) {
        // Extract weekIds from the announcement's weeks if available
        requestBody['weekIds'] = updatedAnnouncement.weeks!
            .map((week) => week.week.id)
            .toList();
      }

      final response = await http.put(
        Uri.parse('${Globals.baseUrl}/announcement/${updatedAnnouncement.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        // Refresh the announcements list
        await fetchAllAnnouncements();
      } else {
        final errorData = json.decode(response.body);
        _error = errorData['message'] ?? 'Failed to update announcement';
        // Use logger instead of print in production
        _error != null ? debugPrint(_error) : null;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Error updating announcement: $e';
      // Use logger instead of print in production
      debugPrint(_error);
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete an announcement
  Future<void> deleteAnnouncement(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.delete(
        Uri.parse('${Globals.baseUrl}/announcement/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        // Refresh the announcements list
        await fetchAllAnnouncements();
      } else {
        final errorData = json.decode(response.body);
        _error = errorData['message'] ?? 'Failed to delete announcement';
        // Use logger instead of print in production
        _error != null ? debugPrint(_error) : null;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Error deleting announcement: $e';
      // Use logger instead of print in production
      debugPrint(_error);
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
