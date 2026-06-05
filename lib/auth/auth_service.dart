import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:employee_task_tracker/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// สมัครสมาชิก + สร้าง users/{uid} ใน Firestore พร้อม role = employee
  Future<AppUser> register(String email, String password) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user!;
    final appUser = AppUser(
      uid: user.uid,
      email: email,
      role: 'employee', // default
    );

    // สร้าง document ใน collection users
    await _db.collection('users').doc(user.uid).set(appUser.toMap());

    return appUser;
  }

  /// เข้าสู่ระบบ และโหลด role จาก Firestore
  Future<AppUser?> login(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user;
    if (user == null) return null;

    final snapshot = await _db.collection('users').doc(user.uid).get();

    if (!snapshot.exists) {
      // เผื่อ user เก่าที่ไม่มี doc ใน users
      final fallbackUser = AppUser(
        uid: user.uid,
        email: user.email ?? email,
        role: 'employee',
      );
      await _db.collection('users').doc(user.uid).set(fallbackUser.toMap());
      return fallbackUser;
    }

    return AppUser.fromMap(user.uid, snapshot.data()!);
  }

  /// คืนค่า Firebase User ปัจจุบัน
  User? get currentFirebaseUser => _auth.currentUser;

  /// โหลด AppUser ปัจจุบัน (สำคัญมากสำหรับ role-based)
  Future<AppUser?> getCurrentAppUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final snapshot = await _db.collection('users').doc(user.uid).get();
    if (!snapshot.exists) return null;

    return AppUser.fromMap(user.uid, snapshot.data()!);
  }

  /// 🔐 ส่งลิงก์รีเซ็ตรหัสผ่านไปที่อีเมล
  Future<void> sendPasswordResetEmail(String email) async {
    final trimmed = email.trim();
    if (trimmed.isEmpty) {
      throw Exception('กรุณากรอกอีเมล');
    }

    await _auth.sendPasswordResetEmail(email: trimmed);
  }

  /// ออกจากระบบ
  Future<void> logout() async {
    await _auth.signOut();
  }
}
