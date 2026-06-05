import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/task.dart';
import '../models/user_model.dart';
import '../models/task_message.dart';
import '../models/checklist_item.dart';
import '../models/activity_log.dart';

import '../services/task_service.dart';
import '../services/task_detail_service.dart';
import '../services/notification_service.dart';
import '../services/location_service.dart';
import '../auth/auth_service.dart';

class TaskDetailDialog extends StatefulWidget {
  final String taskId;

  const TaskDetailDialog({
    super.key,
    required this.taskId,
  });

  @override
  State<TaskDetailDialog> createState() => _TaskDetailDialogState();
}

class _TaskDetailDialogState extends State<TaskDetailDialog>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final _chatController = TextEditingController();
  late AnimationController _fadeController;

  AppUser? _currentUser;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    )..forward();

    _loadCurrentUser().then((_) {
      _recordLocation();
    });
  }

  Future<void> _loadCurrentUser() async {
    final auth = AuthService();
    final user = await auth.getCurrentAppUser();
    if (mounted) setState(() => _currentUser = user);
  }

  Future<void> _recordLocation() async {
    try {
      final user = _currentUser;
      if (user == null) return;

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('📍 Location service is disabled');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        print('📍 Location permission denied');
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      await TaskDetailService.instance.logLocation(
        taskId: widget.taskId,
        lat: position.latitude,
        lng: position.longitude,
        uid: user.uid,
        email: user.email,
      );

      print(
          '📍 Logged location for task=${widget.taskId} at (${position.latitude}, ${position.longitude})');
    } catch (e, st) {
      print('📍 Error recordLocation: $e');
      print(st);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _chatController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 1000;
    final isTablet = screenWidth > 600;

    return Dialog(
      insetPadding: EdgeInsets.all(_getDialogPadding(screenWidth)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: FadeTransition(
        opacity: CurvedAnimation(
          parent: _fadeController,
          curve: Curves.easeOut,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: _getMaxWidth(screenWidth),
            maxHeight: _getMaxHeight(context),
          ),
          child: _currentUser == null
              ? const Center(child: CircularProgressIndicator())
              : StreamBuilder<Task?>(
                  stream:
                      TaskService.instance.streamTaskById(widget.taskId),
                  builder: (context, taskSnap) {
                    if (taskSnap.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                          child: CircularProgressIndicator());
                    }
                    final task = taskSnap.data;
                    if (task == null) {
                      return const Center(
                        child: Text(
                          'Task not found.',
                          style: TextStyle(fontSize: 16),
                        ),
                      );
                    }

                    if (isWide) {
                      return _buildWideLayout(task);
                    } else if (isTablet) {
                      return _buildTabbedLayout(task);
                    } else {
                      return _buildMobileLayout(task);
                    }
                  },
                ),
        ),
      ),
    );
  }

  double _getDialogPadding(double screenWidth) {
    if (screenWidth < 600) return 12;
    if (screenWidth < 1000) return 16;
    return 24;
  }

  double _getMaxWidth(double screenWidth) {
    if (screenWidth < 600) return double.infinity;
    if (screenWidth < 1000) return screenWidth * 0.95;
    return 1400;
  }

  double _getMaxHeight(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return screenHeight * 0.85;
  }

  Widget _buildWideLayout(Task task) {
    return Row(
      children: [
        Expanded(flex: 3, child: _buildOverview(task)),
        Container(
          width: 1,
          color: Colors.grey.shade200,
        ),
        Expanded(flex: 2, child: _buildChat(task)),
      ],
    );
  }

  Widget _buildTabbedLayout(Task task) {
    return Column(
      children: [
        _buildHeader(task),
        Container(
          color: Colors.grey.shade50,
          child: TabBar(
            controller: _tabController,
            labelColor: Colors.blue.shade700,
            unselectedLabelColor: Colors.grey.shade600,
            indicatorColor: Colors.blue.shade700,
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: const [
              Tab(text: 'Overview', icon: Icon(Icons.description_outlined)),
              Tab(text: 'Discussion', icon: Icon(Icons.forum_outlined)),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildOverview(task),
              _buildChat(task),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(Task task) {
    return Column(
      children: [
        _buildHeader(task),
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusRow(task),
                  const SizedBox(height: 16),
                  if (task.description != null &&
                      task.description!.isNotEmpty)
                    _buildDescriptionCard(task),
                  const SizedBox(height: 16),
                  _buildLocationButtons(task, isMobile: true),
                  const SizedBox(height: 16),
                  _buildChecklistSection(task),
                  const SizedBox(height: 16),
                  _buildActivitySection(task, compact: true),
                ],
              ),
            ),
          ),
        ),
        _buildChatInput(task),
      ],
    );
  }

  Widget _buildHeader(Task task) {
    final dueDate = task.dueDate;
    final now = DateTime.now();

    String deadlineText = 'No deadline';
    Color deadlineColor = Colors.grey;
    IconData deadlineIcon = Icons.schedule_outlined;

    if (dueDate != null) {
      final diff = dueDate.difference(now);
      if (diff.isNegative) {
        deadlineText = 'Overdue';
        deadlineColor = Colors.red;
        deadlineIcon = Icons.error_outline;
      } else if (diff.inHours < 24) {
        deadlineText = 'Due in ${diff.inHours}h';
        deadlineColor = Colors.orange;
        deadlineIcon = Icons.warning_outlined;
      } else {
        deadlineText = 'Due in ${diff.inDays}d';
        deadlineColor = Colors.green;
        deadlineIcon = Icons.check_circle_outline;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  task.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: deadlineColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: deadlineColor.withOpacity(0.3),
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(deadlineIcon, size: 14, color: deadlineColor),
                      const SizedBox(width: 4),
                      Text(
                        deadlineText,
                        style: TextStyle(
                          color: deadlineColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
            tooltip: 'Close',
          ),
        ],
      ),
    );
  }

  Widget _buildOverview(Task task) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(task),
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusRow(task),
                  const SizedBox(height: 20),
                  if (task.description != null &&
                      task.description!.isNotEmpty)
                    _buildDescriptionCard(task),
                  if (task.description != null &&
                      task.description!.isNotEmpty)
                    const SizedBox(height: 20),
                  _buildLocationButtons(task, isMobile: false),
                  const SizedBox(height: 20),
                  _buildChecklistSection(task),
                  const SizedBox(height: 20),
                  _buildActivitySection(task),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ✨ NEW: Location Buttons with Modern Material3 Design
  Widget _buildLocationButtons(Task task, {required bool isMobile}) {
    final hasLocation = task.lat != null && task.lng != null;
    
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildOpenMapsButton(task, hasLocation),
          const SizedBox(height: 10),
          _buildCheckInButton(task, hasLocation),
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(child: _buildOpenMapsButton(task, hasLocation)),
          const SizedBox(width: 12),
          Expanded(child: _buildCheckInButton(task, hasLocation)),
        ],
      );
    }
  }

  Widget _buildOpenMapsButton(Task task, bool hasLocation) {
    return AnimatedScale(
      scale: 1.0,
      duration: const Duration(milliseconds: 100),
      child: FilledButton.icon(
        onPressed: hasLocation
            ? () async {
                final lat = task.lat!;
                final lng = task.lng!;
                final url = Uri.parse(
                    'https://www.google.com/maps/search/?api=1&query=$lat,$lng');
                
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('ไม่สามารถเปิด Google Maps ได้'),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Colors.red.shade600,
                      ),
                    );
                  }
                }
              }
            : null,
        icon: Icon(
          Icons.map_outlined,
          size: 22,
          color: hasLocation ? Colors.white : Colors.grey.shade400,
        ),
        label: const Text(
          'Open in Google Maps',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: hasLocation ? Colors.blue.shade600 : Colors.grey.shade300,
          foregroundColor: hasLocation ? Colors.white : Colors.grey.shade500,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: hasLocation ? 2 : 0,
          shadowColor: Colors.blue.shade200,
        ).copyWith(
          overlayColor: MaterialStateProperty.resolveWith<Color?>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.pressed)) {
                return Colors.white.withOpacity(0.2);
              }
              if (states.contains(MaterialState.hovered)) {
                return Colors.white.withOpacity(0.1);
              }
              return null;
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCheckInButton(Task task, bool hasLocation) {
    return AnimatedScale(
      scale: 1.0,
      duration: const Duration(milliseconds: 100),
      child: FilledButton.icon(
        onPressed: hasLocation
            ? () async {
                try {
                  final user = _currentUser;
                  if (user == null) return;

                  // Show loading
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: const [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('กำลัง Check-in...'),
                          ],
                        ),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }

                  // Get current position
                  final position = await Geolocator.getCurrentPosition(
                    desiredAccuracy: LocationAccuracy.high,
                  );

                  // Record check-in
                  // await LocationService.instance.recordCheckIn(
                  //  taskId: task.id,
                  //  lat: position.latitude,
                  //  lng: position.longitude,
                  //  uid: user.uid,
                  //  email: user.email,
                 // );

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: const [
                            Icon(Icons.check_circle, color: Colors.white, size: 20),
                            SizedBox(width: 12),
                            Text('Check-in สำเร็จ!'),
                          ],
                        ),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Colors.green.shade600,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('เกิดข้อผิดพลาด: $e'),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Colors.red.shade600,
                      ),
                    );
                  }
                }
              }
            : null,
        icon: Icon(
          Icons.location_on,
          size: 22,
          color: hasLocation ? Colors.white : Colors.grey.shade400,
        ),
        label: const Text(
          'Check-in',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: hasLocation ? Colors.green.shade600 : Colors.grey.shade300,
          foregroundColor: hasLocation ? Colors.white : Colors.grey.shade500,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: hasLocation ? 2 : 0,
          shadowColor: Colors.green.shade200,
        ).copyWith(
          overlayColor: MaterialStateProperty.resolveWith<Color?>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.pressed)) {
                return Colors.white.withOpacity(0.2);
              }
              if (states.contains(MaterialState.hovered)) {
                return Colors.white.withOpacity(0.1);
              }
              return null;
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDescriptionCard(Task task) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.blue.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            task.description!,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(Task task) {
    final user = _currentUser!;
    final isAdmin = user.role == 'admin';
    final canEdit = isAdmin || task.assignedTo == user.uid;

    Color statusColor(String s) {
      switch (s) {
        case 'done':
          return Colors.green;
        case 'in_progress':
          return Colors.orange;
        default:
          return Colors.blue;
      }
    }

    final statusItems = const [
      {'value': 'todo', 'label': 'To Do'},
      {'value': 'in_progress', 'label': 'In Progress'},
      {'value': 'done', 'label': 'Done'},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: statusColor(task.status).withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor(task.status).withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Status: ',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: task.status,
              items: statusItems
                  .map(
                    (e) => DropdownMenuItem(
                      value: e['value']!,
                      child: Text(
                        e['label']!,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: statusColor(e['value']!),
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: canEdit
                  ? (value) async {
                      if (value == null || value == task.status) return;
                      final old = task.status;

                      await TaskService.instance
                          .updateTaskStatus(task.id, value);

                      await TaskDetailService.instance.logStatusChange(
                        task: task,
                        fromStatus: old,
                        toStatus: value,
                        actorId: user.uid,
                        actorName: user.email,
                      );

                      await NotificationService.instance
                          .createTaskStatusNotification(
                        task: task.copyWith(status: value),
                        newStatus: value,
                        actorUid: user.uid,
                      );
                    }
                  : null,
              style: TextStyle(
                color: statusColor(task.status),
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
              icon: Icon(
                Icons.arrow_drop_down,
                color: statusColor(task.status),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistSection(Task task) {
    final user = _currentUser!;
    final isAdmin = user.role == 'admin';
    final isAssignee = task.assignedTo == user.uid;
    final canEdit = isAdmin || isAssignee;

    return StreamBuilder<List<ChecklistItem>>(
      stream: TaskDetailService.instance.streamChecklist(task.id),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snap.hasData) return const SizedBox.shrink();

        final items = snap.data!;
        final total = items.length;
        final done = items.where((i) => i.isDone).length;
        final progress = total == 0 ? 0.0 : done / total;

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.checklist_outlined,
                      size: 18, color: Colors.grey.shade700),
                  const SizedBox(width: 8),
                  const Text(
                    'Checklist',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (total > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$done/$total',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  const Spacer(),
                  if (isAdmin)
                    Tooltip(
                      message: 'Add checklist item',
                      child: SizedBox(
                        width: 32,
                        height: 32,
                        child: IconButton(
                          icon: const Icon(Icons.add_circle_outline, size: 20),
                          padding: EdgeInsets.zero,
                          onPressed: () async {
                            final title =
                                await _showAddChecklistItemDialog();
                            if (title != null && title.trim().isNotEmpty) {
                              await TaskDetailService.instance
                                  .addChecklistItem(
                                task.id,
                                title.trim(),
                                total,
                              );
                            }
                          },
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation(
                    progress == 1.0 ? Colors.green : Colors.blue,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              if (items.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'No items yet',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ...items.asMap().entries.map((entry) {
                final item = entry.value;
                final idx = entry.key;
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: idx < items.length - 1 ? 8 : 0,
                  ),
                  child: _buildChecklistItem(task, item, canEdit),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChecklistItem(Task task, ChecklistItem item, bool canEdit) {
    final user = _currentUser!;
    final isAdmin = user.role == 'admin';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: item.isDone ? Colors.green.shade200 : Colors.grey.shade200,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Checkbox(
            value: item.isDone,
            onChanged: canEdit
                ? (value) {
                    TaskDetailService.instance.toggleChecklistItem(
                      task.id,
                      item.id,
                      value ?? false,
                    );
                  }
                : null,
          ),
          Expanded(
            child: Text(
              item.title,
              style: TextStyle(
                fontSize: 14,
                decoration:
                    item.isDone ? TextDecoration.lineThrough : null,
                color: item.isDone ? Colors.grey.shade500 : Colors.black,
              ),
            ),
          ),
          if (isAdmin)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Tooltip(
                  message: 'Edit',
                  child: IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(),
                    onPressed: () async {
                      final newTitle =
                          await _showEditChecklistItemDialog(item.title);
                      if (newTitle != null && newTitle.trim().isNotEmpty) {
                        await TaskDetailService.instance
                            .updateChecklistItem(
                          task.id,
                          item.id,
                          newTitle.trim(),
                        );
                      }
                    },
                  ),
                ),
                Tooltip(
                  message: 'Delete',
                  child: IconButton(
                    icon: const Icon(Icons.delete_outline,
                        size: 16, color: Colors.red),
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(),
                    onPressed: () => _showDeleteConfirmation(
                      title: item.title,
                      onConfirm: () async {
                        await TaskDetailService.instance.deleteChecklistItem(
                          task.id,
                          item.id,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Future<String?> _showAddChecklistItemDialog() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add checklist item'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Title',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.pop(context, controller.text.trim()),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    controller.dispose();
    return result;
  }

  Future<String?> _showEditChecklistItemDialog(String currentTitle) async {
    final controller = TextEditingController(text: currentTitle);
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit checklist item'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Title',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.pop(context, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    return result;
  }

  void _showDeleteConfirmation({
    required String title,
    required Future<void> Function() onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Delete item?'),
        content: Text('Are you sure you want to delete "$title"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () async {
              Navigator.pop(dialogCtx);
              await onConfirm();
            },
            child:
                const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildActivitySection(Task task, {bool compact = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.timeline_outlined,
                size: 18, color: Colors.grey.shade700),
            const SizedBox(width: 8),
            const Text(
              'Activity',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: compact ? 150 : 200,
          child: StreamBuilder<List<ActivityLog>>(
            stream: TaskDetailService.instance.streamActivities(task.id),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snap.hasData || snap.data!.isEmpty) {
                return Center(
                  child: Text(
                    'No activity yet',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 13,
                    ),
                  ),
                );
              }
              final activities = snap.data!;
              return ListView.separated(
                itemCount: activities.length,
                separatorBuilder: (_, __) =>
                    Divider(height: 1, color: Colors.grey.shade200),
                itemBuilder: (context, index) {
                  final a = activities[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(Icons.bolt_outlined,
                              size: 16, color: Colors.blue.shade700),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                a.message,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _formatTime(a.createdAt),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt.toLocal());

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';

    return '${dt.toLocal().month}/${dt.toLocal().day}';
  }

  Widget _buildChat(Task task) {
    final user = _currentUser!;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(Icons.forum_outlined, color: Colors.grey.shade700),
              const SizedBox(width: 8),
              const Text(
                'Discussion',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        Container(height: 1, color: Colors.grey.shade200),
        Expanded(
          child: StreamBuilder<List<TaskMessage>>(
            stream: TaskDetailService.instance.streamMessages(task.id),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snap.hasData || snap.data!.isEmpty) {
                return Center(
                  child: Text(
                    'No messages yet. Start a discussion!',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 13,
                    ),
                  ),
                );
              }
              final messages = snap.data!;
              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final m = messages[index];
                  final isMe = m.senderId == user.uid;
                  return _buildMessageBubble(task.id, m, isMe);
                },
              );
            },
          ),
        ),
        _buildChatInput(task),
      ],
    );
  }

  Widget _buildMessageBubble(String taskId, TaskMessage m, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(11),
        constraints: const BoxConstraints(maxWidth: 300),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue.shade500 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Text(
                m.senderName,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
            if (!isMe) const SizedBox(height: 4),
            Text(
              m.text,
              style: TextStyle(
                fontSize: 14,
                color: isMe ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            _buildReactionsRow(taskId, m, isMe),
          ],
        ),
      ),
    );
  }

  Widget _buildReactionsRow(String taskId, TaskMessage m, bool isMe) {
    final emojiList = ['👍', '❤️', '🔥', '👀'];
    final uid = _currentUser!.uid;

    return Wrap(
      spacing: 4,
      children: emojiList.map((emoji) {
        final users = m.reactions[emoji] ?? [];
        final isReacted = users.contains(uid);
        return InkWell(
          onTap: () {
            TaskDetailService.instance.toggleReaction(
              taskId: taskId,
              messageId: m.id,
              emoji: emoji,
              uid: uid,
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isReacted
                  ? (isMe
                      ? Colors.white.withOpacity(0.3)
                      : Colors.blue.shade100)
                  : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 12)),
                if (users.isNotEmpty) ...[
                  const SizedBox(width: 2),
                  Text(
                    '${users.length}',
                    style: TextStyle(
                      fontSize: 10,
                      color: isMe ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildChatInput(Task task) {
    final user = _currentUser!;
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
          color: Colors.grey.shade50,
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.shade300, width: 0.5),
                ),
                child: TextField(
                  controller: _chatController,
                  minLines: 1,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Write a comment...',
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.blue.shade500,
                borderRadius: BorderRadius.circular(50),
              ),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: () async {
                  final text = _chatController.text.trim();
                  if (text.isEmpty) return;

                  await TaskDetailService.instance.sendMessage(
                    task: task,
                    sender: user,
                    text: text,
                  );
                  _chatController.clear();
                },
                tooltip: 'Send message',
              ),
            ),
          ],
        ),
      ),
    );
  }
}