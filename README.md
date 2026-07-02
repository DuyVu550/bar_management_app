# Bar Manager App 🍹📊

Ứng dụng quản lý vận hành Quán Bar / Nhà Hàng thời gian thực (Realtime) được phát triển trên nền tảng **Flutter** áp dụng mô hình kiến trúc sạch **Clean Architecture** và kết nối trực tiếp với **MongoDB Atlas**.

---

## 🚀 Các Tính Năng Chính (Realtime)

1. **Quản lý Đơn vị (Units):**
   * Hiển thị danh sách các đơn vị tính (Chai, Lon, Ly, Đĩa, Phần...).
   * Hỗ trợ thêm mới, sửa tên đơn vị, xóa từng đơn vị và xóa sạch toàn bộ.
   * Thanh tìm kiếm nhanh đơn vị theo tên thời gian thực.

2. **Quản lý Đồ uống / Thực đơn (Drinks & Menu):**
   * Quản lý danh sách thực đơn đa dạng: Đồ uống 🍹, Đồ ăn 🍔, Snack 🍟.
   * Hiển thị chi tiết: Tên món, đơn giá bán, đơn vị tính và số lượng tồn kho thực tế hiện tại.
   * Hỗ trợ thêm mới (lựa chọn phân loại và đơn vị tính), sửa thông tin, xóa từng món hoặc xóa toàn bộ thực đơn.
   * Tìm kiếm món ăn/đồ uống thời gian thực.

3. **Giao dịch Nhập hàng (Stock In):**
   * Ghi nhận phiếu nhập kho: Số lượng nhập, đơn giá nhập, chọn đồ uống từ danh sách và nhập ghi chú.
   * **Tự động cộng dồn** số lượng nhập vào tồn kho của sản phẩm tương ứng trong cơ sở dữ liệu.
   * **Thống kê gom nhóm theo ngày:** Lịch sử nhập hàng được gom nhóm theo ngày cực kỳ trực quan, hiển thị Tổng số lượng nhập và Tổng chi phí của ngày đó.
   * Hỗ trợ xóa phiếu nhập và tự động trừ trả lại số lượng tồn kho tương ứng.

4. **Giao dịch Tiêu thụ (Consumption):**
   * Ghi nhận xuất kho tiêu thụ sản phẩm ngoài luồng đặt món tại bàn.
   * **Ràng buộc tồn kho thông minh:** Ngăn chặn xuất âm kho, hiển thị thông báo lỗi nếu số lượng tiêu thụ lớn hơn tồn kho thực tế.
   * **Tự động trừ kho** khi ghi nhận tiêu thụ và **tự động hoàn trả kho** khi xóa giao dịch tiêu thụ.
   * Thống kê lịch sử tiêu thụ gom nhóm chi tiết theo ngày (Tổng số lượng & Tổng trị giá xuất bán).

5. **Báo cáo Tồn kho & Truy vết Lịch sử (Stock Management):**
   * Danh sách tồn kho thời gian thực của tất cả sản phẩm. Cảnh báo badge màu đỏ nổi bật đối với các mặt hàng đã hết hàng (Tồn = 0).
   * **Xem chi tiết lịch sử Nhập - Xuất:** Chạm vào bất kỳ sản phẩm nào để mở BottomSheet hiển thị toàn bộ lịch sử các giao dịch nhập kho (`+` số lượng, icon ⬇️) và tiêu thụ (`-` số lượng, icon ⬆️) chi tiết của món đó.

6. **Đồ uống đã hết hàng (Out of Stock):**
   * Tích hợp Tab View tiện lợi trong màn hình Kho giúp lọc nhanh toàn bộ danh sách các đồ uống đã bán hết hàng (tồn kho = 0) thời gian thực.

7. **Sơ đồ Bàn & Đặt món (Table Grid & Order):**
   * Quản lý trạng thái bàn (Trống/Có khách/Đang đặt món).
   * Giao diện gọi món nhanh và thanh toán hóa đơn.

8. **Báo cáo Doanh thu (Financial Stats):**
   * Thống kê chi tiết doanh thu thực tế theo khoảng thời gian.

---

## 🛠️ Công Nghệ Sử Dụng

* **Framework:** Flutter (Target Windows Desktop & Mobile Native).
* **State Management:** Riverpod (Riverpod Generator & Annotation).
* **Routing:** GoRouter.
* **Database:** MongoDB Atlas (sử dụng thư viện `mongo_dart`).
* **Architecture:** Clean Architecture (Domain, Data, Presentation) kết hợp bảo mật kết nối qua `.env`.

---

## 💻 Hướng Dẫn Cài Đặt & Chạy Dự Án

### 1. Chuẩn bị môi trường
* Máy tính đã cài đặt **Flutter SDK** mới nhất.
* Cài đặt **C++ build tools** (Visual Studio) nếu chạy target Windows Desktop.

### 2. Thiết lập cấu hình bảo mật
* Nhân bản file `.env.example` thành `.env` (hoặc tạo mới file `.env` ở thư mục gốc của dự án).
* Cấu hình chuỗi kết nối MongoDB Atlas của bạn:
  ```env
  MONGODB_URI=mongodb+srv://<username>:<password>@<host>/bar_manager?retryWrites=true&w=majority&tls=true&safeAtlas=true
  ```

### 3. Cài đặt các gói phụ thuộc
Mở terminal tại thư mục dự án và chạy:
```bash
flutter pub get
```

### 4. Biên dịch tự động sinh code (Riverpod Providers)
Chạy lệnh `build_runner` để sinh các file Riverpod:
```bash
dart run build_runner build --delete-conflicting-outputs
```

### 5. Chạy ứng dụng trên môi trường Native (Windows)
```bash
flutter run -d windows
```

---

## 📂 Cấu Trúc Thư Mục Dự Án
```text
lib/
├── core/                  # Các tài nguyên dùng chung cho toàn app
│   ├── database/          # Cấu hình kết nối MongoDB & Quản lý stream realtime
│   ├── providers/         # Đăng ký Dependency Injection (Usecases, Repositories)
│   ├── router/            # Cấu hình định tuyến GoRouter
│   └── theme/             # Định nghĩa mã màu & kiểu chữ Dark Mode cao cấp
└── features/              # Các module chức năng theo kiến trúc Clean Architecture
    ├── menu/              # Module quản lý Menu & Đồ uống
    ├── order/             # Module đặt món tại bàn
    ├── report/            # Module thống kê doanh thu
    ├── stock/             # Module Nhập hàng, Tiêu thụ, Tồn kho & Lịch sử chi tiết
    ├── table/             # Module sơ đồ bàn
    └── unit/              # Module quản lý đơn vị tính
```
