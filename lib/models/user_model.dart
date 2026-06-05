class AppUser {
  final String uid;
  final String email;
  final String role;

  AppUser({
    required this.uid,
    required this.email,
    required this.role,
  });

  /// สำหรับดึงข้อมูลจาก Firestore
  factory AppUser.fromMap(String uid, Map<String, dynamic> data) {
    return AppUser(
      uid: uid,
      email: data['email'] ?? '',
      role: data['role'] ?? 'employee',
    );
  }

  /// สำหรับบันทึกข้อมูลลง Firestore ตอน Register
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'role': role,
    };
  }
}
