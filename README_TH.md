<p align="center">
  <img src="assets/Gistnu_new_logo.webp" alt="GIST NU Logo" width="120"/>
</p>

<h1 align="center">Employee Task Tracker</h1>

<p align="center">
  <strong>มินิโปรเจกต์ Flutter สำหรับฝึกฝนและเรียนรู้การพัฒนาแอปพลิเคชันมือถือเบื้องต้น</strong>
</p>

<p align="center">
  <a href="README.md">Read in English (EN)</a>
</p>

---

## เกี่ยวกับโปรเจกต์นี้

**Employee Task Tracker** เป็นมินิโปรเจกต์ที่ผมจัดทำขึ้น **ระหว่างรอ Requirement ของโปรเจกต์จริง** โดยมีจุดประสงค์เพื่อ **ฝึกฝนและเรียนรู้พื้นฐานการพัฒนาแอปพลิเคชันด้วย Flutter** ตั้งแต่การจัดการ State, การเชื่อมต่อ Firebase, ระบบ Role-Based Access Control ไปจนถึงการ Sync ข้อมูลแบบ Real-Time

> **หมายเหตุ:** โปรเจกต์นี้ **ไม่ใช่** แอปพลิเคชันสำหรับใช้งานจริง (Production) เป็นโปรเจกต์ส่วนตัวที่สร้างขึ้นเพื่อเรียนรู้แนวคิดของ Flutter แบบลงมือทำ

---

## ฟีเจอร์หลัก

| ฟีเจอร์ | รายละเอียด |
|---|---|
| **ระบบยืนยันตัวตน** | เข้าสู่ระบบ & สมัครสมาชิกด้วย Email/Password ผ่าน Firebase Auth รองรับการรีเซ็ตรหัสผ่าน |
| **ระบบแบ่งสิทธิ์ตามบทบาท** | แบ่งเป็น 2 บทบาท — **Admin** (เห็นงานทั้งหมด) และ **Employee** (เห็นเฉพาะงานที่ถูกมอบหมาย) |
| **จัดการงาน (Task Management)** | สร้าง, แก้ไข, อัปเดตสถานะ, มอบหมาย และลบงาน (CRUD) |
| **ติดตามสถานะงาน** | 3 สถานะ — `To Do` → `In Progress` → `Done` |
| **อัปเดตข้อมูลแบบ Real-Time** | ใช้ Firestore Streams ให้ข้อมูลอัปเดตทันทีข้ามอุปกรณ์ |
| **แจ้งเตือนในแอป** | แจ้งเตือนผู้สร้างงาน/Admin เมื่อมีการเปลี่ยนแปลงสถานะ |
| **แชทและคอมเมนต์ในงาน** | ระบบข้อความในแต่ละงาน รองรับ Emoji Reactions และแนบไฟล์ |
| **Checklist** | รายการย่อยภายในแต่ละงาน สำหรับติดตามความคืบหน้าอย่างละเอียด |
| **แผนที่แสดงตำแหน่งงาน** | เชื่อมต่อ Google Maps เพื่อแสดงตำแหน่งงานบนแผนที่ (บริเวณ GIST NU) |
| **บันทึกกิจกรรม (Activity Log)** | บันทึกทุกการกระทำที่เกิดขึ้นกับแต่ละงาน |
| **ธีมสวยงาม** | ออกแบบ Material Design Theme ที่เป็นเอกภาพทั่วทั้งแอป |

---

## เทคโนโลยีที่ใช้

| ส่วนประกอบ | เทคโนโลยี |
|---|---|
| **Framework** | Flutter (Dart) — SDK ^3.7.2 |
| **ระบบยืนยันตัวตน** | Firebase Auth |
| **ฐานข้อมูล** | Cloud Firestore (NoSQL แบบ Real-Time) |
| **แผนที่** | Google Maps Flutter |
| **ตำแหน่ง GPS** | Geolocator |
| **เครื่องมือเสริม** | intl (จัดรูปแบบวันที่), url_launcher |
| **สถาปัตยกรรม** | Service-based Pattern แยกเป็น Models, Services, Screens และ Widgets |

---

## โครงสร้างโปรเจกต์

```
lib/
├── main.dart                  # จุดเริ่มต้นของแอป & ตั้งค่า Route
├── firebase_options.dart      # ค่า Config ของ Firebase (สร้างอัตโนมัติ)
│
├── auth/
│   └── auth_service.dart      # เข้าสู่ระบบ, สมัครสมาชิก, ออกจากระบบ, รีเซ็ตรหัสผ่าน
│
├── models/
│   ├── task.dart              # โมเดลข้อมูลงาน
│   ├── user_model.dart        # โมเดลผู้ใช้พร้อมบทบาท (admin/employee)
│   ├── task_message.dart      # โมเดลข้อความแชทและไฟล์แนบ
│   ├── task_location.dart     # โมเดลข้อมูลตำแหน่ง
│   ├── checklist_item.dart    # โมเดลรายการ Checklist ย่อย
│   ├── activity_log.dart      # โมเดลบันทึกกิจกรรม
│   └── notification_model.dart # โมเดลการแจ้งเตือน
│
├── services/
│   ├── task_service.dart      # CRUD & Query งานตามบทบาท
│   ├── task_detail_service.dart # รายละเอียดงาน (แชท, Checklist ฯลฯ)
│   ├── notification_service.dart # ระบบแจ้งเตือนในแอป
│   └── location_service.dart  # เครื่องมือ GPS & ตำแหน่ง
│
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart      # หน้าเข้าสู่ระบบ
│   │   └── register_screen.dart   # หน้าสมัครสมาชิก
│   ├── task_list_screen.dart      # หน้ารายการงานหลัก (กรองตามบทบาท)
│   ├── task_form_screen.dart      # ฟอร์มสร้าง/แก้ไขงาน
│   ├── task_detail_dialog.dart    # รายละเอียดงานพร้อมแชท & Checklist
│   └── task_map_screen.dart       # หน้าแผนที่แสดงตำแหน่งงาน
│
├── widgets/
│   ├── task_card.dart         # Card แสดงรายการงาน
│   └── status_chip.dart       # Badge แสดงสถานะงาน
│
├── theme/
│   └── app_theme.dart         # ธีมหลักของแอป (Material Design)
│
└── utils/
    └── date_formatter.dart    # ฟังก์ชันจัดรูปแบบวันที่/เวลา
```

---

## สิ่งที่ได้เรียนรู้

จากการสร้างโปรเจกต์นี้ ผมได้ฝึกฝนแนวคิดของ Flutter & Firebase ดังนี้:

- **การเชื่อมต่อ Firebase** — ตั้งค่า Auth, Firestore และใช้งาน Real-Time Streams
- **การจัดการ State** — ใช้ `StreamBuilder` สำหรับ UI ที่อัปเดตแบบ Reactive
- **ระบบสิทธิ์ตามบทบาท (Role-Based Access Control)** — กรองข้อมูลและ UI ตามบทบาทผู้ใช้
- **CRUD Operations** — ขั้นตอนการสร้าง อ่าน อัปเดต ลบข้อมูลกับ Firestore ครบวงจร
- **การเชื่อมต่อ Google Maps** — แสดง Marker ตำแหน่งงานบนแผนที่
- **โครงสร้างโค้ดที่เป็นระเบียบ** — แยก Concern ออกเป็น Models, Services, Screens และ Widgets
- **Material Design** — สร้าง UI Component ที่มีธีมสอดคล้องกันทั้งแอป

---

## เริ่มต้นใช้งาน

### สิ่งที่ต้องมี

- Flutter SDK ^3.7.2
- Dart SDK
- Firebase Project (เปิดใช้ Auth + Firestore)
- Google Maps API Key (สำหรับฟีเจอร์แผนที่)

### วิธีติดตั้ง

```bash
# Clone repository
git clone https://github.com/putianan65/employee_task_tracker.git

# เข้าไปในโปรเจกต์
cd employee_task_tracker

# ติดตั้ง dependencies
flutter pub get

# รันแอป
flutter run
```

> คุณจะต้องตั้งค่า Firebase Project ของคุณเอง และอัปเดตไฟล์ `firebase_options.dart` ให้ตรงกับ Project ของคุณ

---

## สัญญาอนุญาต

โปรเจกต์นี้จัดทำขึ้นเพื่อ **วัตถุประสงค์ทางการศึกษาเท่านั้น** สามารถนำไปอ้างอิงเพื่อเรียนรู้ได้ตามสะดวก

---

<p align="center">
  สร้างด้วย Flutter & Firebase
</p>
