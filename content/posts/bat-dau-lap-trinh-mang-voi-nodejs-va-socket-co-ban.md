---
title: "Bắt đầu Lập trình Mạng với Node.js và Socket Cơ bản"
date: 2025-10-10T00:00:00+07:00
draft: false
categories: ["JavaScript", "Mạng & Web"]
type: "post"
---

**Mở đầu:** Socket là cửa ngõ cơ bản nhất để hiểu về giao tiếp mạng. Bài viết này sẽ hướng dẫn bạn thiết lập một kết nối mạng hai chiều đơn giản bằng cách sử dụng module `net` sẵn có trong Node.js, đặt nền móng cho việc xây dựng các ứng dụng thời gian thực.

## Nội dung chính:

- **Socket là gì?** Khái niệm TCP Socket và vai trò của nó trong mô hình Client-Server.
- **Thiết lập Server Node.js:** Cách tạo một TCP Server lắng nghe trên một Port cụ thể (ví dụ: Port 3000).
- **Thiết lập Client:** Cách tạo một Client kết nối đến Server và gửi/nhận dữ liệu.
- **Minh họa Code:** Ví dụ code chi tiết về cách Server xử lý sự kiện `connection`, `data`, và `end`.

## Kết luận
Nắm vững TCP Socket cơ bản với Node.js là bước đầu tiên để tiến tới WebSocket và các giao thức phức tạp hơn.
