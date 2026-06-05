import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String id;
  final String title;
  final String? description;
  final String status; // todo, in_progress, done
  final String createdBy; // uid ของคนสร้าง
  final String? assignedTo; // uid ของพนักงานที่ถูกมอบหมาย
  final DateTime createdAt;
  final DateTime? dueDate;
  final String priority; // low, medium, high
  final DateTime updatedAt; // เวลาอัปเดตล่าสุด

  // ⭐ NEW: ตำแหน่งหลักของงาน (อาจจะเป็นจุดใน GIST NU)
  final double? lat;
  final double? lng;

  Task({
    required this.id,
    required this.title,
    this.description,
    required this.status,
    required this.createdBy,
    this.assignedTo,
    required this.createdAt,
    this.dueDate,
    required this.priority,
    required this.updatedAt,
    this.lat,
    this.lng,
  });

  factory Task.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;

    return Task(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'],
      status: data['status'] ?? 'todo',
      createdBy: data['createdBy'] ?? '',
      assignedTo: data['assignedTo'],
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      dueDate: (data['dueDate'] as Timestamp?)?.toDate(),
      priority: data['priority'] ?? 'medium',
      updatedAt:
          (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),

      // ⭐ NEW: อ่านค่า lat/lng ถ้ามีใน Firestore (ถ้าไม่มีจะเป็น null)
      lat: (data['lat'] is num) ? (data['lat'] as num).toDouble() : null,
      lng: (data['lng'] is num) ? (data['lng'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'title': title,
      'description': description,
      'status': status,
      'createdBy': createdBy,
      'assignedTo': assignedTo,
      'createdAt': Timestamp.fromDate(createdAt),
      if (dueDate != null) 'dueDate': Timestamp.fromDate(dueDate!),
      'priority': priority,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };

    // ⭐ NEW: เขียน lat/lng เฉพาะตอนที่มีค่า (ไม่งั้นจะไม่แตะ field เดิมใน DB)
    if (lat != null) map['lat'] = lat;
    if (lng != null) map['lng'] = lng;

    return map;
  }

  /// ใช้เวลาต้องการอัปเดตบางค่า
  Task copyWith({
    String? id, // ใช้ id ใหม่ถ้ามี (ส่วนใหญ่ใช้ตอนสร้างเสร็จแล้วได้ docId)
    String? title,
    String? description,
    String? status,
    String? createdBy,
    String? assignedTo,
    DateTime? createdAt,
    DateTime? dueDate,
    String? priority,
    DateTime? updatedAt,
    double? lat,
    double? lng,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      assignedTo: assignedTo ?? this.assignedTo,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      // ถ้าไม่ได้ส่ง updatedAt มา จะอัปเดตเป็นเวลาปัจจุบันให้เลย
      updatedAt: updatedAt ?? DateTime.now(),
      // ⭐ NEW: ถ้าไม่ส่งค่าใหม่มา จะใช้ค่าตำแหน่งเดิม
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
    );
  }
}
