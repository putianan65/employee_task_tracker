import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotification {
  final String id;
  final String taskId;
  final String actorId;     // คนที่กดเปลี่ยนสถานะ
  final String receiverId;  // คนที่ได้รับแจ้งเตือน (เช่น admin / creator)
  final String type;        // task_in_progress / task_done / ...
  final String message;
  final DateTime createdAt;
  final bool isRead;

  AppNotification({
    required this.id,
    required this.taskId,
    required this.actorId,
    required this.receiverId,
    required this.type,
    required this.message,
    required this.createdAt,
    required this.isRead,
  });

  factory AppNotification.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return AppNotification(
      id: doc.id,
      taskId: data['taskId'] ?? '',
      actorId: data['actorId'] ?? '',
      receiverId: data['receiverId'] ?? '',
      type: data['type'] ?? '',
      message: data['message'] ?? '',
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: data['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'taskId': taskId,
      'actorId': actorId,
      'receiverId': receiverId,
      'type': type,
      'message': message,
      'createdAt': Timestamp.fromDate(createdAt),
      'isRead': isRead,
    };
  }
}
