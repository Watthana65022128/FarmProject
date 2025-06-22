# 🌾 Smart Farm Management App

แอปพลิเคชันจัดการฟาร์มอัจฉริยะสำหรับเกษตรกรที่ต้องการติดตามและจัดการค่าใช้จ่ายในการเกษตรอย่างมีประสิทธิภาพ

## 📱 ภาพรวมโปรเจค

Smart Farm Management App เป็นแอปพลิเคชันมือถือที่พัฒนาด้วย Flutter สำหรับช่วยเกษตรกรในการ:
- 📊 จัดการงบประมาณและค่าใช้จ่ายในฟาร์ม
- 📷 สแกนใบเสร็จด้วยเทคโนโลยี OCR
- 📈 วิเคราะห์รายจ่ายและสร้างรายงาน
- 🔔 รับการแจ้งเตือนเมื่อใช้งบประมาณเกินกำหนด
- 👥 ระบบจัดการผู้ใช้งาน (สำหรับแอดมิน)

## ✨ ฟีเจอร์หลัก

### สำหรับเกษตรกร
- **🏡 จัดการไร่**: สร้างและจัดการข้อมูลไร่เกษตร
- **💰 งบประมาณ**: กำหนดและติดตามงบประมาณของแต่ละไร่
- **📱 สแกนใบเสร็จ**: ใช้กล้องสแกนใบเสร็จและแปลงข้อมูลอัตโนมัติ
- **📋 จัดหมวดหมู่รายจ่าย**: 
  - ค่าจัดการและการดูแล (อุปกรณ์, ค่าแรง, ขนส่ง)
  - ค่าใช้จ่ายในการผลิต (เมล็ดพันธุ์, สารเคมี, น้ำ, ไฟ, ปุ๋ย)
- **📊 รายงานและกราฟ**: แสดงสัดส่วนค่าใช้จ่ายแบบกราฟวงกลม
- **🔔 การแจ้งเตือน**: เตือนเมื่อใช้งบประมาณเกิน 60%, 80%, 90%
- **📱 ข้อมูลธุรกรรม**: ดูประวัติรายจ่ายตามช่วงเวลา

### สำหรับแอดมิน
- **👥 จัดการผู้ใช้**: ดูรายชื่อและจัดการบัญชีผู้ใช้
- **🚫 ระงับบัญชี**: ระงับ/ยกเลิกการระงับบัญชีผู้ใช้งาน
- **🔍 ค้นหาผู้ใช้**: ค้นหาผู้ใช้ด้วยชื่อหรืออีเมล

## 🛠️ เทคโนโลยีที่ใช้

### Frontend (Flutter)
- **Flutter** - Cross-platform mobile framework
- **Dart** - Programming language
- **fl_chart** - สำหรับสร้างกราฟและแผนภูมิ
- **image_picker** - เลือกรูปภาพจากกล้องและแกลเลอรี่
- **shared_preferences** - จัดเก็บข้อมูลในเครื่อง
- **http/dio** - HTTP client สำหรับการเชื่อมต่อ API
- **intl** - การจัดรูปแบบวันที่และตัวเลข
- **permission_handler** - จัดการสิทธิ์การเข้าถึง

### Backend Integration
- **REST API** - เชื่อมต่อกับ backend server
- **JWT Authentication** - ระบบยืนยันตัวตน
- **OCR Service** - บริการแปลงข้อความจากรูปภาพ
- **File Upload** - อัพโหลดรูปภาพใบเสร็จ

## 📋 การติดตั้งและใช้งาน

### ความต้องการของระบบ
- Flutter SDK 3.0+
- Dart 3.0+
- Android Studio / VS Code
- Android SDK (สำหรับ Android)
- Xcode (สำหรับ iOS)

### ขั้นตอนการติดตั้ง

1. **Clone repository**
```bash
git clone https://github.com/yourusername/farm-management-app.git
cd farm-management-app
```

2. **ติดตั้ง dependencies**
```bash
flutter pub get
```

3. **ตั้งค่า Backend URL**
แก้ไขไฟล์ในโฟลเดอร์ `lib/services/` และเปลี่ยน `baseUrl`:
```dart
static const String baseUrl = 'http://your-backend-url:3000/api';
```

4. **เรียกใช้แอป**
```bash
flutter run
```

### การตั้งค่าเพิ่มเติม

**Android**
- เพิ่มสิทธิ์ในไฟล์ `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.INTERNET" />
```

**iOS**
- เพิ่มสิทธิ์ในไฟล์ `ios/Runner/Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>ต้องการใช้กล้องเพื่อสแกนใบเสร็จ</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>ต้องการเข้าถึงรูปภาพเพื่อเลือกใบเสร็จ</string>
```

## 📁 โครงสร้างโปรเจค

```
lib/
├── auth/                   # ระบบยืนยันตัวตน
│   └── auth_service.dart
├── models/                 # Data models
│   ├── user_model.dart
│   ├── farm_model.dart
│   └── receipt_model.dart
├── screens/                # หน้าจอต่างๆ
│   ├── login.dart
│   ├── register.dart
│   ├── create_farm.dart
│   ├── farm_list.dart
│   ├── farm_info.dart
│   ├── scan.dart
│   ├── budget.dart
│   ├── notification.dart
│   └── admin_home.dart
├── services/               # API services
│   ├── farm_service.dart
│   ├── receipt_service.dart
│   ├── expense_service.dart
│   └── admin_service.dart
├── widgets/                # Components ที่ใช้ซ้ำ
│   ├── custom_navigation_bar.dart
│   ├── expense_pie_chart.dart
│   └── overview_card.dart
└── utils/                  # Utilities
    └── refreshable_state.dart
```

## 🔑 ฟีเจอร์เด่น

### 1. 📷 OCR Scan ใบเสร็จ
- ถ่ายภาพหรือเลือกรูปจากแกลเลอรี่
- แปลงข้อความในใบเสร็จเป็นข้อมูลอัตโนมัติ
- แก้ไขและจัดหมวดหมู่รายจ่าย

### 2. 📊 Dashboard แบบ Real-time
- แสดงสัดส่วนค่าใช้จ่ายด้วยกราฟวงกลม
- อัพเดทข้อมูลแบบทันที
- รองรับการ pull-to-refresh

### 3. 🔔 ระบบแจ้งเตือนอัจฉริยะ
- แจ้งเตือนตามระดับการใช้งบประมาณ
- แสดงข้อมูลการเตือนแบบภาพ
- คำแนะนำสำหรับการจัดการงบประมาณ

### 4. 👥 ระบบแอดมิน
- จัดการผู้ใช้งานแบบ Real-time
- ระงับ/ยกเลิกการระงับบัญชี
- ค้นหาและกรองข้อมูลผู้ใช้

## 🔒 ความปลอดภัย

- **JWT Authentication** - ระบบยืนยันตัวตนที่ปลอดภัย
- **Token Management** - จัดการ token อัตโนมัติ
- **Input Validation** - ตรวจสอบข้อมูลที่รับเข้ามา
- **Secure Storage** - จัดเก็บข้อมูลสำคัญอย่างปลอดภัย

## 🌐 API Endpoints

### Authentication
- `POST /api/register` - ลงทะเบียนผู้ใช้ใหม่
- `POST /api/login` - เข้าสู่ระบบ
- `GET /api/user/profile` - ดูข้อมูลโปรไฟล์
- `PUT /api/user/profile` - แก้ไขโปรไฟล์

### Farm Management
- `GET /api/farms` - ดูรายการไร่ทั้งหมด
- `POST /api/farm` - สร้างไร่ใหม่
- `PUT /api/farm/budget` - อัพเดทงบประมาณ
- `DELETE /api/farm/:id` - ลบไร่

### Receipt & Expenses
- `POST /api/receipts/scan` - สแกนใบเสร็จ
- `POST /api/receipts` - บันทึกใบเสร็จ
- `GET /api/receipts` - ดูรายการใบเสร็จ
- `GET /api/farms/:id/management-expenses` - ค่าจัดการ
- `GET /api/farms/:id/production-expenses` - ค่าผลิต

### Admin
- `GET /api/admin/users` - ดูรายการผู้ใช้ทั้งหมด
- `POST /api/admin/users/ban` - ระงับผู้ใช้
- `POST /api/admin/users/unban` - ยกเลิกการระงับ

## 📸 Screenshots

### หน้าจอหลัก
- หน้า Login/Register
- Dashboard ภาพรวม
- การจัดการไร่

### ฟีเจอร์สแกน
- การสแกนใบเสร็จ
- แก้ไขข้อมูล OCR
- บันทึกรายจ่าย

### การจัดการ
- หน้างบประมาณ
- การแจ้งเตือน
- ระบบแอดมิน

