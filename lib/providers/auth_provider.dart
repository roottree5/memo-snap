// lib/providers/auth_provider.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? get user => _auth.currentUser;

  // 일반 이메일/비밀번호 로그인
  Future<bool> signInWithEmail(String email, String password) async {
    try {
      print('Attempting login for email: ${email.replaceAll(RegExp(r'(?<=.{3}).(?=.*@)'), '*')}');
      
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      
      final currentUser = userCredential.user;
      
      if (currentUser != null) {
        print('Successfully authenticated user: ${currentUser.uid}');
        
        try {
          final docSnapshot = await _firestore
              .collection('users')
              .doc(currentUser.uid)
              .get();

          if (!docSnapshot.exists) {
            print('Creating new user document in Firestore');
            await _firestore
                .collection('users')
                .doc(currentUser.uid)
                .set({
              'email': currentUser.email,
              'createdAt': FieldValue.serverTimestamp(),
              'lastLogin': FieldValue.serverTimestamp(),
            });
          } else {
            print('Updating existing user last login time');
            await _firestore
                .collection('users')
                .doc(currentUser.uid)
                .update({
              'lastLogin': FieldValue.serverTimestamp(),
            });
          }

          notifyListeners();
          return true;
        } catch (e) {
          print('Firestore 업데이트 에러: $e');
          return true;
        }
      }
      print('No user returned from Firebase Auth');
      return false;
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('Unexpected error during login: $e');
      rethrow;
    }
  }

  // Google 로그인
  Future<User?> signInWithGoogle() async {
    try {
      await _googleSignIn.signOut();
      
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential result = await _auth.signInWithCredential(credential);
      final currentUser = result.user;

      if (currentUser != null) {
        try {
          final docSnapshot = await _firestore.collection('users').doc(currentUser.uid).get();
          
          if (!docSnapshot.exists) {
            await _firestore.collection('users').doc(currentUser.uid).set({
              'email': currentUser.email,
              'name': currentUser.displayName,
              'photoUrl': currentUser.photoURL,
              'createdAt': FieldValue.serverTimestamp(),
              'lastLogin': FieldValue.serverTimestamp(),
            });
          } else {
            await _firestore.collection('users').doc(currentUser.uid).update({
              'lastLogin': FieldValue.serverTimestamp(),
              'photoUrl': currentUser.photoURL,
            });
          }
        } catch (e) {
          print('Error updating user data: $e');
        }
      }

      notifyListeners();
      return currentUser;
    } catch (e) {
      print('Google sign in error: $e');
      rethrow;
    }
  }

  // 회원가입
  Future<User?> signUp(String email, String password, String name) async {
    try {
      print('Starting signup process...');
      
      // 회원가입 시도
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      
      final currentUser = result.user;
      print('User created in Firebase Auth: ${currentUser?.uid}');
      
      if (currentUser != null) {
        try {
          // 사용자 프로필 이름 업데이트
          await currentUser.updateDisplayName(name);
          print('Display name updated');
          
          // Firestore에 사용자 정보 저장
          await _firestore.collection('users').doc(currentUser.uid).set({
            'email': email,
            'name': name,
            'createdAt': FieldValue.serverTimestamp(),
            'lastLogin': FieldValue.serverTimestamp(),
            'uid': currentUser.uid,
          });
          
          print('User data saved to Firestore successfully');
          
          // 성공적으로 처리됨을 알림
          notifyListeners();
          return currentUser;
        } catch (e) {
          print('Error during user data setup: $e');
          try {
            // 실패 시 사용자 정리
            await currentUser.delete();
            print('Cleaned up user due to data setup error');
          } catch (deleteError) {
            print('Error during user cleanup: $deleteError');
          }
          rethrow;
        }
      } else {
        print('User creation failed - null user returned');
        throw Exception('회원가입에 실패했습니다.');
      }
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException during signup: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('Unexpected error during signup: $e');
      rethrow;
    }
  }

  // 로그아웃
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
      notifyListeners();
    } catch (e) {
      print('Sign out error: $e');
      rethrow;
    }
  }

  // 비밀번호 재설정 이메일 전송
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Password reset error: $e');
      rethrow;
    }
  }

  // 현재 사용자 상태 확인
  Future<void> checkCurrentUser() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      try {
        final docSnapshot = await _firestore.collection('users').doc(currentUser.uid).get();
        if (!docSnapshot.exists) {
          await _firestore.collection('users').doc(currentUser.uid).set({
            'email': currentUser.email,
            'name': currentUser.displayName,
            'createdAt': FieldValue.serverTimestamp(),
            'lastLogin': FieldValue.serverTimestamp(),
            'uid': currentUser.uid,
          });
        }
      } catch (e) {
        print('Error checking user data: $e');
      }
    }
    notifyListeners();
  }

  // 사용자 정보 업데이트
  Future<void> updateUserProfile(String name) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        await currentUser.updateDisplayName(name);
        await _firestore.collection('users').doc(currentUser.uid).update({
          'name': name,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        notifyListeners();
      }
    } catch (e) {
      print('Update profile error: $e');
      rethrow;
    }
  }

  // 로그인 상태 확인
  bool isUserLoggedIn() {
    final currentUser = _auth.currentUser;
    return currentUser != null && currentUser.email != null;
  }

  // 이메일 검증 상태 확인
  bool isEmailVerified() {
    final currentUser = _auth.currentUser;
    return currentUser?.emailVerified ?? false;
  }
}