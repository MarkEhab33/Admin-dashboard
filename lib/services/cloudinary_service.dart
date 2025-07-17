import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:async';
import 'package:cloudinary_public/cloudinary_public.dart';
import '../Constants/cloudinary_config.dart';
import '../Constants/globals.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:crypto/crypto.dart' as crypto;

class CloudinaryService {
  static final CloudinaryService _instance = CloudinaryService._internal();
  late final CloudinaryPublic _cloudinary;

  factory CloudinaryService() {
    return _instance;
  }

  CloudinaryService._internal() {
    _cloudinary = CloudinaryPublic(
      CloudinaryConfig.cloudName,
      CloudinaryConfig.uploadPreset,
      cache: true,
    );
  }

  Future<String> uploadWebFile(html.File file) async {
    try {
      final String extension = file.name.split('.').last.toLowerCase();
      final nameWithoutExtension = file.name.substring(0, file.name.lastIndexOf('.'));
      
      // Determine resource type based on extension
      CloudinaryResourceType resourceType;
      if (['jpg', 'jpeg', 'png', 'gif'].contains(extension)) {
        resourceType = CloudinaryResourceType.Image;
      } else if (['pdf'].contains(extension)) {
        resourceType = CloudinaryResourceType.Raw;
      } else if (['mp4', 'wav', 'm4a','mp3'].contains(extension)) {
        resourceType = CloudinaryResourceType.Video; // Cloudinary handles audio under video type
      } else {
        throw Exception('Unsupported file type');
      }
     print("resourse Typeeee: $resourceType");
      // Convert File to Uint8List using FileReader
      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);
      
      final bytes = await reader.onLoad.first.then((_) => 
        Uint8List.fromList(reader.result as List<int>));

      // Use full filename (with extension) for PDFs, otherwise use name without extension
      final identifier = extension == 'pdf' ? file.name : nameWithoutExtension;

      // Always use name without extension for the identifier
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromBytesData(
          bytes,
          identifier: identifier,
          resourceType: resourceType,
        ),
      );
      print(response.data);
      return response.secureUrl;
    } catch (e) {
      print(e);
      throw Exception('Error uploading file to Cloudinary: $e');
    }
  }

  Future<CloudinaryResponse> _uploadToCloudinary(
    html.File file,
    String identifier,
    CloudinaryResourceType resourceType,
  ) async {
    final reader = html.FileReader();
    reader.readAsArrayBuffer(file);
    
    final bytes = await reader.onLoad.first.then((_) => 
      Uint8List.fromList(reader.result as List<int>));

    return await _cloudinary.uploadFile(
      CloudinaryFile.fromBytesData(
        bytes,
        identifier: identifier,
        resourceType: resourceType,
      ),
    );
  }

  // Utility method for PDF thumbnails
  String getPdfThumbnailUrl(String pdfUrl) {
    final uri = Uri.parse(pdfUrl);
    final pathSegments = uri.pathSegments;
    final lastSegment = pathSegments.last;
    
    return pdfUrl.replaceAll(
      lastSegment,
      'c_thumb,w_400,h_400,pg_1/$lastSegment'
    );
  }

  // Utility method for optimized audio
  String getOptimizedAudioUrl(String audioUrl) {
    return audioUrl.replaceAll(
      'upload/',
      'upload/q_auto,f_auto/'
    );
  }

  // Utility method for optimized images
  String getOptimizedImageUrl(String imageUrl, {int width = 400, int height = 400}) {
    return imageUrl.replaceAll(
      'upload/',
      'upload/c_fill,w_${width},h_${height},q_auto,f_auto/'
    );
  }

  Future<bool> deleteFile(String fileUrl) async {
    try {
      // Extract public ID and determine resource type from the URL
      final uri = Uri.parse(fileUrl);
      final pathSegments = uri.pathSegments;
      
      // Find the upload segment index
      final uploadIndex = pathSegments.indexOf('upload');
      if (uploadIndex == -1 || uploadIndex + 1 >= pathSegments.length) {
        throw Exception('Invalid Cloudinary URL format');
      }

      // Determine resource type from file extension
      final extension = uri.pathSegments.last.split('.').last.toLowerCase();
      String resourceType;
      if (['jpg', 'jpeg', 'png', 'gif'].contains(extension)) {
        resourceType = 'image';
      } else if (['pdf'].contains(extension)) {
        resourceType = 'raw';
      } else if (['mp3', 'wav', 'm4a','mp4'].contains(extension)) {
        resourceType = 'video'; // Cloudinary handles audio under video type
      } else {
        resourceType = 'raw'; // Default to image if unknown
      }
      
      // Extract public ID by finding everything after the version number
      final versionMatch = RegExp(r'v\d+/(.+)$').firstMatch(fileUrl);
      var publicId = versionMatch?.group(1) ?? '';
      
      // Remove any query parameters or transformations if present
      if (publicId.contains('?')) {
        publicId = publicId.split('?')[0];
      }
      if (publicId.startsWith('q_auto,f_auto/')) {
        publicId = publicId.substring('q_auto,f_auto/'.length);
      }

      // URL decode the public ID
      publicId = Uri.decodeComponent(publicId);

      // Remove extension only if it's not a PDF
      if (extension != 'pdf') {
        publicId = publicId.substring(0, publicId.lastIndexOf('.'));
      }
      
      print('URL being processed: $fileUrl'); // Debug print
      print('Resource Type: $resourceType'); // Debug print
      print('Public ID: $publicId'); // Debug print
      
      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final signature = _generateSignature(publicId, timestamp);
      
      final url = 'https://api.cloudinary.com/v1_1/${CloudinaryConfig.cloudName}/$resourceType/destroy';
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'public_id': publicId,
          'signature': signature,
          'api_key': CloudinaryConfig.apiKey,
          'timestamp': timestamp.toString(),
        },
      );

      print('Response Status: ${response.statusCode}'); // Debug print
      print('Response Body: ${response.body}'); // Debug print

      final responseData = json.decode(response.body);
      return response.statusCode == 200 && responseData['result'] != 'not found';
    } catch (e) {
      print('Error deleting file from Cloudinary: $e');
      return false;
    }
  }

  String _generateSignature(String publicId, int timestamp) {
    final message = 'public_id=$publicId&timestamp=$timestamp${CloudinaryConfig.apiSecret}';
    return crypto.sha1.convert(utf8.encode(message)).toString();
  }

  // New methods using backend upload endpoints
  Future<String> uploadPdfFile(html.File file) async {
    try {
      print('=== PDF Upload Debug ===');
      print('File name: ${file.name}');
      print('File size: ${file.size} bytes');
      print('File type: ${file.type}');
      print('Base URL: ${Globals.baseUrl}');
      print('Full Upload URL: ${Globals.baseUrl}/upload/pdf');

      final formData = html.FormData();
      formData.appendBlob('file', file, file.name);

      final request = html.HttpRequest();
      request.open('POST', '${Globals.baseUrl}/upload/pdf');

      // Create a completer to handle the async response
      final completer = Completer<String>();

      request.onLoad.listen((event) {
        print('Request completed with status: ${request.status}');
        print('Response text: ${request.responseText}');

        if (request.status == 200 || request.status == 201) {
          try {
            final response = json.decode(request.responseText!);
            print('Parsed response: $response');
            print('File URL: ${response['url']}');
            completer.complete(response['url']);
          } catch (parseError) {
            print('Error parsing response JSON: $parseError');
            completer.completeError(Exception('Failed to parse response: $parseError'));
          }
        } else {
          try {
            final errorResponse = json.decode(request.responseText!);
            print('Error response: $errorResponse');
            completer.completeError(Exception(errorResponse['message'] ?? 'Upload failed with status ${request.status}'));
          } catch (parseError) {
            print('Error parsing error response: $parseError');
            completer.completeError(Exception('Upload failed with status ${request.status}: ${request.responseText}'));
          }
        }
      });

      request.onError.listen((event) {
        print('Network error occurred: $event');
        completer.completeError(Exception('Network error during upload'));
      });

      request.onTimeout.listen((event) {
        print('Request timeout occurred');
        completer.completeError(Exception('Upload timeout'));
      });

      print('Sending request...');
      request.send(formData);
      return await completer.future;
    } catch (e) {
      print('Exception in uploadPdfFile: $e');
      throw Exception('Error uploading PDF: $e');
    }
  }

  Future<String> uploadAudioFile(html.File file) async {
    try {
      print('=== Audio Upload Debug ===');
      print('File name: ${file.name}');
      print('File size: ${file.size} bytes');
      print('File type: ${file.type}');
      print('Upload URL: ${Globals.baseUrl}/upload/record');

      final formData = html.FormData();
      formData.appendBlob('file', file, file.name);

      final request = html.HttpRequest();
      request.open('POST', '${Globals.baseUrl}/upload/record');

      // Create a completer to handle the async response
      final completer = Completer<String>();

      request.onLoad.listen((event) {
        print('Request completed with status: ${request.status}');
        print('Response text: ${request.responseText}');

        if (request.status == 200 || request.status == 201) {
          try {
            final response = json.decode(request.responseText!);
            print('Parsed response: $response');
            print('File URL: ${response['url']}');
            completer.complete(response['url']);
          } catch (parseError) {
            print('Error parsing response JSON: $parseError');
            completer.completeError(Exception('Failed to parse response: $parseError'));
          }
        } else {
          try {
            final errorResponse = json.decode(request.responseText!);
            print('Error response: $errorResponse');
            completer.completeError(Exception(errorResponse['message'] ?? 'Upload failed with status ${request.status}'));
          } catch (parseError) {
            print('Error parsing error response: $parseError');
            completer.completeError(Exception('Upload failed with status ${request.status}: ${request.responseText}'));
          }
        }
      });

      request.onError.listen((event) {
        print('Network error occurred: $event');
        completer.completeError(Exception('Network error during upload'));
      });

      request.onTimeout.listen((event) {
        print('Request timeout occurred');
        completer.completeError(Exception('Upload timeout'));
      });

      print('Sending request...');
      request.send(formData);
      return await completer.future;
    } catch (e) {
      print('Exception in uploadAudioFile: $e');
      throw Exception('Error uploading audio: $e');
    }
  }

  Future<String> uploadImageFile(html.File file) async {
    try {
      print('=== Image Upload Debug ===');
      print('File name: ${file.name}');
      print('File size: ${file.size} bytes');
      print('File type: ${file.type}');
      print('Upload URL: ${Globals.baseUrl}/upload/user-photo');

      // Validate file type
      final validImageTypes = ['image/jpeg', 'image/png', 'image/webp'];
      if (!validImageTypes.contains(file.type)) {
        throw Exception('Invalid file type. Allowed types: JPEG, PNG, WebP');
      }

      // Validate file size (max 5MB as per backend API for user photos)
      if (file.size > 5 * 1024 * 1024) {
        throw Exception('File size exceeds 5MB limit');
      }

      final formData = html.FormData();
      formData.appendBlob('file', file, file.name);

      final request = html.HttpRequest();
      request.open('POST', '${Globals.baseUrl}/upload/user-photo');

      // Create a completer to handle the async response
      final completer = Completer<String>();

      request.onLoad.listen((event) {
        print('Request completed with status: ${request.status}');
        print('Response text: ${request.responseText}');

        if (request.status == 200 || request.status == 201) {
          try {
            final response = json.decode(request.responseText!);
            final url = response['url'];
            print('Upload successful, URL: $url');
            completer.complete(url);
          } catch (parseError) {
            print('Error parsing success response: $parseError');
            completer.completeError(Exception('Error parsing upload response'));
          }
        } else {
          try {
            final errorResponse = json.decode(request.responseText!);
            print('Upload failed: ${errorResponse['message']}');
            completer.completeError(Exception(errorResponse['message'] ?? 'Upload failed with status ${request.status}'));
          } catch (parseError) {
            print('Error parsing error response: $parseError');
            completer.completeError(Exception('Upload failed with status ${request.status}: ${request.responseText}'));
          }
        }
      });

      request.onError.listen((event) {
        print('Network error occurred: $event');
        completer.completeError(Exception('Network error during upload'));
      });

      request.onTimeout.listen((event) {
        print('Request timeout occurred');
        completer.completeError(Exception('Upload timeout'));
      });

      print('Sending request...');
      request.send(formData);
      return await completer.future;
    } catch (e) {
      print('Exception in uploadImageFile: $e');
      throw Exception('Error uploading image: $e');
    }
  }

  // Delete file using backend endpoint
  Future<bool> deleteFileFromBackend(String fileUrl) async {
    try {
      // Extract filename from URL
      final uri = Uri.parse(fileUrl);
      final pathSegments = uri.pathSegments;
      final filename = pathSegments.last;

      // Determine file type from URL path
      String fileType = 'additional-documents'; // default
      if (pathSegments.contains('pdfs')) {
        fileType = 'pdfs';
      } else if (pathSegments.contains('records')) {
        fileType = 'records';
      } else if (pathSegments.contains('user-photos')) {
        fileType = 'user-photos';
      } else if (pathSegments.contains('ids')) {
        fileType = 'ids';
      }

      final response = await http.delete(
        Uri.parse(Globals.getApiUrl('/upload/$fileType/$filename')),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting file from backend: $e');
      return false;
    }
  }
}

























