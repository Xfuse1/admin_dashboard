import 'dart:async';

import '../../domain/entities/order_entities.dart';
import '../../domain/repositories/orders_repository.dart';
import '../models/order_model.dart';
import 'orders_datasource.dart';

/// Mock implementation of OrdersDataSource for development.
class OrdersMockDataSource implements OrdersDataSource {
  // Mock orders data
  final List<OrderModel> _mockOrders = _generateMockOrders();

  // Stream controller for real-time updates
  final _ordersStreamController =
      StreamController<List<OrderModel>>.broadcast();

  OrdersMockDataSource() {
    // Initialize stream with current data
    _ordersStreamController.add(_mockOrders);
  }

  @override
  Future<List<OrderModel>> getOrders({
    OrderStatus? status,
    String? storeId,
    String? driverId,
    DateTime? fromDate,
    DateTime? toDate,
    int limit = 20,
    String? lastOrderId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    var orders = List<OrderModel>.from(_mockOrders);

    // Apply filters
    if (status != null) {
      orders = orders.where((o) => o.status == status).toList();
    }
    if (storeId != null) {
      orders = orders.where((o) => o.storeId == storeId).toList();
    }
    if (driverId != null) {
      orders = orders.where((o) => o.driverId == driverId).toList();
    }
    if (fromDate != null) {
      orders = orders.where((o) => o.createdAt.isAfter(fromDate)).toList();
    }
    if (toDate != null) {
      orders = orders.where((o) => o.createdAt.isBefore(toDate)).toList();
    }

    // Sort by creation date (newest first)
    orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // Apply pagination
    if (lastOrderId != null) {
      final lastIndex = orders.indexWhere((o) => o.id == lastOrderId);
      if (lastIndex != -1) {
        orders = orders.sublist(lastIndex + 1);
      }
    }

    return orders.take(limit).toList();
  }

  @override
  Future<OrderModel> getOrderById(String orderId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final order = _mockOrders.firstWhere(
      (o) => o.id == orderId,
      orElse: () => throw Exception('Order not found'),
    );

    return order;
  }

  @override
  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _mockOrders.indexWhere((o) => o.id == orderId);
    if (index == -1) {
      throw Exception('Order not found');
    }

    final order = _mockOrders[index];
    final newTimeline = [
      ...order.timeline,
      OrderTimelineModel(
        status: newStatus,
        timestamp: DateTime.now(),
      ),
    ];

    _mockOrders[index] = order.copyWith(
      status: newStatus,
      timeline: newTimeline,
      updatedAt: DateTime.now(),
    );

    _ordersStreamController.add(_mockOrders);
  }

  @override
  Future<void> assignDriver(String orderId, String driverId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _mockOrders.indexWhere((o) => o.id == orderId);
    if (index == -1) {
      throw Exception('Order not found');
    }

    _mockOrders[index] = _mockOrders[index].copyWith(
      driverId: driverId,
      driverName: 'سائق معين',
      updatedAt: DateTime.now(),
    );

    _ordersStreamController.add(_mockOrders);
  }

  @override
  Future<void> cancelOrder(String orderId, String reason) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _mockOrders.indexWhere((o) => o.id == orderId);
    if (index == -1) {
      throw Exception('Order not found');
    }

    final order = _mockOrders[index];
    final newTimeline = [
      ...order.timeline,
      OrderTimelineModel(
        status: OrderStatus.cancelled,
        timestamp: DateTime.now(),
        note: reason,
      ),
    ];

    _mockOrders[index] = order.copyWith(
      status: OrderStatus.cancelled,
      timeline: newTimeline,
      employeeCancelNote: reason,
      updatedAt: DateTime.now(),
    );

    _ordersStreamController.add(_mockOrders);
  }

  @override
  Stream<List<OrderModel>> watchOrders({OrderStatus? status}) {
    if (status != null) {
      return _ordersStreamController.stream
          .map((orders) => orders.where((o) => o.status == status).toList());
    }
    return _ordersStreamController.stream;
  }

  @override
  Future<OrderStats> getOrderStats({
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    var orders = List<OrderModel>.from(_mockOrders);

    if (fromDate != null) {
      orders = orders.where((o) => o.createdAt.isAfter(fromDate)).toList();
    }
    if (toDate != null) {
      orders = orders.where((o) => o.createdAt.isBefore(toDate)).toList();
    }

    final totalOrders = orders.length;
    final pendingOrders =
        orders.where((o) => o.status == OrderStatus.pending).length;
    final activeOrders = orders.where((o) => o.status.isActive).length;
    final completedOrders =
        orders.where((o) => o.status == OrderStatus.delivered).length;
    final cancelledOrders =
        orders.where((o) => o.status == OrderStatus.cancelled).length;
    final totalRevenue = orders
        .where((o) => o.status == OrderStatus.delivered)
        .fold(0.0, (sum, o) => sum + (o.total ?? 0.0));

    return OrderStats(
      totalOrders: totalOrders,
      pendingOrders: pendingOrders,
      activeOrders: activeOrders,
      completedOrders: completedOrders,
      cancelledOrders: cancelledOrders,
      totalRevenue: totalRevenue,
      averageOrderValue:
          completedOrders > 0 ? totalRevenue / completedOrders : 0,
    );
  }

  void dispose() {
    _ordersStreamController.close();
  }
}

// Generate mock orders data
List<OrderModel> _generateMockOrders() {
  final now = DateTime.now();
  final statuses = OrderStatus.values;
  final stores = [
    {'id': 'store_1', 'name': 'مطعم البيت'},
    {'id': 'store_2', 'name': 'كافيه الصباح'},
    {'id': 'store_3', 'name': 'مطعم الشام'},
    {'id': 'store_4', 'name': 'بيتزا هت'},
    {'id': 'store_5', 'name': 'ماكدونالدز'},
  ];

  final customers = [
    {'id': 'cust_1', 'name': 'أحمد محمد', 'phone': '0501234567'},
    {'id': 'cust_2', 'name': 'سارة علي', 'phone': '0507654321'},
    {'id': 'cust_3', 'name': 'خالد عبدالله', 'phone': '0509876543'},
    {'id': 'cust_4', 'name': 'فاطمة حسن', 'phone': '0502345678'},
    {'id': 'cust_5', 'name': 'يوسف عمر', 'phone': '0508765432'},
  ];

  final addresses = [
    'حي النزهة، شارع الأمير سلطان، مبنى 25',
    'حي الروضة، شارع التحلية، فيلا 12',
    'حي السلامة، شارع المحمدية، عمارة 8 شقة 5',
    'حي الفيصلية، شارع الملك فهد، برج الياسمين',
    'حي الزهراء، شارع الأندلس، منزل 18',
  ];

  return List.generate(30, (index) {
    final store = stores[index % stores.length];
    final customer = customers[index % customers.length];
    final status = statuses[index % statuses.length];
    final orderDate = now.subtract(Duration(hours: index * 2));

    final items = List.generate(
      (index % 4) + 1,
      (i) => OrderItemModel(
        id: 'item_${index}_$i',
        name: ['برجر لحم', 'بيتزا كبيرة', 'سلطة سيزر', 'عصير برتقال'][i % 4],
        quantity: (i % 3) + 1,
        price: [25.0, 45.0, 20.0, 12.0][i % 4],
        total: [25.0, 45.0, 20.0, 12.0][i % 4] * ((i % 3) + 1),
      ),
    );

    final subtotal = items.fold(0.0, (sum, item) => sum + item.total);
    final deliveryFee = 10.0;

    return OrderModel(
      id: 'order_${1000 + index}',
      customerId: customer['id']!,
      customerName: customer['name']!,
      customerPhone: customer['phone']!,
      storeId: store['id']!,
      storeName: store['name']!,
      driverId:
          status.isActive || status.isCompleted ? 'driver_${index % 5}' : null,
      driverName: status.isActive || status.isCompleted
          ? 'سائق ${index % 5 + 1}'
          : null,
      driverLatitude: status.isActive || status.isCompleted
          ? 24.7136 + (index * 0.01)
          : null,
      driverLongitude: status.isActive || status.isCompleted
          ? 46.6753 + (index * 0.01)
          : null,
      items: items,
      status: status,
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      total: subtotal + deliveryFee,
      address: DeliveryAddressModel(
        state: 'الرياض',
        city: 'الرياض',
        street: addresses[index % addresses.length],
        mobile: customer['phone']!,
        latitude: 24.7136 + (index * 0.01),
        longitude: 46.6753 + (index * 0.01),
      ),
      timeline: _generateTimeline(status, orderDate),
      createdAt: orderDate,
      updatedAt: orderDate.add(Duration(minutes: index * 5)),
    );
  });
}

List<OrderTimelineModel> _generateTimeline(
    OrderStatus status, DateTime startTime) {
  final timeline = <OrderTimelineModel>[];

  final allStatuses = [
    OrderStatus.pending,
    OrderStatus.confirmed,
    OrderStatus.preparing,
    OrderStatus.ready,
    OrderStatus.pickedUp,
    OrderStatus.onTheWay,
    OrderStatus.delivered,
  ];

  if (status == OrderStatus.cancelled) {
    timeline.add(OrderTimelineModel(
      status: OrderStatus.pending,
      timestamp: startTime,
    ));
    timeline.add(OrderTimelineModel(
      status: OrderStatus.cancelled,
      timestamp: startTime.add(const Duration(minutes: 10)),
      note: 'تم الإلغاء بناءً على طلب العميل',
    ));
    return timeline;
  }

  final statusIndex = allStatuses.indexOf(status);
  for (int i = 0; i <= statusIndex; i++) {
    timeline.add(OrderTimelineModel(
      status: allStatuses[i],
      timestamp: startTime.add(Duration(minutes: i * 8)),
    ));
  }

  return timeline;
}
