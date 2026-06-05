import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';
import 'screens/auth/login_screen.dart';
import 'screens/task_list_screen.dart';
import 'screens/task_map_screen.dart';  // ⭐ เพิ่มไฟล์แผนที่

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const EmployeeTaskTrackerApp());
}

class EmployeeTaskTrackerApp extends StatelessWidget {
  const EmployeeTaskTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Employee Task Tracker',
      debugShowCheckedModeBanner: false,

      // ⭐ เพิ่ม route หน้าต่างๆ
      routes: {
        '/map': (_) => const TaskMapScreen(),   // หน้าแผนที่ GIST NU
      },

      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // โหลด Firebase อยู่ → แสดงวงกลมหมุน
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // ยังไม่ login → ไปหน้า login
          if (!snapshot.hasData) {
            return const LoginScreen();
          }

          // login แล้ว → ไปหน้า list งาน
          return const TaskListScreen();
        },
      ),
    );
  }
}
