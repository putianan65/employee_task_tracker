import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/task_service.dart';
import '../../services/notification_service.dart';
import '../../services/location_service.dart';
import '../../models/task.dart';
import '../../models/user_model.dart';
import '../../models/notification_model.dart';
import '../../auth/auth_service.dart';
import 'task_detail_dialog.dart';
import 'task_map_screen.dart'; // ✅ เพิ่ม import หน้ารวมแผนที่งาน

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final firebaseUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Image.asset(
          'assets/Gistnu_new_logo.webp',
          height: 40,
          fit: BoxFit.contain,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: Colors.grey.shade200,
            height: 1,
          ),
        ),
        actions: [
          // ✅ ปุ่มไปหน้าแผนที่ Task Map (GIST NU)
          IconButton(
            tooltip: 'แผนที่งาน (GIST NU)',
            icon: Icon(
              Icons.map_outlined,
              color: Colors.grey.shade700,
              size: 26,
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const TaskMapScreen(),
                ),
              );
            },
          ),

          if (firebaseUser != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.account_circle,
                        size: 16,
                        color: Colors.blue.shade700,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        firebaseUser.email ?? '',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          FutureBuilder<AppUser?>(
            future: authService.getCurrentAppUser(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data?.role == 'admin') {
                final adminUser = snapshot.data!;
                return StreamBuilder<List<AppNotification>>(
                  stream: NotificationService.instance
                      .streamForUser(adminUser.uid),
                  builder: (context, notifSnapshot) {
                    final notifications = notifSnapshot.data ?? [];
                    final unreadCount =
                        notifications.where((n) => !n.isRead).length;

                    return Stack(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.notifications_outlined,
                            color: Colors.grey.shade700,
                            size: 28,
                          ),
                          tooltip: 'Notifications',
                          onPressed: () =>
                              _showNotificationsSheet(context, adminUser.uid),
                        ),
                        if (unreadCount > 0)
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 20,
                                minHeight: 20,
                              ),
                              child: Text(
                                unreadCount > 9 ? '9+' : '$unreadCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
          IconButton(
            icon: Icon(Icons.logout, color: Colors.grey.shade700),
            tooltip: 'Logout',
            onPressed: () async {
              await authService.logout();
              // ถ้า Flutter เวอร์ชันยังไม่รองรับ context.mounted ใช้แบบนี้แทนก็ได้:
              if (Navigator.canPop(context)) {
                Navigator.pushReplacementNamed(context, '/login');
              } else {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: FutureBuilder<AppUser?>(
        future: authService.getCurrentAppUser(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!userSnapshot.hasData || userSnapshot.data == null) {
            return const Center(
              child: Text('User not found. Please login again.'),
            );
          }

          final currentUser = userSnapshot.data!;
          final isAdmin = currentUser.role == 'admin';

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: StreamBuilder<List<Task>>(
                stream: TaskService.instance.streamTasksForUser(currentUser),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error: ${snapshot.error}',
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final tasks = snapshot.data ?? [];

                  if (tasks.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.task_alt,
                            size: 80,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No tasks yet',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (isAdmin)
                            Text(
                              'Tap the + button to create your first task',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                            ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(24),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];

                      Color statusColor;
                      IconData statusIcon;
                      String statusLabel;

                      switch (task.status) {
                        case 'done':
                          statusColor = Colors.green.shade600;
                          statusIcon = Icons.check_circle;
                          statusLabel = 'Done';
                          break;
                        case 'in_progress':
                          statusColor = Colors.orange.shade600;
                          statusIcon = Icons.pending;
                          statusLabel = 'In Progress';
                          break;
                        default:
                          statusColor = Colors.blue.shade600;
                          statusIcon = Icons.radio_button_unchecked;
                          statusLabel = 'To Do';
                      }

                      Color priorityColor;
                      IconData priorityIcon;

                      switch (task.priority) {
                        case 'high':
                          priorityColor = Colors.red.shade600;
                          priorityIcon = Icons.priority_high;
                          break;
                        case 'low':
                          priorityColor = Colors.green.shade600;
                          priorityIcon = Icons.low_priority;
                          break;
                        default:
                          priorityColor = Colors.orange.shade600;
                          priorityIcon = Icons.drag_handle;
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (_) => TaskDetailDialog(
                                  taskId: task.id,
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          task.title,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey.shade800,
                                            decoration: task.status == 'done'
                                                ? TextDecoration.lineThrough
                                                : null,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      PopupMenuButton<String>(
                                        icon: Icon(
                                          Icons.more_vert,
                                          color: Colors.grey.shade600,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        onSelected: (value) async {
                                          if (value == 'todo' ||
                                              value == 'in_progress' ||
                                              value == 'done') {
                                            try {
                                              final updatedTask =
                                                  task.copyWith(status: value);

                                              await TaskService.instance
                                                  .updateTaskStatus(
                                                task.id,
                                                value,
                                              );

                                              await NotificationService.instance
                                                  .createTaskStatusNotification(
                                                task: updatedTask,
                                                newStatus: value,
                                                actorUid: currentUser.uid,
                                              );
                                            } catch (e, st) {
                                              print(
                                                  '❌ Failed to change status: $e');
                                              print(st);
                                            }
                                          } else if (value == 'delete' &&
                                              isAdmin) {
                                            await TaskService.instance
                                                .deleteTask(task.id);
                                          }
                                        },
                                        itemBuilder: (context) => [
                                          const PopupMenuItem(
                                            value: 'todo',
                                            child: Row(
                                              children: [
                                                Icon(
                                                    Icons
                                                        .radio_button_unchecked,
                                                    size: 20),
                                                SizedBox(width: 12),
                                                Text('Mark as To Do'),
                                              ],
                                            ),
                                          ),
                                          const PopupMenuItem(
                                            value: 'in_progress',
                                            child: Row(
                                              children: [
                                                Icon(Icons.pending, size: 20),
                                                SizedBox(width: 12),
                                                Text('Mark as In Progress'),
                                              ],
                                            ),
                                          ),
                                          const PopupMenuItem(
                                            value: 'done',
                                            child: Row(
                                              children: [
                                                Icon(Icons.check_circle,
                                                    size: 20),
                                                SizedBox(width: 12),
                                                Text('Mark as Done'),
                                              ],
                                            ),
                                          ),
                                          if (isAdmin) const PopupMenuDivider(),
                                          if (isAdmin)
                                            const PopupMenuItem(
                                              value: 'delete',
                                              child: Row(
                                                children: [
                                                  Icon(Icons.delete,
                                                      size: 20,
                                                      color: Colors.red),
                                                  SizedBox(width: 12),
                                                  Text(
                                                    'Delete',
                                                    style: TextStyle(
                                                        color: Colors.red),
                                                  ),
                                                ],
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  if (task.description != null &&
                                      task.description!.isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    Text(
                                      task.description!,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                        height: 1.5,
                                      ),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: statusColor.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              statusIcon,
                                              size: 16,
                                              color: statusColor,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              statusLabel,
                                              style: TextStyle(
                                                color: statusColor,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              priorityColor.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              priorityIcon,
                                              size: 16,
                                              color: priorityColor,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              '${task.priority[0].toUpperCase()}${task.priority.substring(1)} Priority',
                                              style: TextStyle(
                                                color: priorityColor,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FutureBuilder<AppUser?>(
        future: authService.getCurrentAppUser(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data?.role != 'admin') {
            return const SizedBox.shrink();
          }
          return FloatingActionButton.extended(
            onPressed: () => _openAddTaskDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('New Task'),
            elevation: 4,
          );
        },
      ),
    );
  }

  void _showNotificationsSheet(BuildContext context, String adminUid) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return NotificationBottomSheet(adminUid: adminUid);
      },
    );
  }

  // ========================================
  // 📝 DIALOG สร้าง TASK ใหม่ (เพิ่ม Location)
  // ========================================
  Future<void> _openAddTaskDialog(BuildContext context) async {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String priority = 'medium';
    
    // ✅ 1. ประกาศตัวแปร state สำหรับ location
    double? selectedLat;
    double? selectedLng;

    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) return;

    final authService = AuthService();
    final currentAppUser = await authService.getCurrentAppUser();
    final isAdmin = currentAppUser?.role == 'admin';

    if (!isAdmin) {
      return;
    }

    List<AppUser> assignees = [];
    String? selectedAssigneeId;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'employee')
        .get();

    assignees = snapshot.docs
        .map((doc) => AppUser.fromMap(doc.id, doc.data()))
        .toList();

    if (assignees.isNotEmpty) {
      selectedAssigneeId = assignees.first.uid;
    }

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.add_task,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('Add New Task'),
                ],
              ),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 500,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: titleCtrl,
                        decoration: InputDecoration(
                          labelText: 'Task Title',
                          hintText: 'Enter task title',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.title),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: descCtrl,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          hintText: 'Enter task description',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.description),
                          alignLabelWithHint: true,
                        ),
                        maxLines: 4,
                      ),
                      const SizedBox(height: 16),
                      if (assignees.isNotEmpty) ...[
                        DropdownButtonFormField<String>(
                          value: selectedAssigneeId,
                          decoration: InputDecoration(
                            labelText: 'Assign to',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: const Icon(Icons.person_add),
                          ),
                          items: assignees
                              .map(
                                (u) => DropdownMenuItem(
                                  value: u.uid,
                                  child: Text(u.email),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedAssigneeId = value;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                      DropdownButtonFormField<String>(
                        value: priority,
                        decoration: InputDecoration(
                          labelText: 'Priority Level',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.flag),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'low',
                            child: Row(
                              children: [
                                Icon(Icons.low_priority,
                                    size: 20, color: Colors.green),
                                SizedBox(width: 8),
                                Text('Low'),
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'medium',
                            child: Row(
                              children: [
                                Icon(Icons.drag_handle,
                                    size: 20, color: Colors.orange),
                                SizedBox(width: 8),
                                Text('Medium'),
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'high',
                            child: Row(
                              children: [
                                Icon(Icons.priority_high,
                                    size: 20, color: Colors.red),
                                SizedBox(width: 8),
                                Text('High'),
                              ],
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              priority = value;
                            });
                          }
                        },
                      ),
                      
                      // ✅ 2. ปุ่ม Set Task Location
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            try {
                              final pos = await LocationService.instance
                                  .getCurrentPosition();
                              setState(() {
                                selectedLat = pos.latitude;
                                selectedLng = pos.longitude;
                              });
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to get location: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          icon: Icon(
                            selectedLat == null
                                ? Icons.location_on_outlined
                                : Icons.location_on,
                          ),
                          label: Text(
                            selectedLat == null
                                ? 'Set Task Location'
                                : 'Location: ${selectedLat!.toStringAsFixed(5)}, ${selectedLng!.toStringAsFixed(5)}',
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            backgroundColor: selectedLat == null
                                ? Colors.blue.shade50
                                : Colors.green.shade50,
                            foregroundColor: selectedLat == null
                                ? Colors.blue.shade700
                                : Colors.green.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    if (titleCtrl.text.trim().isEmpty) return;
                    if (selectedAssigneeId == null) return;

                    final assignedUid = selectedAssigneeId!;

                    // ✅ 3. สร้าง Task พร้อม lat/lng
                    final task = Task(
                      id: '',
                      title: titleCtrl.text.trim(),
                      description: descCtrl.text.trim(),
                      status: 'todo',
                      createdBy: firebaseUser.uid,
                      assignedTo: assignedUid,
                      createdAt: DateTime.now(),
                      dueDate: null,
                      priority: priority,
                      updatedAt: DateTime.now(),
                      lat: selectedLat,
                      lng: selectedLng,
                    );

                    try {
                      final taskId =
                          await TaskService.instance.addTask(task);

                      final savedTask = task.copyWith(id: taskId);

                      await NotificationService.instance
                          .createTaskAssignedNotification(
                        task: savedTask,
                        adminUid: firebaseUser.uid,
                      );

                      Navigator.pop(context);
                    } catch (e, st) {
                      print('❌ Failed to add task: $e');
                      print(st);
                    }
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Add Task'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    titleCtrl.dispose();
    descCtrl.dispose();
  }
}

// ========================================
// 📋 NOTIFICATION BOTTOM SHEET WIDGET
// ========================================
class NotificationBottomSheet extends StatefulWidget {
  final String adminUid;

  const NotificationBottomSheet({super.key, required this.adminUid});

  @override
  State<NotificationBottomSheet> createState() =>
      _NotificationBottomSheetState();
}

class _NotificationBottomSheetState extends State<NotificationBottomSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Set<String> _removedNotificationIds = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width > 600;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              _buildHeader(isWeb),
              Expanded(
                child: StreamBuilder<List<AppNotification>>(
                  stream: NotificationService.instance
                      .streamForUser(widget.adminUid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final allNotifications = (snapshot.data ?? [])
                        .where((n) => !_removedNotificationIds.contains(n.id))
                        .toList();

                    return TabBarView(
                      controller: _tabController,
                      children: [
                        _buildNotificationList(
                          scrollController,
                          allNotifications,
                          isWeb,
                        ),
                        _buildNotificationList(
                          scrollController,
                          allNotifications.where((n) => !n.isRead).toList(),
                          isWeb,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(bool isWeb) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isWeb ? 32 : 20,
              vertical: 12,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.notifications_rounded,
                    color: Colors.blue.shade700,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const Spacer(),
                Material(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () async {
                      final notifs = await NotificationService.instance
                          .streamForUser(widget.adminUid)
                          .first;
                      setState(() {
                        _removedNotificationIds.addAll(
                          notifs.map((n) => n.id),
                        );
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.clear_all_rounded,
                            size: 18,
                            color: Colors.red.shade700,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Clear All',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(
              horizontal: isWeb ? 32 : 16,
              vertical: 8,
            ),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: Colors.blue.shade700,
              unselectedLabelColor: Colors.grey.shade600,
              labelStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              tabs: [
                Tab(
                  height: 44,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.inbox_rounded, size: 20),
                      SizedBox(width: 8),
                      Text('All'),
                    ],
                  ),
                ),
                Tab(
                  height: 44,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.circle, size: 20),
                      SizedBox(width: 8),
                      Text('Unread'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildNotificationList(
    ScrollController scrollController,
    List<AppNotification> notifications,
    bool isWeb,
  ) {
    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_off_outlined,
                size: 64,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No notifications',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You\'re all caught up!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isWeb ? 800 : double.infinity,
        ),
        child: ListView.builder(
          controller: scrollController,
          padding: EdgeInsets.symmetric(
            horizontal: isWeb ? 32 : 16,
            vertical: 12,
          ),
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final notif = notifications[index];
            return _buildNotificationCard(notif, isWeb);
          },
        ),
      ),
    );
  }

  Widget _buildNotificationCard(AppNotification notif, bool isWeb) {
    IconData icon;
    Color iconColor;

    switch (notif.type) {
      case NotificationService.typeTaskAssigned:
        icon = Icons.assignment_ind_rounded;
        iconColor = Colors.blue;
        break;
      case NotificationService.typeTaskInProgress:
        icon = Icons.play_circle_fill_rounded;
        iconColor = Colors.orange;
        break;
      case NotificationService.typeTaskDone:
        icon = Icons.check_circle_rounded;
        iconColor = Colors.green;
        break;
      default:
        icon = Icons.notifications_rounded;
        iconColor = Colors.grey;
    }

    return Dismissible(
      key: Key(notif.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(
          Icons.delete_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
      onDismissed: (direction) {
        setState(() {
          _removedNotificationIds.add(notif.id);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Notification removed'),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: notif.isRead ? Colors.white : Colors.blue.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: notif.isRead
                ? Colors.grey.shade200
                : Colors.blue.shade200,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () async {
              if (!notif.isRead) {
                await NotificationService.instance.markAsRead(notif.id);
              }
            },
            child: Padding(
              padding: EdgeInsets.all(isWeb ? 20 : 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: iconColor,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notif.message,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: notif.isRead
                                ? FontWeight.w500
                                : FontWeight.w600,
                            color: Colors.grey.shade800,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 14,
                              color: Colors.grey.shade500,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatTimestamp(notif.createdAt),
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}
