# Bar Manager App 🍹📊

Ứng dụng quản lý vận hành Quán Bar / Nhà Hàng thời gian thực (Realtime) được phát triển trên nền tảng **Flutter** (hỗ trợ Web, Windows, Android, iOS...) kết hợp cùng **Node.js Express Backend API** và cơ sở dữ liệu **MongoDB Atlas**. 

Ứng dụng áp dụng mô hình kiến trúc sạch **Clean Architecture** phân tách rõ ràng các tầng lớp giúp dễ dàng mở rộng và bảo trì.

---

## 🚀 Các Tính Năng Chính (Realtime)

1. **Sơ đồ Bàn VIP & Bàn Thường (Table Grid):**
   * Phân chia sơ đồ bàn ăn thông minh thành 2 tab: **BÀN VIP** (tên chứa chữ "VIP") và **BÀN THƯỜNG** giúp quản lý tối ưu.
   * Hỗ trợ đổi tên bàn ăn trực tiếp hoặc xóa bàn trống nhanh chóng bằng menu 3 chấm trực quan.
   * Ràng buộc kiểm tra trùng tên bàn từ cả Client lẫn Backend để bảo toàn tính duy nhất của bàn ăn.

2. **Quản lý Đơn vị tính (Units):**
   * Quản lý danh sách đơn vị tính động (Chai, Lon, Ly, Đĩa, Phần...).
   * Hỗ trợ thêm mới, sửa tên, xóa đơn vị tính trực quan và đồng bộ tức thời vào cơ sở dữ liệu.

3. **Phân tách Quản lý Thực đơn & Nguyên liệu:**
   * **Quản lý Thực đơn (Menu):** Quản lý đồ uống 🍹, đồ ăn 🍔, snack 🍟 thành phẩm tự chế biến. Không duy trì tồn kho để tối ưu vận hành.
   * **Quản lý Nguyên liệu (Ingredients):** Quản lý các loại nguyên liệu thô đầu vào nhập kho. Chỉ cho phép chỉnh sửa tên và xóa nguyên liệu (với hộp thoại cảnh báo trước khi xóa để tránh mất dữ liệu lịch sử).
   * **Đồng bộ đơn vị tính động:** Khi thêm mới món ăn hoặc nguyên liệu thô, đơn vị tính được tải động từ DB thay vì hardcode.

4. **Giao dịch Nhập hàng (Stock In):**
   * Thêm phiếu nhập kho: Số lượng nhập, giá nhập, chọn nguyên liệu thô (có thể tạo nhanh nguyên liệu thô và đơn vị tính mới ngay tại form).
   * Tự động cộng dồn số lượng nhập vào tồn kho thực tế của nguyên liệu.
   * Lịch sử nhập hàng được gom nhóm theo từng ngày cụ thể kèm chi tiết số lượng và tổng chi phí.

5. **Giao dịch Tiêu thụ (Consumption):**
   * Xuất kho tiêu thụ nguyên liệu ngoài luồng gọi món tại bàn.
   * Ngăn chặn xuất âm kho, tự động kiểm tra đối chiếu số lượng tồn kho khả dụng hiện tại.
   * Lịch sử tiêu thụ gom nhóm chi tiết theo ngày.

6. **Đặt món tại bàn & Thanh toán hóa đơn (Ordering):**
   * Giao diện gọi món trực quan, lọc thông minh chỉ hiển thị Đồ ăn, Đồ uống, Snack thành phẩm (loại trừ nguyên liệu thô).
   * Cho phép thêm/sửa ghi chú, điều chỉnh tăng giảm số lượng món đã gọi trong hóa đơn.
   * Tự động tính tiền và in hóa đơn thanh toán sắc nét.
   * **Hủy bàn linh hoạt:** Hỗ trợ nút **Hủy Bàn** trực tiếp kể cả khi hóa đơn chưa gọi món nào để trả bàn về trạng thái trống (vacant) nhanh chóng.

7. **Báo cáo Kho & Thống kê Tài chính:**
   * Lọc nhanh danh sách nguyên liệu hết hàng (tồn kho = 0).
   * Thống kê tài chính chi tiết (Doanh thu, Chi phí, Lợi nhuận) theo khoảng thời gian tùy ý.
   * Thống kê các món bán chạy nhất (Best Sellers) đem lại doanh thu cao nhất.

---

## 🛠️ Công Nghệ Sử Dụng

* **Frontend:** Flutter Web, Windows Desktop, Android & iOS.
* **State Management:** Riverpod (Riverpod Generator & Annotation).
* **Routing:** GoRouter.
* **Backend:** Node.js Express Server kết nối MongoDB Atlas qua Mongoose / MongoDB Native Driver.
* **Network client:** Dio HTTP Client tích hợp reactive stream qua `StreamController`.
* **Architecture:** Clean Architecture (Domain, Data, Presentation).

---

## 💻 Hướng Dẫn Cài Đặt & Chạy Dự Án

### 1. Cài đặt và Chạy Backend (Node.js Express)
* Di chuyển vào thư mục server:
  ```bash
  cd server
  ```
* Thiết lập cấu hình bảo mật bằng cách tạo file `server/.env` với nội dung:
  ```env
  PORT=3000
  MONGODB_URI=mongodb+srv://<username>:<password>@<host>/bar_manager?retryWrites=true&w=majority&tls=true
  ```
* Cài đặt các gói thư viện backend:
  ```bash
  npm install
  ```
* Khởi chạy Backend Server:
  ```bash
  npm start
  ```
  *Server sẽ lắng nghe tại cổng `http://localhost:3000`.*

### 2. Thiết lập cấu hình Flutter Client
* Tạo file `.env` tại thư mục gốc của dự án Flutter:
  ```env
  API_URL=http://localhost:3000
  ```

### 3. Khởi chạy Flutter Client
* Cài đặt dependencies:
  ```bash
  flutter pub get
  ```
* Biên dịch tự động sinh code (Riverpod Providers):
  ```bash
  dart run build_runner build --delete-conflicting-outputs
  ```
* Khởi chạy ứng dụng:
  * Chạy trên trình duyệt Web (Chrome):
    ```bash
    flutter run -d chrome
    ```
  * Chạy trên Windows Desktop:
    ```bash
    flutter run -d windows
    ```

---

## 📂 Cấu Trúc Thư Mục Dự Án
```text
bar_manager/
├── lib/                      # Mã nguồn ứng dụng Flutter Client
│   ├── core/                 # Cấu hình dùng chung hệ thống
│   │   ├── database/         # Client Dio kết nối REST API & reactive streams
│   │   ├── providers/        # Dependency Injection (Usecases, Repositories)
│   │   ├── router/           # Định tuyến GoRouter
│   │   └── theme/            # Giao diện Dark Mode sang trọng
│   └── features/             # Các Module nghiệp vụ (Clean Architecture)
│       ├── menu/             # Quản lý món ăn, đồ uống, nguyên liệu
│       ├── order/            # Đơn hàng & Đặt món tại bàn
│       ├── report/           # Báo cáo doanh thu & tài chính
│       ├── stock/            # Nhập kho, xuất kho, báo cáo tồn kho
│       ├── table/            # Quản lý bàn VIP / bàn thường
│       └── unit/             # Quản lý đơn vị tính
├── server/                   # Mã nguồn Express Backend Server
│   ├── server.js             # Khởi tạo Express API Endpoints & kết nối DB
│   ├── package.json          # Quản lý dependencies node
│   └── .env                  # Cấu hình cổng kết nối & MongoDB URI của Server
```
