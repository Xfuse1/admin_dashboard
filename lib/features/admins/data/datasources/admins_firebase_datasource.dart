import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/admin_model.dart';
import 'admins_datasource.dart';

/// Firebase implementation of Admins datasource.
///
/// Uses Cloud Functions for create/delete to avoid signing out the current user
/// and to properly manage Firebase Auth accounts via Admin SDK.
class AdminsFirebaseDataSource implements AdminsDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  AdminsFirebaseDataSource({
    FirebaseFirestore? firestore,
    FirebaseFunctions? functions,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _functions = functions ?? FirebaseFunctions.instance;

  @override
  Future<List<AdminModel>> getAdmins() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('role', whereIn: ['admin', 'superAdmin']).get();

      final admins = snapshot.docs
          .map((doc) => AdminModel.fromFirestore(doc.id, doc.data()))
          .toList()
        // Sort locally: nulls last, newest first
        ..sort((a, b) {
          if (a.createdAt == null && b.createdAt == null) return 0;
          if (a.createdAt == null) return 1;
          if (b.createdAt == null) return -1;
          return b.createdAt!.compareTo(a.createdAt!);
        });

      return admins;
    } on FirebaseException catch (e) {
      throw ServerException(
        message: 'فشل تحميل المسؤولين: ${e.message}',
        code: e.code,
      );
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
      final callable = _functions.httpsCallable('createAdmin');
      final result = await callable.call<Map<String, dynamic>>({
        'name': name,
        'email': email,
        'password': password,
      });

      final data = result.data;
      final adminData = Map<String, dynamic>.from(data['admin'] as Map);

      return AdminModel(
        id: adminData['id'] as String,
        name: adminData['name'] as String,
        email: adminData['email'] as String,
        role: adminData['role'] as String,
        isActive: adminData['isActive'] as bool? ?? true,
        createdAt: DateTime.now(),
        createdBy: adminData['createdBy'] as String?,
      );
    } on FirebaseFunctionsException catch (e) {
      throw ServerException(
        message: e.message ?? 'فشل إضافة المسؤول',
        code: e.code,
      );
    } catch (e) {
      throw ServerException(message: 'فشل إضافة المسؤول: $e');
    }
  }

  @override
  Future<void> deleteAdmin(String adminId) async {
    try {
      final callable = _functions.httpsCallable('deleteAdmin');
      await callable.call<Map<String, dynamic>>({
        'adminId': adminId,
      });
    } on FirebaseFunctionsException catch (e) {
      throw ServerException(
        message: e.message ?? 'فشل حذف المسؤول',
        code: e.code,
      );
    } catch (e) {
      throw ServerException(message: 'فشل حذف المسؤول: $e');
    }
  }
}
