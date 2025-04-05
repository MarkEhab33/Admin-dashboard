import 'dart:html' as html;
import 'dart:typed_data';
import 'package:cloudinary_public/cloudinary_public.dart';
import '../Constants/cloudinary_config.dart';
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
}

























