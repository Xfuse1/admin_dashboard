import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/vehicle_entity.dart';
import 'fleet_datasource.dart';

/// Firebase implementation of [FleetDataSource].
class FleetFirebaseDataSource implements FleetDataSource {
  final FirebaseFirestore _firestore;
  static const String _collection = 'vehicles';

  FleetFirebaseDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _vehiclesRef =>
      _firestore.collection(_collection);

  @override
  Future<List<VehicleEntity>> getVehicles({
    VehicleStatus? status,
    VehicleType? type,
    String? assignedDriverId,
    String? lastVehicleId,
    int limit = 20,
  }) async {
    Query<Map<String, dynamic>> query =
        _vehiclesRef.orderBy('createdAt', descending: true);

    if (status != null) {
      query = query.where('status', isEqualTo: status.value);
    }

    if (type != null) {
      query = query.where('type', isEqualTo: type.value);
    }

    if (assignedDriverId != null) {
      query = query.where('assignedDriverId', isEqualTo: assignedDriverId);
    }

    if (lastVehicleId != null) {
      final lastDoc = await _vehiclesRef.doc(lastVehicleId).get();
      if (lastDoc.exists) {
        query = query.startAfterDocument(lastDoc);
      }
    }

    final snapshot = await query.limit(limit).get();
    return snapshot.docs.map((doc) => _vehicleFromFirestore(doc)).toList();
  }

  @override
  Future<VehicleEntity> getVehicleById(String id) async {
    final doc = await _vehiclesRef.doc(id).get();
    if (!doc.exists) {
      throw Exception('Vehicle not found');
    }
    return _vehicleFromFirestore(doc);
  }

  @override
  Future<VehicleEntity> addVehicle(VehicleEntity vehicle) async {
    final docRef = _vehiclesRef.doc();
    final now = DateTime.now();
    final newVehicle = vehicle.copyWith(
      id: docRef.id,
      createdAt: now,
      updatedAt: now,
    );

    await docRef.set(_vehicleToFirestore(newVehicle));
    return newVehicle;
  }

  @override
  Future<VehicleEntity> updateVehicle(VehicleEntity vehicle) async {
    final updatedVehicle = vehicle.copyWith(updatedAt: DateTime.now());
    await _vehiclesRef
        .doc(vehicle.id)
        .update(_vehicleToFirestore(updatedVehicle));
    return updatedVehicle;
  }

  @override
  Future<void> deleteVehicle(String id) async {
    await _vehiclesRef.doc(id).delete();
  }

  @override
  Future<VehicleEntity> updateVehicleStatus(
    String id,
    VehicleStatus status,
  ) async {
    await _vehiclesRef.doc(id).update({
      'status': status.value,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return getVehicleById(id);
  }

  @override
  Future<VehicleEntity> assignDriver(
    String vehicleId,
    String driverId,
    String driverName,
  ) async {
    await _vehiclesRef.doc(vehicleId).update({
      'assignedDriverId': driverId,
      'assignedDriverName': driverName,
      'status': VehicleStatus.inUse.value,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return getVehicleById(vehicleId);
  }

  @override
  Future<VehicleEntity> unassignDriver(String vehicleId) async {
    await _vehiclesRef.doc(vehicleId).update({
      'assignedDriverId': null,
      'assignedDriverName': null,
      'status': VehicleStatus.available.value,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return getVehicleById(vehicleId);
  }

  @override
  Future<void> updateVehicleLocation(
    String id,
    double latitude,
    double longitude,
  ) async {
    await _vehiclesRef.doc(id).update({
      'latitude': latitude,
      'longitude': longitude,
      'lastLocationUpdate': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<FleetStatsEntity> getFleetStats() async {
    final snapshot = await _vehiclesRef.get();
    final vehicles =
        snapshot.docs.map((doc) => _vehicleFromFirestore(doc)).toList();

    final now = DateTime.now();
    int available = 0;
    int inUse = 0;
    int maintenance = 0;
    int outOfService = 0;
    int expiredLicense = 0;
    int expiredInsurance = 0;
    int maintenanceDue = 0;
    double totalKm = 0;
    final Map<VehicleType, int> byType = {};

    for (final vehicle in vehicles) {
      // Count by status
      switch (vehicle.status) {
        case VehicleStatus.available:
          available++;
        case VehicleStatus.inUse:
          inUse++;
        case VehicleStatus.maintenance:
          maintenance++;
        case VehicleStatus.outOfService:
          outOfService++;
      }

      // Count by type
      byType[vehicle.type] = (byType[vehicle.type] ?? 0) + 1;

      // Count alerts
      if (vehicle.licenseExpiry != null &&
          vehicle.licenseExpiry!.isBefore(now)) {
        expiredLicense++;
      }
      if (vehicle.insuranceExpiry != null &&
          vehicle.insuranceExpiry!.isBefore(now)) {
        expiredInsurance++;
      }
      if (vehicle.nextMaintenanceDate != null &&
          vehicle.nextMaintenanceDate!.isBefore(now)) {
        maintenanceDue++;
      }

      totalKm += vehicle.totalKilometers;
    }

    return FleetStatsEntity(
      totalVehicles: vehicles.length,
      availableVehicles: available,
      inUseVehicles: inUse,
      maintenanceVehicles: maintenance,
      outOfServiceVehicles: outOfService,
      vehiclesWithExpiredLicense: expiredLicense,
      vehiclesWithExpiredInsurance: expiredInsurance,
      vehiclesDueForMaintenance: maintenanceDue,
      totalKilometersDriven: totalKm,
      vehiclesByType: byType,
    );
  }

  @override
  Stream<List<VehicleEntity>> watchVehicles({VehicleStatus? status}) {
    Query<Map<String, dynamic>> query =
        _vehiclesRef.orderBy('createdAt', descending: true);

    if (status != null) {
      query = query.where('status', isEqualTo: status.value);
    }

    return query.snapshots().map(
          (snapshot) =>
              snapshot.docs.map((doc) => _vehicleFromFirestore(doc)).toList(),
        );
  }

  @override
  Future<List<VehicleEntity>> searchVehicles(String query) async {
    final lowerQuery = query.toLowerCase();

    // Search by plate number
    final plateSnapshot = await _vehiclesRef
        .where('plateNumber', isGreaterThanOrEqualTo: query.toUpperCase())
        .where('plateNumber',
            isLessThanOrEqualTo: '${query.toUpperCase()}\uf8ff')
        .limit(10)
        .get();

    // Search by brand
    final brandSnapshot = await _vehiclesRef
        .where('brand', isGreaterThanOrEqualTo: lowerQuery)
        .where('brand', isLessThanOrEqualTo: '$lowerQuery\uf8ff')
        .limit(10)
        .get();

    // Combine and deduplicate results
    final Map<String, VehicleEntity> results = {};
    for (final doc in plateSnapshot.docs) {
      final vehicle = _vehicleFromFirestore(doc);
      results[vehicle.id] = vehicle;
    }
    for (final doc in brandSnapshot.docs) {
      final vehicle = _vehicleFromFirestore(doc);
      results[vehicle.id] = vehicle;
    }

    return results.values.toList();
  }

  @override
  Future<List<VehicleEntity>> getVehiclesWithAlerts() async {
    final snapshot = await _vehiclesRef.get();
    final vehicles =
        snapshot.docs.map((doc) => _vehicleFromFirestore(doc)).toList();

    return vehicles.where((v) => v.hasAlerts).toList();
  }

  /// Converts Firestore document to [VehicleEntity].
  VehicleEntity _vehicleFromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return VehicleEntity(
      id: doc.id,
      plateNumber: data['plateNumber'] ?? '',
      type: VehicleType.fromValue(data['type'] ?? 'motorcycle'),
      brand: data['brand'] ?? '',
      model: data['model'] ?? '',
      year: data['year'] ?? DateTime.now().year,
      color: data['color'] ?? '',
      status: VehicleStatus.fromValue(data['status'] ?? 'available'),
      assignedDriverId: data['assignedDriverId'],
      assignedDriverName: data['assignedDriverName'],
      latitude: data['latitude']?.toDouble(),
      longitude: data['longitude']?.toDouble(),
      lastLocationUpdate: _parseTimestamp(data['lastLocationUpdate']),
      imageUrl: data['imageUrl'],
      licenseExpiry: _parseTimestamp(data['licenseExpiry']),
      insuranceExpiry: _parseTimestamp(data['insuranceExpiry']),
      lastMaintenanceDate: _parseTimestamp(data['lastMaintenanceDate']),
      nextMaintenanceDate: _parseTimestamp(data['nextMaintenanceDate']),
      totalKilometers: data['totalKilometers']?.toDouble() ?? 0.0,
      fuelType: data['fuelType'] ?? 'petrol',
      fuelCapacity: data['fuelCapacity']?.toDouble(),
      currentFuelLevel: data['currentFuelLevel']?.toDouble(),
      maxLoadCapacity: data['maxLoadCapacity']?.toDouble(),
      notes: data['notes'],
      createdAt: _parseTimestamp(data['createdAt']) ?? DateTime.now(),
      updatedAt: _parseTimestamp(data['updatedAt']) ?? DateTime.now(),
    );
  }

  /// Converts [VehicleEntity] to Firestore document.
  Map<String, dynamic> _vehicleToFirestore(VehicleEntity vehicle) {
    return {
      'plateNumber': vehicle.plateNumber,
      'type': vehicle.type.value,
      'brand': vehicle.brand,
      'model': vehicle.model,
      'year': vehicle.year,
      'color': vehicle.color,
      'status': vehicle.status.value,
      'assignedDriverId': vehicle.assignedDriverId,
      'assignedDriverName': vehicle.assignedDriverName,
      'latitude': vehicle.latitude,
      'longitude': vehicle.longitude,
      'lastLocationUpdate': vehicle.lastLocationUpdate != null
          ? Timestamp.fromDate(vehicle.lastLocationUpdate!)
          : null,
      'imageUrl': vehicle.imageUrl,
      'licenseExpiry': vehicle.licenseExpiry != null
          ? Timestamp.fromDate(vehicle.licenseExpiry!)
          : null,
      'insuranceExpiry': vehicle.insuranceExpiry != null
          ? Timestamp.fromDate(vehicle.insuranceExpiry!)
          : null,
      'lastMaintenanceDate': vehicle.lastMaintenanceDate != null
          ? Timestamp.fromDate(vehicle.lastMaintenanceDate!)
          : null,
      'nextMaintenanceDate': vehicle.nextMaintenanceDate != null
          ? Timestamp.fromDate(vehicle.nextMaintenanceDate!)
          : null,
      'totalKilometers': vehicle.totalKilometers,
      'fuelType': vehicle.fuelType,
      'fuelCapacity': vehicle.fuelCapacity,
      'currentFuelLevel': vehicle.currentFuelLevel,
      'maxLoadCapacity': vehicle.maxLoadCapacity,
      'notes': vehicle.notes,
      'createdAt': Timestamp.fromDate(vehicle.createdAt),
      'updatedAt': Timestamp.fromDate(vehicle.updatedAt),
    };
  }

  /// Parses Firestore timestamp to DateTime.
  DateTime? _parseTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
