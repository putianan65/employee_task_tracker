import 'package:cloud_firestore/cloud_firestore.dart';

class TaskAttachment {
  final String url;
  final String fileName;
  final String type; // image, pdf, ...

  TaskAttachment({
    required this.url,
    required this.fileName,
    required this.type,
  });

  factory TaskAttachment.fromMap(Map<String, dynamic> map) {
    return TaskAttachment(
      url: map['url'] ?? '',
      fileName: map['fileName'] ?? '',
      type: map['type'] ?? 'file',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'url': url,
      'fileName': fileName,
      'type': type,
    };
  }
}

class TaskMessage {
  final String id;
  final String taskId;
  final String text;
  final String senderId;
  final String senderName;
  final DateTime createdAt;
  final List<TaskAttachment> attachments;
  final Map<String, List<String>> reactions; // emoji -> [uid]

  TaskMessage({
    required this.id,
    required this.taskId,
    required this.text,
    required this.senderId,
    required this.senderName,
    required this.createdAt,
    this.attachments = const [],
    this.reactions = const {},
  });

  factory TaskMessage.fromDoc(
    String taskId,
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return TaskMessage(
      id: doc.id,
      taskId: taskId,
      text: data['text'] ?? '',
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      attachments: (data['attachments'] as List<dynamic>? ?? [])
          .map((e) => TaskAttachment.fromMap(e as Map<String, dynamic>))
          .toList(),
      reactions: (data['reactions'] as Map<String, dynamic>? ?? {}).map(
        (key, value) =>
            MapEntry(key, List<String>.from(value as List<dynamic>)),
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'senderId': senderId,
      'senderName': senderName,
      'createdAt': Timestamp.fromDate(createdAt),
      'attachments': attachments.map((a) => a.toMap()).toList(),
      'reactions': reactions,
    };
  }
}
