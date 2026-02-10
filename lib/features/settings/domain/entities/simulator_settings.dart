import 'package:equatable/equatable.dart';

/// Simulator settings entity.
class SimulatorSettings extends Equatable {
  final bool enabled;
  final int rows;
  final int columns;
  final int productsPerRow;
  final int productsPerColumn;
  final int maxCartItems;
  final double minOrderAmount;
  final int cartTimeout;
  final int autoScrollSpeed;
  final bool enableSounds;
  final bool enableVibration;

  const SimulatorSettings({
    this.enabled = false,
    this.rows = 4,
    this.columns = 3,
    this.productsPerRow = 5,
    this.productsPerColumn = 4,
    this.maxCartItems = 20,
    this.minOrderAmount = 50.0,
    this.cartTimeout = 30,
    this.autoScrollSpeed = 3,
    this.enableSounds = true,
    this.enableVibration = true,
  });

  /// Create from Firestore data.
  factory SimulatorSettings.fromMap(Map<String, dynamic> data) {
    return SimulatorSettings(
      enabled: data['enabled'] ?? false,
      rows: data['rows'] ?? 4,
      columns: data['columns'] ?? 3,
      productsPerRow: data['productsPerRow'] ?? 5,
      productsPerColumn: data['productsPerColumn'] ?? 4,
      maxCartItems: data['maxCartItems'] ?? 20,
      minOrderAmount: (data['minOrderAmount'] as num?)?.toDouble() ?? 50.0,
      cartTimeout: data['cartTimeout'] ?? 30,
      autoScrollSpeed: data['autoScrollSpeed'] ?? 3,
      enableSounds: data['enableSounds'] ?? true,
      enableVibration: data['enableVibration'] ?? true,
    );
  }

  /// Convert to Firestore data.
  Map<String, dynamic> toMap() {
    return {
      'enabled': enabled,
      'rows': rows,
      'columns': columns,
      'productsPerRow': productsPerRow,
      'productsPerColumn': productsPerColumn,
      'maxCartItems': maxCartItems,
      'minOrderAmount': minOrderAmount,
      'cartTimeout': cartTimeout,
      'autoScrollSpeed': autoScrollSpeed,
      'enableSounds': enableSounds,
      'enableVibration': enableVibration,
    };
  }

  SimulatorSettings copyWith({
    bool? enabled,
    int? rows,
    int? columns,
    int? productsPerRow,
    int? productsPerColumn,
    int? maxCartItems,
    double? minOrderAmount,
    int? cartTimeout,
    int? autoScrollSpeed,
    bool? enableSounds,
    bool? enableVibration,
  }) {
    return SimulatorSettings(
      enabled: enabled ?? this.enabled,
      rows: rows ?? this.rows,
      columns: columns ?? this.columns,
      productsPerRow: productsPerRow ?? this.productsPerRow,
      productsPerColumn: productsPerColumn ?? this.productsPerColumn,
      maxCartItems: maxCartItems ?? this.maxCartItems,
      minOrderAmount: minOrderAmount ?? this.minOrderAmount,
      cartTimeout: cartTimeout ?? this.cartTimeout,
      autoScrollSpeed: autoScrollSpeed ?? this.autoScrollSpeed,
      enableSounds: enableSounds ?? this.enableSounds,
      enableVibration: enableVibration ?? this.enableVibration,
    );
  }

  @override
  List<Object?> get props => [
        enabled,
        rows,
        columns,
        productsPerRow,
        productsPerColumn,
        maxCartItems,
        minOrderAmount,
        cartTimeout,
        autoScrollSpeed,
        enableSounds,
        enableVibration,
      ];
}
