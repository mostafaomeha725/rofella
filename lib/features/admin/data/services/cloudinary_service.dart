import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class CloudinaryService {
  // تم إضافة بيانات حسابك بنجاح
  static const String cloudName = 'vckgkwp6';
  static const String uploadPreset = 'flutter_upload';

  static Future<String?> uploadImage(XFile imageFile) async {
    try {
      final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = uploadPreset;

      // Use readAsBytes() for Web compatibility instead of fromPath
      final bytes = await imageFile.readAsBytes();
      final multipartFile = http.MultipartFile.fromBytes(
        'file', 
        bytes, 
        filename: imageFile.name,
      );
      
      request.files.add(multipartFile);

      final response = await request.send().timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final jsonMap = jsonDecode(responseData);
        return jsonMap['secure_url'];
      } else {
        debugPrint('Cloudinary Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Cloudinary Exception: $e');
      return null;
    }
  }
}
