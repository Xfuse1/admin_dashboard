import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/admin_model.dart';
import 'admins_datasource.dart';

/// Firebase implementation of Admins datasource.
class AdminsFirebaseDataSource implements AdminsDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  AdminsFirebaseDataSource({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  @override
  Future<List<AdminModel>> getAdmins() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('role', whereIn: ['admin', 'superAdmin']).get();

      final admins = snapshot.docs
          .map((doc) => AdminModel.fromFirestore(doc.id, doc.data()))
          .toList();

      // Sort by creation date (newest first)
      admins.sort((a, b) {
        if (a.createdAt == null || b.createdAt == null) return 0;
        return b.createdAt!.compareTo(a.createdAt!);
      });

      return admins;
    } catch (e) {
      throw ServerException(message: 'فشل تحميل المسؤولين: $e');
    }
  }

  @override
  Future<AdminModel> addAdmin({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // Create account in Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user!.uid;

      // Save admin data in Firestore
      final adminData = {
        'name': name,
        'email': email,
        'role': 'admin',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': _auth.currentUser?.uid,
      };

      await _firestore.collection('users').doc(uid).set(adminData);

      return AdminModel(
        id: uid,
        name: name,
        email: email,
        role: 'admin',
        isActive: true,
        createdAt: DateTime.now(),
        createdBy: _auth.currentUser?.uid,
      );
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          throw const ServerException(
              message: 'البريد الإلكتروني مستخدم بالفعل');
        case 'weak-password':
          throw const ServerException(message: 'كلمة المرور ضعيفة جداً');
        case 'invalid-email':
          throw const ServerException(message: 'البريد الإلكتروني غير صالح');
        default:
          throw ServerException(message: 'خطأ: ${e.message}');
      }
    } catch (e) {
      throw ServerException(message: 'فشل إضافة المسؤول: $e');
    }
  }

  @override
  Future<void> deleteAdmin(String adminId) async {
    try {
      await _firestore.collection('users').doc(adminId).delete();
    } catch (e) {
      throw ServerException(message: 'فشل حذف المسؤول: $e');
    }
  }
}
