import 'package:equatable/equatable.dart';

/// Rejection request entity
class RejectionRequestEntity extends Equatable {
  final String requestId;
  final String orderId;
  final String driverId;
  final String driverName;
  final String reason;
  final String adminDecision; // 'pending', 'approved', 'rejected'
  final String? adminComment;
  final DateTime requestedAt;
  final DateTime? decidedAt;

  const RejectionRequestEntity({
    required this.requestId,
    required this.orderId,
    required this.driverId,
    required this.driverName,
    required this.reason,
    required this.adminDecision,
    this.adminComment,
    required this.requestedAt,
    this.decidedAt,
  });

  /// Calculate wait time in minutes
  int get waitTimeMinutes {
    final now = DateTime.now();
    final waitTime = decidedAt ?? now;
    return waitTime.difference(requestedAt).inMinutes;
  }

  /// Get SLA status color indicator
  String get slaStatus {
    final minutes = waitTimeMinutes;
    if (minutes < 5) return 'green';
    if (minutes < 15) return 'yellow';
    return 'red';
  }

  bool get isPending => adminDecision == 'pending';
  bool get isApproved => adminDecision == 'approved';
  bool get isRejected => adminDecision == 'rejected';

  @override
  List<Object?> get props => [
        requestId,
        orderId,
        driverId,
        driverName,
        reason,
        adminDecision,
        adminComment,
        requestedAt,
        decidedAt,
      ];
}

/// Statistics for rejection requests
class RejectionStats extends Equatable {
  final int totalRequests;
  final int pendingRequests;
  final int approvedRequests;
  final int rejectedRequests;
  final double averageResponseTimeMinutes;

  const RejectionStats({
    required this.totalRequests,
    required this.pendingRequests,
    required this.approvedRequests,
    required this.rejectedRequests,
    required this.averageResponseTimeMinutes,
  });

  double get approvalRate {
    if (totalRequests == 0) return 0;
    return (approvedRequests / totalRequests) * 100;
  }

  double get rejectionRate {
    if (totalRequests == 0) return 0;
    return (rejectedRequests / totalRequests) * 100;
  }

  @override
  List<Object?> get props => [
        totalRequests,
        pendingRequests,
        approvedRequests,
        rejectedRequests,
        averageResponseTimeMinutes,
      ];
}
