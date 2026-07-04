# Quy tắc phát triển dự án Bar Manager

## Yêu cầu đặc biệt
- **Độ phức tạp**: Code phải ngắn gọn, cú pháp đơn giản, dễ hiểu và dễ mở rộng. Tránh viết code quá phức tạp hoặc lạm dụng cấu trúc khó đọc.
- **Kiểm thử**: Khi thực hiện xong bất cứ chỉnh sửa hoặc tính năng nào, bắt buộc phải chạy các bài kiểm thử hoặc phân tích mã nguồn (`flutter analyze`, test case) để xác minh tính ổn định của ứng dụng.
- **Quy trình duyệt**: Chờ User xem xét và duyệt kết quả trực tiếp trước khi thực hiện các lệnh push mã nguồn lên Git.
- **Khởi chạy hệ thống**: Backend Server (Node.js) tại thư mục `server/` phải luôn được chạy (ở cổng 3000) trước khi chạy hoặc test ứng dụng Flutter. Nếu chưa chạy, hãy tự động khởi chạy backend bằng `npm start` trước.


## Quy ước Code & Naming
- Áp dụng cấu trúc **Clean Architecture**: Phân tách rõ ràng các tầng `domain`, `data`, và `presentation` cho mỗi feature.
- File và thư mục: đặt tên theo dạng `snake_case`.
- Class name: đặt tên theo dạng `PascalCase`.
- Tên biến và hàm: đặt tên theo dạng `camelCase`.
- Riverpod: sử dụng Riverpod Generator cho các provider mới để tối ưu hiệu năng và quản lý code dễ dàng.

## Các tính năng chính của Bar Manager App (Realtime)
1. **Quản lý Đơn vị (Units)**: hiển thị danh sách, thêm, sửa, xóa, xóa tất cả, tìm kiếm đơn vị theo tên.
2. **Quản lý Đồ uống (Drinks)**: hiển thị danh sách, thêm, sửa, xóa, xóa tất cả, tìm kiếm đồ uống theo tên.
3. **Nhập hàng (Stock In)**: Chức năng nhập hàng & thống kê lịch sử nhập hàng theo từng ngày.
4. **Tiêu thụ (Consumption)**: Nhập đồ uống đã tiêu thụ & thống kê lịch sử tiêu thụ theo ngày.
5. **Báo cáo kho (Stock Management)**: hiển thị tất cả danh sách đồ uống với số lượng tồn kho hiện tại. Xem chi tiết lịch sử Nhập Hàng / Tiêu Thụ của một đồ uống cụ thể.
6. **Đồ uống hết hàng (Out of Stock)**: hiển thị danh sách các đồ uống đã bán hết hàng (tồn kho = 0).
7. **Thống kê Tài chính (Financial Stats) theo khoảng thời gian tùy ý**:
   - Thống kê DOANH THU trên từng đầu mục đồ uống.
   - Thống kê CHI PHÍ trên từng đầu mục đồ uống.
   - Thống kê LỢI NHUẬN trên từng đầu mục đồ uống.
8. **Đồ uống bán chạy nhất (Best Sellers)**: hiển thị danh sách các đồ uống bán chạy nhất, đem lại doanh thu lớn.
