# Daily55

Project mặt đồng hồ hằng ngày cho **Garmin Forerunner 55** (`fr55`), viết bằng Monkey C / Connect IQ.

Giao diện ban đầu: nền đen, giờ lớn màu trắng, ngày màu xanh, phần trăm pin, số bước và thanh tiến độ mục tiêu bước chân. Giờ tự theo cài đặt 12/24 giờ trên đồng hồ. Khi dữ liệu bước chân không có, hiển thị `--`; khi không có mục tiêu hợp lệ, ẩn thanh tiến độ. Ngày dùng dạng `THU 05/11`, nhãn dùng tiếng Anh để giữ giao diện gọn.

## Thiết lập trên macOS

1. Cài Java JDK 17, chẳng hạn từ [Eclipse Temurin](https://adoptium.net/temurin/releases/?version=17), rồi kiểm tra `java -version`.
2. Cài [Garmin Connect IQ SDK Manager](https://developer.garmin.com/connect-iq/sdk/). Đăng nhập tài khoản Garmin, tải SDK và chọn làm SDK hiện hành. Trong tab **Devices**, tải **Forerunner 55**.
3. Mở thư mục project trong VS Code và cài extension **Monkey C** của **Garmin** (`garmin.monkey-c`), được đề xuất trong project.
4. Mở Command Palette (`Cmd+Shift+P`), chạy **Monkey C: Verify Installation**.
5. Chạy **Monkey C: Generate a Developer Key**. Lưu key vào thư mục `keys/` trong project hoặc vị trí riêng ngoài project, và cấu hình **Monkey C: Developer Key Path** nếu cần. `keys/`, `*.der` và `*.pem` đã được bỏ qua trong `.gitignore`. Giữ bản sao key để ký các bản cập nhật sau này.

## Chạy simulator

1. Mở `source/Daily55View.mc` trong VS Code.
2. Nhấn `F5`, chọn cấu hình **Run Daily55 on Forerunner 55** nếu được hỏi, rồi chọn **Forerunner 55**.
3. Kiểm tra giờ 12/24 giờ, chữ số rộng (ví dụ `20:08`), pin, bước chân chưa có dữ liệu, bước vượt mục tiêu và chế độ ngủ.

Project chỉ khai báo `fr55` trong manifest. Không có timer hay animation riêng; giao diện dùng callback `onUpdate` của hệ thống. Trong chế độ tiết kiệm điện, hệ thống cập nhật mặt đồng hồ theo phút.

## Build và cài lên đồng hồ

1. Cắm đồng hồ vào máy tính bằng cáp dữ liệu.
2. Chạy **Monkey C: Build for Device**, chọn **Forerunner 55**, chọn thư mục đầu ra `bin/`.
3. Chép file `.prg` được tạo vào `GARMIN/APPS` trên đồng hồ khi ổ thiết bị có thể truy cập từ máy tính.
4. Ngắt kết nối an toàn. Trên màn hình đồng hồ, giữ **UP**, vào **Watch Face**, chọn **Daily55**, rồi áp dụng.

Trên macOS, cách truy cập bộ nhớ thiết bị phụ thuộc chế độ kết nối của đồng hồ. Nếu không thấy ổ trong Finder, kiểm tra kết nối USB và hướng dẫn Garmin trước khi chép file.

Nếu đã đưa thư mục `bin` của SDK vào `PATH`, có thể build bằng terminal từ thư mục gốc project (đổi đường dẫn key theo nơi bạn lưu):

```sh
mkdir -p bin
monkeyc -f monkey.jungle -d fr55 -y keys/developer_key.der -o bin/Daily55.prg -w
```

## Các file cần sửa

- `source/Daily55View.mc`: bố cục, màu sắc và dữ liệu hiển thị.
- `source/Daily55App.mc`: điểm vào ứng dụng.
- `manifest.xml`: app ID, loại `watchface`, thiết bị và API tối thiểu.
- `monkey.jungle`: đường dẫn mã nguồn và tài nguyên.
- `resources/strings/strings.xml`: tên mặt đồng hồ.
- `resources/drawables/`: icon ứng dụng.

## Trạng thái kiểm tra

Project được tạo khi máy chưa có Java runtime và chưa tìm thấy Connect IQ SDK. Chưa biên dịch, chạy simulator, xác nhận bố cục bằng ảnh chụp hoặc thử trên đồng hồ thật. Cần hoàn tất các bước thiết lập và kiểm tra simulator trước khi cài để sử dụng hằng ngày.

## Tài liệu Garmin

- [Bắt đầu với Connect IQ](https://developer.garmin.com/connect-iq/connect-iq-basics/getting-started/)
- [Tạo project, chạy simulator và sideload](https://developer.garmin.com/connect-iq/connect-iq-basics/your-first-app/)
- [Vòng đời và cập nhật WatchFace](https://developer.garmin.com/connect-iq/api-docs/Toybox/WatchUi/WatchFace.html)
- [Thông số thiết bị](https://developer.garmin.com/connect-iq/compatible-devices/)
