---
title: "Tìm hiểu về JSON và cơ chế gửi/nhận dữ liệu trong AJAX"
date: 2025-10-11T00:00:00+07:00
draft: false
categories: ["JavaScript", "Mạng & Web"]
type: "post"
---

**Mở đầu:** Trong các ứng dụng Web hiện đại, JSON (JavaScript Object Notation) là định dạng trao đổi dữ liệu phổ biến nhất. Bài viết này tập trung vào vai trò của JSON trong việc truyền tải dữ liệu qua mạng bằng kỹ thuật AJAX.

## Nội dung chính:

### JSON là gì và tại sao lại quan trọng?
Ưu điểm của JSON so với XML (nhẹ, dễ đọc, tích hợp sẵn trong JavaScript).

### AJAX hoạt động như thế nào?
Giải thích quy trình gửi HTTP Request bất đồng bộ bằng XMLHttpRequest hoặc Fetch API trong JavaScript.

### Quy trình Serialization/Deserialization
Hướng dẫn cách chuyển đổi giữa Object JavaScript và chuỗi JSON (JSON.stringify và JSON.parse) trước khi gửi qua mạng.

### Ví dụ thực tế

#### 1. Gửi dữ liệu JSON bằng Fetch API

```javascript
// Dữ liệu người dùng
const userData = {
    name: "Lê Trần Minh Long",
    email: "long@example.com",
    age: 22
};

// Gửi dữ liệu lên server
fetch('https://api.example.com/users', {
    method: 'POST',
    headers: {
        'Content-Type': 'application/json',
    },
    body: JSON.stringify(userData) // Chuyển đổi object thành JSON string
})
.then(response => response.json()) // Phân tích phản hồi JSON
.then(data => {
    console.log('Thành công:', data);
})
.catch((error) => {
    console.error('Lỗi:', error);
});
```

#### 2. Nhận dữ liệu JSON từ API

```javascript
// Lấy danh sách bài viết
fetch('https://jsonplaceholder.typicode.com/posts')
.then(response => {
    if (!response.ok) {
        throw new Error('Phản hồi mạng không thành công');
    }
    return response.json();
})
.then(posts => {
    // Xử lý dữ liệu JSON nhận được
    posts.forEach(post => {
        console.log(`Tiêu đề: ${post.title}`);
        console.log(`Nội dung: ${post.body}`);
    });
})
.catch(error => {
    console.error('Lỗi Fetch:', error);
});
```

#### 3. Sử dụng XMLHttpRequest (cách truyền thống)

```javascript
function sendDataWithXHR() {
    const xhr = new XMLHttpRequest();
    const data = {
        message: "Xin chào từ AJAX!",
        timestamp: new Date().toISOString()
    };

    xhr.open('POST', 'https://api.example.com/messages', true);
    xhr.setRequestHeader('Content-Type', 'application/json');
    
    xhr.onreadystatechange = function() {
        if (xhr.readyState === 4 && xhr.status === 200) {
            const response = JSON.parse(xhr.responseText);
            console.log('Phản hồi:', response);
        }
    };
    
    xhr.send(JSON.stringify(data));
}
```

#### 4. Xử lý lỗi và validation

```javascript
async function handleUserData() {
    try {
        const userData = {
            username: "minhlong",
            password: "securePassword123"
        };

        // Kiểm tra dữ liệu trước khi gửi
        if (!userData.username || !userData.password) {
            throw new Error('Tên người dùng và mật khẩu không được để trống');
        }

        const response = await fetch('/api/login', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(userData)
        });

        if (!response.ok) {
            const errorData = await response.json();
            throw new Error(errorData.message || 'Đăng nhập thất bại');
        }

        const result = await response.json();
        console.log('Đăng nhập thành công:', result);
        
    } catch (error) {
        console.error('Lỗi:', error.message);
    }
}
```

## Kết luận
JSON và AJAX là bộ đôi không thể thiếu trong phát triển front-end và giao tiếp API, giúp tối ưu hóa băng thông và trải nghiệm người dùng.
