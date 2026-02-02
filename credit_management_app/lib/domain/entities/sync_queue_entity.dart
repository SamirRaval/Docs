/// Sync queue item entity for offline sync management
class SyncQueueEntity {
  final String id;
  final String entityType; // customer, credit, transaction
  final String entityId;
  final String operation; // create, update, delete
  final Map<String, dynamic> data;
  final int retryCount;
  final String status; // pending, processing, completed, failed
  final String? errorMessage;
  final DateTime createdAt;
  final DateTime? processedAt;

  SyncQueueEntity({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.data,
    this.retryCount = 0,
    this.status = 'pending',
    this.errorMessage,
    required this.createdAt,
    this.processedAt,
  });

  /// Check if item can be retried
  bool get canRetry => retryCount < 3 && status != 'completed';

  /// Check if item is pending
  bool get isPending => status == 'pending';

  /// Check if item has failed
  bool get hasFailed => status == 'failed';

  SyncQueueEntity copyWith({
    String? id,
    String? entityType,
    String? entityId,
    String? operation,
    Map<String, dynamic>? data,
    int? retryCount,
    String? status,
    String? errorMessage,
    DateTime? createdAt,
    DateTime? processedAt,
  }) {
    return SyncQueueEntity(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      operation: operation ?? this.operation,
      data: data ?? this.data,
      retryCount: retryCount ?? this.retryCount,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      createdAt: createdAt ?? this.createdAt,
      processedAt: processedAt ?? this.processedAt,
    );
  }
}
