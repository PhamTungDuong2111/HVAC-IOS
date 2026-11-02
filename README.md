# DuctWise HVAC Duct Calculator for iOS (HVAC-IOS)

> **Phần mềm Tiện ích Chuyên ngành HVAC trên iOS: Tính toán & Thiết kế Kích thước Đường ống Gió Chuẩn ASHRAE Fundamentals, SMACNA & ACCA Manual D.**  
> *Phiên bản hoàn toàn bản địa hóa (Native SwiftUI) dành cho iPhone & iPad, hỗ trợ biên dịch trực tiếp bằng Xcode, chạy mượt mà trên thiết bị thật, giao diện hiện đại Dark Theme, hỗ trợ song ngữ (Tiếng Việt & English) và hoạt động 100% ngoại tuyến (Offline-First).*

[![Platform: iOS 16+](https://img.shields.io/badge/Platform-iOS%2016%2B-blue.svg?logo=apple)](https://developer.apple.com/ios/)
[![Swift: 5.0+](https://img.shields.io/badge/Swift-5.0%2B-orange.svg?logo=swift)](https://swift.org)
[![HVAC Standards](https://img.shields.io/badge/Standards-ASHRAE%20%7C%20SMACNA%20%7C%20ACCA%20Manual%20D-0284c7)](https://www.ashrae.org)
[![Offline-First](https://img.shields.io/badge/Offline-100%25%20Ready-10b981)](#)

---

## 🎯 Giới thiệu Dự án (Project Overview)

**DuctWise HVAC iOS** là ứng dụng di động chuyên sâu cho kỹ sư cơ điện (MEP), kỹ sư thiết kế nhiệt - lạnh và nhà thầu HVAC. Ứng dụng cung cấp đầy đủ các công cụ tính toán thủy lực đường ống gió theo tiêu chuẩn quốc tế, kiểm tra lắp đặt thực địa, quản lý tổn thất tĩnh áp và xuất tài liệu kỹ thuật PDF chuyên nghiệp trực tiếp từ iPhone hoặc iPad.

---

## ✨ Các Tính Năng Chính (Key Features)

### 1. 📐 Tính toán Kích thước & Tương đương Huebscher (Duct Sizer & Huebscher)
- **Phương trình Huebscher (Huebscher Equation):** Quy đổi chính xác giữa ống tròn và ống chữ nhật (hoặc ống oval dẹt) theo hệ số ma sát tương đương (*Equal Friction Method*):
  $$D_e = 1.30 \times \frac{(a \times b)^{0.625}}{(a + b)^{0.25}}$$
- **Giải pháp đa chế độ (Sizing Methods):**
  - Ma sát tương đương (*Equal Friction Method* - in.wg/100ft hoặc Pa/m).
  - Vận tốc không đổi (*Velocity Method* - FPM hoặc m/s).
  - Kiểm tra tiết diện có sẵn (*Known Dimensions*).
- **Khóa kích thước linh hoạt:** Khóa chiều rộng, khóa chiều cao hoặc tự động cân bằng tỷ lệ tối ưu (~1.5:1).
- **Gợi ý kích thước thương mại sẵn kho (Stock Size Suggestions):** Đề xuất 4 kích thước thương mại tiêu chuẩn (Ø tròn hoặc chữ nhật) gần nhất kèm độ lệch lưu lượng (%) và vận tốc thực tế, áp dụng nhanh với 1 chạm.
- **Thanh đo Tỷ lệ Khung hình (Aspect Ratio Gauge):** Cảnh báo trực quan bằng màu sắc (Xanh $\le 2:1$, Cyan $\le 3:1$, Cam $\le 4:1$, Đỏ $> 4:1$). Bật cảnh báo ASHRAE nếu vượt quá giới hạn $4:1$ để chống hiện tượng rung lắc thành ống (*oil-canning*) và tổn thất áp suất cao.
- **Đề xuất độ dày tôn chuẩn SMACNA (Gauge Recommendation):** Tự động xác định độ dày tôn mạ kẽm (26 ga, 24 ga, 22 ga, 20 ga, 18 ga) và diện tích bề mặt tôn phục vụ bóc tách dự toán.

### 2. 🏗️ Mô phỏng Không gian Khoang Dầm (Fits the Bay Simulator)
- **Mặt cắt 2D theo tỷ lệ thực (Real-time 2D Scaled Canvas):** Mô phỏng trực quan hình ảnh ống gió đặt bên trong khoang dầm trần (*joist cavity*).
- **Quy cách dầm tiêu chuẩn:** Dầm gỗ 2x8, 2x10, 2x12 (khoảng cách 16" hoặc 24" O.C.), dầm sàn thép/hộp 14", và khoang kỹ thuật tùy chỉnh (*Custom Framing*).
- **Tính toán bảo ôn & tiêu âm:** Hỗ trợ bảo ôn ngoài (wrap 1.5", 2.0") hoặc tiêu âm trong (liner 0.5", 1.0") vào kích thước bao phủ.
- **Xoay ống 90° (Rotate 90°):** Thử nghiệm nhanh phương án xoay dẹt ống để luồn qua khoang dầm hẹp.
- **Đánh giá trạng thái lắp đặt tức thì:**
  - 🟢 **PASS:** Vừa vặn thoải mái (Khoảng hở $\ge 1.0"$).
  - 🟡 **TIGHT:** Khá chật (Khoảng hở $< 1.0"$, cần chú ý ty treo).
  - 🔴 **CONFLICT:** Không vừa! Kích thước phủ bì vượt quá khoang dầm.

### 3. ⏱️ Kiểm tra Vận tốc & Đồng hồ Tốc độ (Velocity & Design Bands)
- **Đồng hồ đo vận tốc tương tác (Speedometer Gauge):** Hiển thị kim đo thời gian thực so với dải vận tốc tối ưu và vạch cảnh báo tiếng ồn.
- **Thư viện Dải vận tốc ASHRAE & ACCA Manual D:**
  - Ống chính cấp gió dân dụng (*Residential Supply Trunk*: 700 - 900 FPM, NC 25-30)
  - Ống nhánh cấp gió dân dụng (*Residential Supply Branch*: 500 - 700 FPM, NC 20-25)
  - Ống chính hồi gió dân dụng (*Residential Return Trunk*: 600 - 700 FPM, NC 25-30)
  - Ống nhánh hồi gió dân dụng (*Residential Return Branch*: 400 - 600 FPM, NC 20-25)
  - Ống chính cấp thương mại (*Commercial Supply Main*: 1000 - 1500 FPM, NC 30-35)
  - Ống nhánh cấp thương mại (*Commercial Supply Branch*: 800 - 1200 FPM, NC 25-30)
  - Ống hồi thương mại (*Commercial Return Main*: 800 - 1200 FPM, NC 30-35)
  - Hệ thống hút khí thải / thông gió (*Exhaust/Ventilation*: 1200 - 1800 FPM)
  - Khu vực nhạy cảm âm thanh / Bệnh viện (*Acoustic Sensitive*: 350 - 500 FPM, NC 15-20)
- **Áp dụng 1 chạm:** Chuyển ngay thông số vận tốc và ma sát tiêu chuẩn sang tab tính toán.

### 4. 💨 Ngân sách Tĩnh áp & ACCA Manual D (Static Budget Manager)
- **Tổng chiều dài tương đương (TEL - Total Equivalent Length):**
  - Chiều dài ống thẳng (Straight Length).
  - Danh mục phụ kiện đầy đủ với bộ đếm số lượng: Co vuông 90° có cánh/không cánh, co mitered, chếch 45°, tê chia nhánh, tê chạy thẳng, cổ trích gió côn/thẳng, hộp miệng gió, van chỉnh gió.
- **Tổn thất các thiết bị phụ trợ (Component Pressure Drops):**
  - Dàn lạnh (Cooling Coil), phin lọc MERV 8/11/13, miệng gió cấp/hồi, van gió điện, điện trở sấy.
- **Tính toán Tĩnh áp Khả dụng (ASP) & Tỷ lệ Ma sát Thiết kế:**
  $$\text{ASP} = \text{Blower Rated ESP} - \sum \Delta P_{\text{components}}$$
  $$\text{Design Friction Rate} = \frac{\text{ASP} \times 100}{\text{TEL}}$$
- **Nút chuyển nhanh giá trị ma sát thiết kế sang tab Sizer.**

### 5. 📋 Lịch trình Ống gió & Xuất Báo cáo PDF (Duct Schedule & PDF Export)
- Quản lý danh mục các đoạn ống đã tính toán với đầy đủ thông số kỹ thuật (Tag, Mô tả, Kích thước, Lưu lượng, Vận tốc, Tổn thất áp, Độ dày tôn, Diện tích tôn).
- Thẻ thống kê tổng hợp: Tổng số đoạn ống, Tổng lưu lượng CFM, Tổng chiều dài mét/feet, Tổng diện tích tôn m²/sqft.
- Chức năng Nhân bản (Duplicate), Xóa từng dòng hoặc Xóa toàn bộ.
- **Xuất PDF Kỹ thuật Chuyên nghiệp:** Tạo tài liệu PDF khổ A4 ngang bằng `UIGraphicsPDFRenderer` tiêu chuẩn kỹ thuật với bảng quy cách, ghi chú mật độ không khí, khung chữ ký nghiệm thu và chia sẻ qua iOS Share Sheet (AirDrop, Mail, Zalo, Files...).

### 6. 🏔️ Hiệu chỉnh Độ cao & Nhiệt độ (Altitude & Air Density)
- Tự động hiệu chỉnh mật độ không khí ($\rho / \rho_0$) theo công thức khí quyển chuẩn dựa trên độ cao từ $-1000$ đến $15,000$ ft (hoặc mét) và nhiệt độ từ $-40$ đến $200$ °F (hoặc °C).
- Cập nhật tự động hệ số tổn thất áp suất dòng khí cho toàn bộ ứng dụng.

---

## 🛠️ Cấu trúc Thư mục Dự án (Project Architecture)

```
HVAC-IOS/
├── HVAC-IOS.xcodeproj/         # Xcode Project File
│   └── project.pbxproj         # Cấu hình Build Settings, Targets, Sources
├── HVAC-IOS/
│   ├── App/
│   │   ├── HVACApp.swift       # @main App Entry Point
│   │   ├── ContentView.swift   # Giao diện chính với Header & TabView
│   │   └── Info.plist          # Cấu hình quyền và thông tin ứng dụng iOS
│   ├── Models/
│   │   ├── AppState.swift      # Trạng thái toàn cục của ứng dụng
│   │   ├── DuctRun.swift       # Đối tượng đoạn ống gió (Schedule Item)
│   │   └── Presets.swift       # Dữ liệu mẫu (Stock sizes, bands, joists, fittings)
│   ├── Core/
│   │   ├── HvacFormulas.swift  # Công thức Huebscher, Darcy-Weisbach, mật độ khí
│   │   ├── Standards.swift     # Tiêu chuẩn ASHRAE Fundamentals, SMACNA, Manual D
│   │   ├── UnitConverter.swift # Chuyển đổi hai chiều hệ IP (Anh-Mỹ) <-> SI (Mét)
│   │   └── I18n.swift          # Song ngữ Tiếng Việt & English (217 thuật ngữ)
│   ├── ViewModels/
│   │   └── DuctWiseViewModel.swift # Quản lý logic nghiệp vụ và dữ liệu
│   ├── Views/
│   │   ├── Components/
│   │   │   ├── AppHeaderView.swift        # Thanh tiêu đề trên cùng với nút đổi ngôn ngữ & đơn vị
│   │   │   ├── SpeedometerGaugeView.swift # Đồng hồ đo vận tốc dạng kim xoay
│   │   │   ├── JoistBayCanvasView.swift   # Khung mô phỏng 2D khoang dầm
│   │   │   └── AspectBarView.swift        # Thanh đo tỷ lệ khung hình & cảnh báo
│   │   └── Screens/
│   │       ├── SizerView.swift        # Màn hình tính toán kích thước ống
│   │       ├── FitsTheBayView.swift   # Màn hình mô phỏng lắp dầm
│   │       ├── VelocityView.swift     # Màn hình dải vận tốc & đồng hồ đo
│   │       ├── StaticBudgetView.swift # Màn hình tĩnh áp & ACCA Manual D
│   │       ├── JobListView.swift      # Màn hình danh mục & xuất file PDF
│   │       └── AltitudeView.swift     # Màn hình hiệu chỉnh độ cao
│   ├── Export/
│   │   └── PdfExporter.swift   # Trình xuất file PDF chuẩn đồ họa vector
│   ├── Theme/
│   │   └── AppTheme.swift      # Bảng màu Dark Mode chuyên nghiệp
│   └── Assets.xcassets/        # Tài nguyên biểu tượng ứng dụng và màu sắc
├── .gitignore
└── README.md
```

---

## 📱 Hướng Dẫn Biên Dịch & Chạy Bằng Xcode (How to Build & Run)

### 1. Yêu cầu Hệ thống
- Máy Mac chạy **macOS Ventura 13.0** trở lên.
- **Xcode 14.0** trở lên (Khuyến nghị Xcode 15 hoặc 16).
- Thiết bị iOS (iPhone / iPad) chạy **iOS 16.0** trở lên hoặc iOS Simulator.
- Tài khoản Apple ID (Tài khoản Apple Developer miễn phí hoặc trả phí).

### 2. Các Bước Mở và Build Trên Máy Thật (Step-by-Step Build on Physical Device)

1. **Tải hoặc Clone dự án về máy Mac:**
   ```bash
   git clone https://github.com/PhamTungDuong2111/HVAC-IOS.git
   cd HVAC-IOS
   ```

2. **Mở dự án trong Xcode:**
   - Nhấp đúp vào file `HVAC-IOS.xcodeproj` hoặc gõ lệnh trong Terminal:
     ```bash
     open HVAC-IOS.xcodeproj
     ```

3. **Cấu hình Signing (Ký mã bản dựng):**
   - Trong thanh điều hướng bên trái của Xcode, bấm vào biểu tượng dự án gốc **HVAC-IOS** (màu xanh).
   - Chọn thẻ **Signing & Capabilities**.
   - Đảm bảo ô **Automatically manage signing** đã được đánh dấu tích chọn.
   - Tại mục **Team**, nhấp vào menu thả xuống và chọn tài khoản Apple ID của bạn (ví dụ: *Pham Tung Duong (Personal Team)*).
   - Nếu Bundle Identifier (`com.ductwise.hvac`) trùng lặp với tài khoản khác, bạn có thể chỉnh nhẹ thành `com.phamduong.hvac` hoặc bất kỳ ID duy nhất nào.

4. **Kết nối Thiết bị Thật:**
   - Kết nối iPhone/iPad của bạn với máy Mac qua cáp Lightning/USB-C hoặc qua mạng Wi-Fi cùng lớp mạng.
   - Mở khóa iPhone và bấm **Tin cậy máy tính này** (*Trust This Computer*) nếu được hỏi.
   - Trên thanh công cụ trên cùng của Xcode (mục Scheme Target), bấm chọn thiết bị của bạn thay vì máy ảo Simulator.

5. **Chạy ứng dụng (Build & Run):**
   - Nhấn tổ hợp phím **`Cmd + R`** hoặc bấm nút **Play ▶** ở góc trên bên trái Xcode.
   - Xcode sẽ tự động biên dịch toàn bộ mã nguồn Swift và cài đặt trực tiếp lên iPhone/iPad của bạn.

> 💡 **Mẹo cho thiết bị chạy lần đầu tiên:**  
> Nếu trên iPhone hiển thị thông báo *Untrusted Developer Certificate*, bạn chỉ cần vào:  
> **Cài đặt (Settings)** ➔ **Cài đặt chung (General)** ➔ **Quản lý VPN & Thiết bị (VPN & Device Management)** ➔ Chọn Apple ID của bạn và bấm **Tin cậy (Trust)**. Sau đó mở ứng dụng và sử dụng bình thường.

---

## 📜 Tiêu Chuẩn Tham Chiếu Kỹ Thuật (Engineering References)

- **ASHRAE Handbook - Fundamentals (Chapter 21: Duct Design)**: Phương trình Huebscher, ma sát Darcy-Weisbach và dải vận tốc dòng khí.
- **SMACNA HVAC Duct Construction Standards - Metal and Flexible (4th Edition)**: Quy chuẩn độ dày tôn mạ kẽm (gauge) và bán kính uốn phụ kiện.
- **ACCA Manual D (Residential Duct Systems)**: Chiều dài tương đương của phụ kiện (TEL) và phương pháp tính toán ngân sách tĩnh áp khả dụng (ASP).

---

## 👨‍💻 Tác Giả & Bản Quyền

- **Tác giả:** Pham Tung Duong
- **Mã nguồn:** [GitHub - HVAC-IOS](https://github.com/PhamTungDuong2111/HVAC-IOS.git)
- **Giấy phép:** MIT License

