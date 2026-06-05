import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/task.dart';
import '../models/user_model.dart';
import '../models/task_message.dart';
import '../models/checklist_item.dart';
import '../models/activity_log.dart';

class TaskDetailService {
  TaskDetailService._();
  static final TaskDetailService instance = TaskDetailService._();

  final _db = FirebaseFirestore.instance;

  // ------------------ CHAT ------------------
  Stream<List<TaskMessage>> streamMessages(String taskId) {
    return _db
        .collection('tasks')
        .doc(taskId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => TaskMessage.fromDoc(taskId, d)).toList());
  }

  Future<void> sendMessage({
    required Task task,
    required AppUser sender,
    required String text,
    List<TaskAttachment> attachments = const [],
  }) async {
    final ref =
        _db.collection('tasks').doc(task.id).collection('messages').doc();

    await ref.set({
      'text': text,
      'senderId': sender.uid,
      'senderName': sender.email, // ใช้อีเมลเป็นชื่อแสดง
      'createdAt': FieldValue.serverTimestamp(),
      'attachments': attachments.map((a) => a.toMap()).toList(),
      'reactions': {},
    });

    await _addActivity(
      taskId: task.id,
      actorId: sender.uid,
      type: 'comment',
      message: '${sender.email} คอมเมนต์ในงาน',
      meta: {'preview': text},
    );
  }

  Future<void> toggleReaction({
    required String taskId,
    required String messageId,
    required String emoji,
    required String uid,
  }) async {
    final msgRef = _db
        .collection('tasks')
        .doc(taskId)
        .collection('messages')
        .doc(messageId);

    await _db.runTransaction((tx) async {
      final snap = await tx.get(msgRef);
      if (!snap.exists) return;
      final data = snap.data() as Map<String, dynamic>;
      final reactions = Map<String, dynamic>.from(data['reactions'] ?? {});
      final List<dynamic> users =
          List<dynamic>.from(reactions[emoji] ?? []);

      if (users.contains(uid)) {
        users.remove(uid);
      } else {
        users.add(uid);
      }
      reactions[emoji] = users;
      tx.update(msgRef, {'reactions': reactions});
    });
  }

  // ------------------ CHECKLIST ------------------
  Stream<List<ChecklistItem>> streamChecklist(String taskId) {
    return _db
        .collection('tasks')
        .doc(taskId)
        .collection('checklist')
        .orderBy('order')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => ChecklistItem.fromDoc(taskId, d)).toList());
  }

  Future<void> addChecklistItem(
      String taskId, String title, int order) async {
    final ref = _db
        .collection('tasks')
        .doc(taskId)
        .collection('checklist')
        .doc();
    await ref.set({
      'title': title,
      'isDone': false,
      'order': order,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> toggleChecklistItem(
      String taskId, String itemId, bool isDone) async {
    final ref = _db
        .collection('tasks')
        .doc(taskId)
        .collection('checklist')
        .doc(itemId);
    await ref.update({
      'isDone': isDone,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// แก้ไขชื่อ checklist item
  Future<void> updateChecklistItem(
    String taskId,
    String itemId,
    String newTitle,
  ) async {
    final ref = _db
        .collection('tasks')
        .doc(taskId)
        .collection('checklist')
        .doc(itemId);

    await ref.update({
      'title': newTitle,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// ลบ checklist item
  Future<void> deleteChecklistItem(
    String taskId,
    String itemId,
  ) async {
    final ref = _db
        .collection('tasks')
        .doc(taskId)
        .collection('checklist')
        .doc(itemId);

    await ref.delete();
  }

  // ------------------ ACTIVITY ------------------
  Stream<List<ActivityLog>> streamActivities(String taskId) {
    return _db
        .collection('tasks')
        .doc(taskId)
        .collection('activity_logs')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => ActivityLog.fromDoc(taskId, d)).toList());
  }

  Future<void> _addActivity({
    required String taskId,
    required String actorId,
    required String type,
    required String message,
    Map<String, dynamic> meta = const {},
  }) async {
    final ref = _db
        .collection('tasks')
        .doc(taskId)
        .collection('activity_logs')
        .doc();
    await ref.set({
      'type': type,
      'message': message,
      'actorId': actorId,
      'createdAt': FieldValue.serverTimestamp(),
      'meta': meta,
    });
  }

  Future<void> logStatusChange({
    required Task task,
    required String fromStatus,
    required String toStatus,
    required String actorId,
    required String actorName,
  }) async {
    await _addActivity(
      taskId: task.id,
      actorId: actorId,
      type: 'status_changed',
      message: '$actorName เปลี่ยนสถานะจาก $fromStatus เป็น $toStatus',
      meta: {
        'from': fromStatus,
        'to': toStatus,
      },
    );
  }

  // ------------------ LOCATION LOG (NEW) ------------------
  /// บันทึกตำแหน่งที่ user เปิด TaskDetailDialog
  Future<void> logLocation({
    required String taskId,
    required double lat,
    required double lng,
    required String uid,
    required String email,
  }) async {
    try {
      final docRef = _db.collection('task_locations').doc();

      await docRef.set({
        'id': docRef.id,
        'taskId': taskId,
        'lat': lat,
        'lng': lng,
        'userId': uid,
        'userEmail': email,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e, st) {
      // dev log ไว้ดู
      // ignore: avoid_print
      print('❌ logLocation error: $e');
      // ignore: avoid_print
      print(st);
    }
  }
}
