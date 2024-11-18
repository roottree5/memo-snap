// lib/providers/diary_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import '../services/cloudinary_service.dart';

class Diary {
  final String id;
  final String userId;
  final String content;
  final List<String> photoUrls;
  final DateTime createdAt;
  final String title;
  final String preview;
  final String date;

  Diary({
    required this.id,
    required this.userId,
    required this.content,
    required this.photoUrls,
    required this.createdAt,
    required this.title,
    required this.preview,
    required this.date,
  });

  factory Diary.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Diary(
      id: doc.id,
      userId: data['userId'] ?? '',
      content: data['content'] ?? '',
      photoUrls: List<String>.from(data['photoUrls'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      title: '일기 ${doc.id}',
      preview: data['content'] ?? '',
      date: (data['createdAt'] as Timestamp).toDate().toString().substring(0, 10).replaceAll('-', '.'),
    );
  }

  Diary copyWith({
    String? content,
    List<String>? photoUrls,
    String? title,
    String? preview,
  }) {
    return Diary(
      id: this.id,
      userId: this.userId,
      content: content ?? this.content,
      photoUrls: photoUrls ?? this.photoUrls,
      createdAt: this.createdAt,
      title: title ?? this.title,
      preview: preview ?? this.preview,
      date: this.date,
    );
  }
}

class DiaryProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Diary> _diaries = [];
  bool _isLoading = false;
  StreamSubscription<QuerySnapshot>? _subscription;

  List<Diary> get diaries => [..._diaries];
  bool get isLoading => _isLoading;

  Future<void> createDiary({
    required String userId,
    required String content,
    required List<File> photos,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      List<String> photoUrls = [];
      if (photos.isNotEmpty) {
        photoUrls = await CloudinaryService.uploadMultipleImages(photos);
      }

      DocumentReference docRef = await _firestore.collection('diaries').add({
        'userId': userId,
        'content': content,
        'photoUrls': photoUrls,
        'createdAt': FieldValue.serverTimestamp(),
      });

      final newDiary = Diary(
        id: docRef.id,
        userId: userId,
        content: content,
        photoUrls: photoUrls,
        createdAt: DateTime.now(),
        title: '일기 ${_diaries.length + 1}',
        preview: content,
        date: DateTime.now().toString().substring(0, 10).replaceAll('-', '.'),
      );

      _diaries.insert(0, newDiary);
      notifyListeners();
    } catch (e) {
      print('일기 생성 에러: $e');
      throw Exception('일기 생성 실패');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateDiary({
    required String diaryId,
    required String content,
    required List<String> existingPhotos,
    List<File>? newPhotos,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      List<String> allPhotoUrls = [...existingPhotos];

      if (newPhotos != null && newPhotos.isNotEmpty) {
        List<String> newPhotoUrls = await CloudinaryService.uploadMultipleImages(newPhotos);
        allPhotoUrls.addAll(newPhotoUrls);
      }

      await _firestore.collection('diaries').doc(diaryId).update({
        'content': content,
        'photoUrls': allPhotoUrls,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      int index = _diaries.indexWhere((d) => d.id == diaryId);
      if (index != -1) {
        _diaries[index] = _diaries[index].copyWith(
          content: content,
          photoUrls: allPhotoUrls,
          preview: content,
        );
        notifyListeners();
      }
    } catch (e) {
      print('일기 수정 에러: $e');
      throw Exception('일기 수정 실패');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void deleteDiary(String id) async {
    try {
      await _firestore.collection('diaries').doc(id).delete();
      _diaries.removeWhere((diary) => diary.id == id);
      notifyListeners();
    } catch (e) {
      print('일기 삭제 에러: $e');
      throw Exception('일기 삭제 실패');
    }
  }

  void subscribeToUserDiaries(String userId) {
    _subscription = _firestore
        .collection('diaries')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      _diaries = snapshot.docs
          .map((doc) => Diary.fromFirestore(doc))
          .toList();
      notifyListeners();
    });
  }

  void unsubscribeFromUserDiaries() {
    _subscription?.cancel();
    _subscription = null;
    _diaries = [];
    notifyListeners();
  }

  @override
  void dispose() {
    unsubscribeFromUserDiaries();
    super.dispose();
  }
}