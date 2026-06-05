import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityLog {
  final String id;
  final String taskId;
  final String type;
  final String message;
  final String actorId;
  final DateTime createdAt;
  final Map<String, dynamic> meta;

  ActivityLog({
    required this.id,
    required this.taskId,
    required this.type,
    required this.message,
    required this.actorId,
    required this.createdAt,
    this.meta = const {},
  });

  factory ActivityLog.fromDoc(
    String taskId,
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return ActivityLog(
      id: doc.id,
      taskId: taskId,
      type: data['type'] ?? '',
      message: data['message'] ?? '',
      actorId: data['actorId'] ?? '',
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      meta: Map<String, dynamic>.from(data['meta'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'message': message,
      'actorId': actorId,
      'createdAt': Timestamp.fromDate(createdAt),
      'meta': meta,
    };
  }
}
