import 'package:cloud_firestore/cloud_firestore.dart';

class ChecklistItem {
  final String id;
  final String taskId;
  final String title;
  final bool isDone;
  final int order;

  ChecklistItem({
    required this.id,
    required this.taskId,
    required this.title,
    required this.isDone,
    required this.order,
  });

  factory ChecklistItem.fromDoc(
    String taskId,
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return ChecklistItem(
      id: doc.id,
      taskId: taskId,
      title: data['title'] ?? '',
      isDone: data['isDone'] ?? false,
      order: (data['order'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'isDone': isDone,
      'order': order,
    };
  }
}
