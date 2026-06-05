import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/task.dart';          // ✅ แก้จาก ././ เป็น ../
import '../services/task_service.dart'; // ✅ แก้จาก ././ เป็น ../
import 'task_detail_dialog.dart';

class TaskMapScreen extends StatefulWidget {
  const TaskMapScreen({super.key});

  @override
  State<TaskMapScreen> createState() => _TaskMapScreenState();
}

class _TaskMapScreenState extends State<TaskMapScreen> {
  GoogleMapController? _mapController;

  /// จุดกลางเริ่มต้น (ประมาณ GIST NU / NU)
  static const LatLng _gistNuCenter = LatLng(16.7478, 100.1978);
  static const double _defaultZoom = 16;

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  /// Fit กล้องให้เห็นทุก marker
  void _fitToTasks(List<Task> tasks) {
    if (_mapController == null) return;

    final locTasks =
        tasks.where((t) => t.lat != null && t.lng != null).toList();
    if (locTasks.isEmpty) return;

    if (locTasks.length == 1) {
      final t = locTasks.first;
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(t.lat!, t.lng!),
            zoom: 18,
          ),
        ),
      );
      return;
    }

    double minLat = locTasks.first.lat!;
    double maxLat = locTasks.first.lat!;
    double minLng = locTasks.first.lng!;
    double maxLng = locTasks.first.lng!;

    for (final t in locTasks) {
      final lat = t.lat!;
      final lng = t.lng!;
      if (lat < minLat) minLat = lat;
      if (lat > maxLat) maxLat = lat;
      if (lng < minLng) minLng = lng;
      if (lng > maxLng) maxLng = lng;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 80),
    );
  }

  /// สร้าง Marker จากรายการ Task
  Set<Marker> _buildMarkers(BuildContext context, List<Task> tasks) {
    final markers = <Marker>{};

    for (final task in tasks) {
      if (task.lat == null || task.lng == null) continue;

      final pos = LatLng(task.lat!, task.lng!);

      // เลือกสี marker ตาม status
      double hue;
      switch (task.status) {
        case 'done':
          hue = BitmapDescriptor.hueGreen;
          break;
        case 'in_progress':
          hue = BitmapDescriptor.hueOrange;
          break;
        default:
          hue = BitmapDescriptor.hueAzure;
      }

      markers.add(
        Marker(
          markerId: MarkerId(task.id),
          position: pos,
          icon: BitmapDescriptor.defaultMarkerWithHue(hue),
          infoWindow: InfoWindow(
            title: task.title,
            snippet: task.priority.isNotEmpty
                ? 'Priority: ${task.priority}'
                : null,
            onTap: () {
              // กดที่ InfoWindow แล้วเปิด TaskDetailDialog
              showDialog(
                context: context,
                builder: (_) => TaskDetailDialog(
                  taskId: task.id,
                ),
              );
            },
          ),
          onTap: () {
            // แค่แตะ marker ให้ zoom เข้าไปนิดหน่อย
            _mapController?.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(target: pos, zoom: 18),
              ),
            );
          },
        ),
      );
    }

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = kIsWeb;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade600, Colors.blue.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.shade200.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.map_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Task Map',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  'GIST NU Location',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.grey.shade200,
                  Colors.grey.shade100,
                  Colors.grey.shade200,
                ],
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder<List<Task>>(
        stream: TaskService.instance.streamAllTasks(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.shade100.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.error_outline_rounded,
                          size: 56,
                          color: Colors.red.shade400,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Error Loading Tasks',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.shade100.withOpacity(0.5),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation(Colors.blue.shade600),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Loading map data...',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          final tasks = snapshot.data ?? [];
          final locTasks =
              tasks.where((t) => t.lat != null && t.lng != null).toList();

          if (tasks.isEmpty) {
            return Center(
              child: Container(
                padding: const EdgeInsets.all(40),
                margin: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade200,
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.task_alt_rounded,
                        size: 72,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'ยังไม่มีงานในระบบ',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.grey.shade800,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'เริ่มสร้างงานใหม่เพื่อดูบนแผนที่',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (locTasks.isEmpty) {
            return Center(
              child: Container(
                padding: const EdgeInsets.all(40),
                margin: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade200,
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.orange.shade100,
                            Colors.orange.shade50,
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.location_off_rounded,
                        size: 72,
                        color: Colors.orange.shade400,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'ยังไม่มีงานที่ตั้งค่าตำแหน่ง',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.grey.shade800,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.orange.shade200,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                size: 18,
                                color: Colors.orange.shade700,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'วิธีการแก้ไข',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.orange.shade700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'ให้ Admin ตั้งค่าพิกัดงานตอนสร้าง Task\nแล้วค่อยกลับมาดูแผนที่อีกครั้ง',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final markers = _buildMarkers(context, locTasks);

          return Stack(
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isWeb ? 1200 : double.infinity,
                  ),
                  child: Container(
                    margin: EdgeInsets.all(isWeb ? 16 : 0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(isWeb ? 20 : 0),
                      boxShadow: isWeb
                          ? [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ]
                          : null,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(isWeb ? 20 : 0),
                      child: GoogleMap(
                        onMapCreated: (controller) {
                          _onMapCreated(controller);
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _fitToTasks(locTasks);
                          });
                        },
                        initialCameraPosition: const CameraPosition(
                          target: _gistNuCenter,
                          zoom: _defaultZoom,
                        ),
                        markers: markers,
                        myLocationEnabled: false,
                        myLocationButtonEnabled: false,
                        zoomControlsEnabled: true,
                        mapToolbarEnabled: true,
                      ),
                    ),
                  ),
                ),
              ),
              // Legend / Status Indicator
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.palette_outlined,
                            size: 16,
                            color: Colors.grey.shade700,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Legend',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _buildLegendItem(
                        color: Colors.blue.shade400,
                        label: 'To Do',
                        icon: Icons.circle,
                      ),
                      const SizedBox(height: 6),
                      _buildLegendItem(
                        color: Colors.orange.shade400,
                        label: 'In Progress',
                        icon: Icons.circle,
                      ),
                      const SizedBox(height: 6),
                      _buildLegendItem(
                        color: Colors.green.shade400,
                        label: 'Done',
                        icon: Icons.circle,
                      ),
                    ],
                  ),
                ),
              ),
              // Task Counter
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.location_on_rounded,
                          size: 16,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${locTasks.length}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Tasks',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.shade300.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () {
            _mapController?.animateCamera(
              CameraUpdate.newCameraPosition(
                const CameraPosition(
                  target: _gistNuCenter,
                  zoom: _defaultZoom,
                ),
              ),
            );
          },
          icon: const Icon(Icons.center_focus_strong_rounded, size: 22),
          label: const Text(
            'Center Map',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              letterSpacing: 0.2,
            ),
          ),
          backgroundColor: Colors.blue.shade600,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required IconData icon,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: color,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }
}
