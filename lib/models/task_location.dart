import 'package:cloud_firestore/cloud_firestore.dart';

class TaskLocation {
  final String id;
  final String taskId;
  final double lat;
  final double lng;
  final String userId;
  final String userEmail;
  final DateTime createdAt;

  TaskLocation({
    required this.id,
    required this.taskId,
    required this.lat,
    required this.lng,
    required this.userId,
    required this.userEmail,
    required this.createdAt,
  });

  /// ใช้ตอนเซฟลง Firestore (โครงสร้างตรงกับ logLocation)
  Map<String, dynamic> toMap() {
    return {
      'taskId': taskId,
      'lat': lat,
      'lng': lng,
      'userId': userId,
      'userEmail': userEmail,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// ใช้ตอนอ่านจาก Firestore
  /// รองรับทั้งโครงสร้างใหม่ (userId/userEmail/createdAt)
  /// และของเก่า (uid/email/time) เผื่อมีข้อมูลชุดเก่าใน DB
  factory TaskLocation.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    return TaskLocation(
      id: doc.id,
      taskId: data['taskId'] ?? '',
      lat: (data['lat'] as num?)?.toDouble() ?? 0,
      lng: (data['lng'] as num?)?.toDouble() ?? 0,
      userId: data['userId'] ?? data['uid'] ?? '',
      userEmail: data['userEmail'] ?? data['email'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ??
          (data['time'] as Timestamp?)?.toDate() ??
          DateTime.now(),
    );
  }
}
