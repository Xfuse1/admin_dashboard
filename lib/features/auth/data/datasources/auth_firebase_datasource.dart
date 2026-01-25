import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/admin_user_model.dart';
import 'auth_datasource.dart';

/// Firebase implementation of authentication data source.
class AuthFirebaseDataSource implements AuthDataSource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AdminUserModel? _currentUser;

  AuthFirebaseDataSource({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  AdminUserModel? get currentUser => _currentUser;

  @override
  Future<AdminUserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw const AuthException(message: 'فشل تسجيل الدخول');
      }

      // Get admin user data from Firestore
      final doc =
          await _firestore.collection('admins').doc(credential.user!.uid).get();

      if (!doc.exists) {
        await _auth.signOut();
        throw const AuthException(message: 'هذا الحساب ليس حساب مدير');
      }

      final data = doc.data()!;
      data['id'] = doc.id;
      data['email'] = credential.user!.email;
      data['lastLoginAt'] = DateTime.now().toIso8601String();

      // Update last login
      await doc.reference.update({'lastLoginAt': FieldValue.serverTimestamp()});

      _currentUser = AdminUserModel.fromJson(data);
      return _currentUser!;
    } on FirebaseAuthException catch (e) {
      throw AuthException(message: _mapFirebaseError(e.code));
    } catch (e) {
      if (e is AuthException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _auth.signOut();
      _currentUser = null;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<AdminUserModel?> checkAuthStatus() async {
    try {
      // Give Firebase Auth a bit of time to initialize persistence on Web
      User? user = _auth.currentUser;
      if (user == null) {
        // We wait for the first emission from authStateChanges.
        // On web, this is more reliable for session recovery.
        user = await _auth.authStateChanges().first.timeout(
          const Duration(seconds: 2),
          onTimeout: () => null,
        );
      }

      if (user == null) return null;

      final doc = await _firestore.collection('admins').doc(user.uid).get();

      if (!doc.exists) {
        await _auth.signOut();
        return null;
      }

      final data = doc.data()!;
      data['id'] = doc.id;
      data['email'] = user.email;

      _currentUser = AdminUserModel.fromJson(data);
      return _currentUser;
    } catch (e) {
      return null;
    }
  }

  String _mapFirebaseError(String code) {
    return switch (code) {
      'user-not-found' => 'البريد الإلكتروني غير مسجل',
      'wrong-password' => 'كلمة المرور غير صحيحة',
      'invalid-email' => 'البريد الإلكتروني غير صالح',
      'user-disabled' => 'هذا الحساب معطل',
      'too-many-requests' => 'محاولات كثيرة، يرجى المحاولة لاحقاً',
      'network-request-failed' => 'خطأ في الاتصال بالشبكة',
      _ => 'حدث خطأ غير متوقع',
    };
  }
}
