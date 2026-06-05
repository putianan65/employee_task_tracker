import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task.dart';
import '../models/user_model.dart';

class TaskService {
  TaskService._();
  static final TaskService instance = TaskService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _tasksRef =>
      _db.collection('tasks');

  /// สำหรับ admin เห็นงานทั้งหมด
  Stream<List<Task>> streamAllTasks() {
    return _tasksRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Task.fromDoc(doc)).toList();
    });
  }

  /// ⭐ ระบบ Role-based Filtering
  /// admin → เห็นทุกงาน
  /// employee → เห็นเฉพาะงานที่ assignedTo = uid
  Stream<List<Task>> streamTasksForUser(AppUser user) {
    Query<Map<String, dynamic>> query =
        _tasksRef.orderBy('createdAt', descending: true);

    if (user.role == 'employee') {
      query = query.where('assignedTo', isEqualTo: user.uid);
    }

    return query.snapshots().map(
      (snapshot) =>
          snapshot.docs.map((doc) => Task.fromDoc(doc)).toList(),
    );
  }

  /// ✅ ดึงงานรายตัวแบบครั้งเดียว (ใช้ในกรณีต้องการโหลด initial data)
  Future<Task?> getTaskById(String taskId) async {
    final doc =
        await _tasksRef.doc(taskId).get(); // DocumentSnapshot<Map<String, dynamic>>
    if (!doc.exists) return null;
    return Task.fromDoc(doc);
  }

  /// ✅ stream งานรายตัวแบบ realtime (เหมาะกับ TaskDetailDialog)
  Stream<Task?> streamTaskById(String taskId) {
    return _tasksRef.doc(taskId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return Task.fromDoc(doc);
    });
  }

  /// ✅ เพิ่มงานใหม่ และคืนค่า taskId
  Future<String> addTask(Task task) async {
    final docRef = await _tasksRef.add(task.toMap());
    return docRef.id;
  }

  /// ✅ อัปเดตสถานะงาน + updatedAt
  Future<void> updateTaskStatus(String taskId, String newStatus) async {
    await _tasksRef.doc(taskId).update({
      'status': newStatus,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  /// (option) อัปเดตงานทั้งก้อน (สำหรับอนาคต เช่น edit task)
  Future<void> updateTask(Task task) async {
    await _tasksRef.doc(task.id).update(task.toMap());
  }

  /// Admin เปลี่ยน assignedTo ให้พนักงานคนอื่น
  Future<void> assignTask(String taskId, String newAssignedUid) async {
    await _tasksRef.doc(taskId).update({
      'assignedTo': newAssignedUid,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  /// ลบงาน
  Future<void> deleteTask(String taskId) async {
    await _tasksRef.doc(taskId).delete();
  }
}
