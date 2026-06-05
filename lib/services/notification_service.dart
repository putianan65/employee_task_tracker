import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/notification_model.dart';
import '../models/task.dart';

/// NotificationService
/// ใช้เรียกผ่าน: NotificationService.instance
class NotificationService {
  NotificationService._internal();

  static final NotificationService instance = NotificationService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _ref =>
      _db.collection('notifications');

  // ──────────────── const type ────────────────
  static const String typeTaskAssigned = 'task_assigned';
  static const String typeTaskInProgress = 'task_in_progress';
  static const String typeTaskDone = 'task_done';

  // เตรียมไว้รองรับฟีเจอร์ใหม่ ๆ
  static const String typeTaskStatusChanged = 'task_status_changed';
  static const String typeChatMessage = 'chat_message';
  static const String typeDeadlineSoon = 'deadline_soon';

  // ──────────────── stream แจ้งเตือนของ user ────────────────
  Stream<List<AppNotification>> streamForUser(String uid) {
    return _ref
        .where('receiverId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => AppNotification.fromDoc(d)).toList(),
        );
  }

  /// (optional) นับจำนวนที่ยังไม่อ่าน – เอาไปทำ badge
  Stream<int> streamUnreadCount(String uid) {
    return _ref
        .where('receiverId', isEqualTo: uid)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  // ──────────────── INTERNAL: ฟังก์ชันบันทึก notification ────────────────
  Future<void> _saveNotification(
    AppNotification notif, {
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final data = notif.toMap();

      // ใช้ serverTimestamp ให้เวลามาจาก Firestore (ไม่ใช่ client)
      data['createdAt'] = FieldValue.serverTimestamp();

      // รองรับ metadata เพิ่มเติม
      if (metadata != null && metadata.isNotEmpty) {
        data['metadata'] = metadata;
      }

      final docRef = await _ref.add(data);

      // ignore: avoid_print
      print(
          '✅ Notification created: ${docRef.id} (type=${notif.type}) → receiver=${notif.receiverId}');
    } catch (e, st) {
      // ignore: avoid_print
      print('❌ Failed to create notification: $e');
      print(st);
      rethrow;
    }
  }

  // ──────────────── 1) เมื่อ Admin assign งานให้ employee ────────────────
  Future<void> createTaskAssignedNotification({
    required Task task,
    required String adminUid,
  }) async {
    // NOTE:
    // ตรงนี้ใช้ field เดิมของแอล: task.assignedTo
    // ถ้าเปลี่ยน Task model เป็น assigneeId → แก้ให้ตรงกันที่นี่
    final receiverId = task.assignedTo;

    if (receiverId == null || receiverId.isEmpty) {
      // ignore: avoid_print
      print(
          '⚠️ Skip task_assigned notification: assignedTo is empty (taskId=${task.id})');
      return;
    }

    final message = 'คุณได้รับมอบหมายงานใหม่: "${task.title}"';

    final notif = AppNotification(
      id: '', // Firestore จะสร้าง id ให้
      taskId: task.id,
      actorId: adminUid,
      receiverId: receiverId,
      type: typeTaskAssigned,
      message: message,
      // createdAt ใน model จะถูกทับด้วย serverTimestamp อยู่แล้ว
      createdAt: DateTime.now(),
      isRead: false,
    );

    await _saveNotification(
      notif,
      metadata: {
        'event': 'assigned',
        'taskTitle': task.title,
      },
    );
  }

  // ──────────────── 2) เมื่อ employee เปลี่ยนสถานะงาน ────────────────
  Future<void> createTaskStatusNotification({
    required Task task,
    required String newStatus,
    required String actorUid,
  }) async {
    // admin = creator ของงาน (ตาม requirement เดิมของแอล)
    if (task.id.isEmpty || task.createdBy.isEmpty) {
      // ignore: avoid_print
      print(
          '⚠️ Skip status notification: task.id or createdBy is empty (id=${task.id}, createdBy=${task.createdBy})');
      return;
    }

    final receiverId = task.createdBy;

    String? type;
    String? message;

    switch (newStatus) {
      case 'in_progress':
        type = typeTaskInProgress;
        message = 'งาน "${task.title}" ถูกเริ่มดำเนินการแล้ว';
        break;
      case 'done':
        type = typeTaskDone;
        message = 'งาน "${task.title}" ถูกทำเสร็จแล้ว';
        break;
      default:
        // ถ้าอยากรองรับ status อื่น ๆ (blocked, on_hold ฯลฯ)
        // สามารถใช้ typeTaskStatusChanged แทน
        type = typeTaskStatusChanged;
        message = 'สถานะงาน "${task.title}" เปลี่ยนเป็น $newStatus';
        break;
    }

    final notif = AppNotification(
      id: '',
      taskId: task.id,
      actorId: actorUid,
      receiverId: receiverId,
      type: type!,
      message: message!,
      createdAt: DateTime.now(),
      isRead: false,
    );

    await _saveNotification(
      notif,
      metadata: {
        'newStatus': newStatus,
        'taskTitle': task.title,
      },
    );
  }

  // ──────────────── 3) แจ้งเตือนเมื่อมี chat ใหม่ใน task ────────────────
  Future<void> createChatMessageNotification({
    required String taskId,
    required String taskTitle,
    required String senderId,
    required String receiverId,
    required String previewText,
  }) async {
    // กรณีไม่อยากให้ส่งแจ้งเตือนให้ตัวเอง
    if (senderId == receiverId) return;

    final notif = AppNotification(
      id: '',
      taskId: taskId,
      actorId: senderId,
      receiverId: receiverId,
      type: typeChatMessage,
      message: 'มีข้อความใหม่ในงาน: "$taskTitle"\n$previewText',
      createdAt: DateTime.now(),
      isRead: false,
    );

    await _saveNotification(
      notif,
      metadata: {
        'event': 'chat_message',
        'preview': previewText,
        'taskTitle': taskTitle,
      },
    );
  }

  // ──────────────── 4) mark read ทีละอัน ────────────────
  Future<void> markAsRead(String notifId) async {
    try {
      await _ref.doc(notifId).update({'isRead': true});
    } catch (e) {
      // ignore: avoid_print
      print('❌ Failed to markAsRead($notifId): $e');
      rethrow;
    }
  }

  // ──────────────── 5) mark read ทั้งหมดของ user ────────────────
  Future<void> markAllAsReadForUser(String uid) async {
    try {
      final snap = await _ref
          .where('receiverId', isEqualTo: uid)
          .where('isRead', isEqualTo: false)
          .get();

      if (snap.docs.isEmpty) return;

      final batch = _db.batch();
      for (final doc in snap.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      // ignore: avoid_print
      print('❌ Failed to markAllAsReadForUser($uid): $e');
      rethrow;
    }
  }

  // ──────────────── 6) ลบแจ้งเตือนทีละอัน ────────────────
  Future<void> deleteNotification(String notifId) async {
    try {
      await _ref.doc(notifId).delete();
    } catch (e) {
      // ignore: avoid_print
      print('❌ Failed to deleteNotification($notifId): $e');
      rethrow;
    }
  }

  // ──────────────── 7) เคลียร์แจ้งเตือนทั้งหมดของ user ────────────────
  Future<void> clearAllForUser(String uid) async {
    try {
      final snap =
          await _ref.where('receiverId', isEqualTo: uid).get();

      if (snap.docs.isEmpty) return;

      final batch = _db.batch();
      for (final doc in snap.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      // ignore: avoid_print
      print('❌ Failed to clearAllForUser($uid): $e');
      rethrow;
    }
  }
}
