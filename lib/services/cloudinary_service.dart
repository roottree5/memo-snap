// lib/services/cloudinary_service.dart
import 'package:cloudinary_public/cloudinary_public.dart';
import 'dart:io';

class CloudinaryService {
  static final cloudinary = CloudinaryPublic(
    'dpvkjvz0v',  // Cloudinary 콘솔에서 확인
    'ufx2o6uw',  // Unsigned upload preset
    cache: false,
  );

  static Future<String> uploadImage(File image) async {
    try {
      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          image.path,
          folder: 'memosnap_diary_images',  // Cloudinary에 저장될 폴더명
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      return response.secureUrl;  // HTTPS URL 반환
    } catch (e) {
      print('Cloudinary 업로드 에러: $e');
      throw Exception('이미지 업로드 실패');
    }
  }

  static Future<List<String>> uploadMultipleImages(List<File> images) async {
    try {
      List<String> imageUrls = [];
      for (var image in images) {
        String url = await uploadImage(image);
        imageUrls.add(url);
      }
      return imageUrls;
    } catch (e) {
      print('다중 이미지 업로드 에러: $e');
      throw Exception('이미지 업로드 실패');
    }
  }
}