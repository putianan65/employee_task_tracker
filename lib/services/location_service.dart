import 'package:geolocator/geolocator.dart';

/// Service กลางสำหรับจัดการเรื่องตำแหน่ง (Location / GPS)
/// - ขอ permission
/// - ดึงตำแหน่งปัจจุบัน
/// - subscribe ดูตำแหน่งแบบ realtime
/// - คำนวณระยะทางระหว่าง 2 จุด (km)
class LocationService {
  LocationService._();
  static final LocationService instance = LocationService._();

  /// ✅ ตรวจสอบ + ขอสิทธิ์ใช้งาน Location
  /// ถ้า user ปฏิเสธ หรือปิด location service อยู่ → จะ throw Exception
  Future<void> _ensurePermission() async {
    // 1) เช็คว่าเปิด Location service อยู่ไหม (GPS / network)
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // บน web = ผู้ใช้ต้องเปิด location ใน browser
      throw Exception(
        'Location service ถูกปิดอยู่ กรุณาเปิด GPS หรืออนุญาตตำแหน่งในอุปกรณ์',
      );
    }

    // 2) เช็ค permission ปัจจุบัน
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      // ขอใหม่อีกรอบ
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception(
          'ไม่ได้รับอนุญาตให้ใช้ตำแหน่ง (permission denied)',
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // user เลือก "Don't ask again" หรือ block ถาวร
      throw Exception(
        'สิทธิ์การเข้าถึงตำแหน่งถูกบล็อกถาวร กรุณาเปิดสิทธิ์จาก Settings',
      );
    }

    // allowed → ทำงานต่อได้
  }

  /// ✅ ดึงตำแหน่งปัจจุบัน (lat / lng)
  /// ใช้สำหรับ:
  /// - กดปุ่ม "Set task location"
  /// - กด "Check-in"
  Future<Position> getCurrentPosition({
    LocationAccuracy accuracy = LocationAccuracy.high,
  }) async {
    await _ensurePermission();

    return Geolocator.getCurrentPosition(
      desiredAccuracy: accuracy,
    );
  }

  /// ✅ Stream ตำแหน่งแบบ realtime
  /// ใช้ในกรณี:
  /// - อยากดูการเคลื่อนที่ขณะทำงานภาคสนาม
  /// - ดู live location ระหว่าง check-in
  Stream<Position> watchPosition({
    LocationAccuracy accuracy = LocationAccuracy.best,
    int distanceFilterMeters = 5,
  }) {
    final settings = LocationSettings(
      accuracy: accuracy,
      distanceFilter: distanceFilterMeters,
    );

    return Geolocator.getPositionStream(locationSettings: settings);
  }

  /// ✅ คำนวณระยะทางระหว่าง 2 จุด (หน่วย: กิโลเมตร)
  /// เอาไว้ใช้เช็คว่า user อยู่ใกล้งานพอสำหรับ check-in หรือยัง เช่น <= 0.05 km (50 เมตร)
  double distanceKm({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) {
    final meters = Geolocator.distanceBetween(
      startLat,
      startLng,
      endLat,
      endLng,
    );
    return meters / 1000.0;
  }
}
