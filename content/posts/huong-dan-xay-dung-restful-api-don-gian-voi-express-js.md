---
title: "Hướng dẫn xây dựng RESTful API đơn giản với Express.js"
date: 2025-10-12T00:00:00+07:00
draft: false
categories: ["JavaScript", "Mạng & Web"]
type: "post"
---

**Mở đầu:** Khi phát triển ứng dụng web quy mô lớn, việc xây dựng API theo kiến trúc REST (Representational State Transfer) là điều bắt buộc. Bài viết này sẽ hướng dẫn bạn từng bước xây dựng một RESTful API cơ bản sử dụng framework Express.js của Node.js.

## Nội dung chính:

### Nguyên tắc cốt lõi của REST
Giải thích về các động từ HTTP (GET, POST, PUT, DELETE) và cách chúng ánh xạ tới các thao tác CRUD (Create, Read, Update, Delete).

- **GET**: Đọc dữ liệu (Read)
- **POST**: Tạo mới dữ liệu (Create)
- **PUT**: Cập nhật dữ liệu (Update)
- **DELETE**: Xóa dữ liệu (Delete)

### Thiết lập Express.js

#### 1. Khởi tạo dự án Node.js

```bash
mkdir my-api
cd my-api
npm init -y
npm install express
```

#### 2. Tạo file server.js cơ bản

```javascript
const express = require('express');
const app = express();
const PORT = 3000;

// Middleware để phân tích JSON
app.use(express.json());

// Tuyến đường cơ bản
app.get('/', (req, res) => {
    res.json({ message: 'Chào mừng đến với RESTful API sử dụng Express.js!' });
});

// Khởi động máy chủ
app.listen(PORT, () => {
    console.log(`Máy chủ đang chạy tại http://localhost:${PORT}`);
});
```

### Định tuyến (Routing)

#### Tạo các Route cơ bản cho quản lý Users

```javascript
// Dữ liệu mẫu (trong thực tế sẽ dùng database)
let users = [
    { id: 1, name: 'Lê Trần Minh Long', email: 'long@example.com' },
    { id: 2, name: 'Nguyễn Văn A', email: 'a@example.com' }
];

// GET /api/users - Lấy danh sách tất cả users
app.get('/api/users', (req, res) => {
    res.json({
        success: true,
        data: users,
        count: users.length
    });
});

// GET /api/users/:id - Lấy thông tin user theo ID
app.get('/api/users/:id', (req, res) => {
    const id = parseInt(req.params.id);
    const user = users.find(u => u.id === id);
    
    if (!user) {
        return res.status(404).json({
            success: false,
            message: 'Người dùng không tồn tại'
        });
    }
    
    res.json({
        success: true,
        data: user
    });
});

// POST /api/users - Tạo người dùng mới
app.post('/api/users', (req, res) => {
    const { name, email } = req.body;
    
    // Kiểm tra đơn giản
    if (!name || !email) {
        return res.status(400).json({
            success: false,
            message: 'Tên và email là bắt buộc'
        });
    }
    
    // Tạo người dùng mới
    const newUser = {
        id: users.length + 1,
        name,
        email
    };
    
    users.push(newUser);
    
    res.status(201).json({
        success: true,
        message: 'Người dùng đã được tạo thành công',
        data: newUser
    });
});

// PUT /api/users/:id - Cập nhật người dùng
app.put('/api/users/:id', (req, res) => {
    const id = parseInt(req.params.id);
    const userIndex = users.findIndex(u => u.id === id);
    
    if (userIndex === -1) {
        return res.status(404).json({
            success: false,
            message: 'Người dùng không tồn tại'
        });
    }
    
    const { name, email } = req.body;
    
    // Cập nhật thông tin
    if (name) users[userIndex].name = name;
    if (email) users[userIndex].email = email;
    
    res.json({
        success: true,
        message: 'Người dùng đã được cập nhật',
        data: users[userIndex]
    });
});

// DELETE /api/users/:id - Xóa người dùng
app.delete('/api/users/:id', (req, res) => {
    const id = parseInt(req.params.id);
    const userIndex = users.findIndex(u => u.id === id);
    
    if (userIndex === -1) {
        return res.status(404).json({
            success: false,
            message: 'Người dùng không tồn tại'
        });
    }
    
    const deletedUser = users.splice(userIndex, 1)[0];
    
    res.json({
        success: true,
        message: 'Người dùng đã được xóa',
        data: deletedUser
    });
});
```

### Xử lý Request Body và Middleware

#### 1. Middleware logging

```javascript
// Middleware để log các request
app.use((req, res, next) => {
    console.log(`${new Date().toISOString()} - ${req.method} ${req.url}`);
    next();
});
```

#### 2. Middleware xử lý lỗi

```javascript
// Middleware xử lý lỗi global
app.use((err, req, res, next) => {
    console.error(err.stack);
    res.status(500).json({
        success: false,
        message: 'Có lỗi xảy ra trên server'
    });
});
```

#### 3. Middleware CORS (nếu cần)

```javascript
app.use((req, res, next) => {
    res.header('Access-Control-Allow-Origin', '*');
    res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE');
    res.header('Access-Control-Allow-Headers', 'Content-Type');
    next();
});
```

### Code hoàn chỉnh

```javascript
const express = require('express');
const app = express();
const PORT = 3000;

// Middleware
app.use(express.json());
app.use((req, res, next) => {
    console.log(`${new Date().toISOString()} - ${req.method} ${req.url}`);
    next();
});

// Dữ liệu mẫu
let users = [
    { id: 1, name: 'Lê Trần Minh Long', email: 'long@example.com' },
    { id: 2, name: 'Nguyễn Văn A', email: 'a@example.com' }
];

// Routes
app.get('/api/users', (req, res) => {
    res.json({ success: true, data: users, count: users.length });
});

app.get('/api/users/:id', (req, res) => {
    const user = users.find(u => u.id === parseInt(req.params.id));
    if (!user) return res.status(404).json({ success: false, message: 'User không tồn tại' });
    res.json({ success: true, data: user });
});

app.post('/api/users', (req, res) => {
    const { name, email } = req.body;
    if (!name || !email) {
        return res.status(400).json({ success: false, message: 'Name và email là bắt buộc' });
    }
    const newUser = { id: users.length + 1, name, email };
    users.push(newUser);
    res.status(201).json({ success: true, data: newUser });
});

// Khởi động server
app.listen(PORT, () => {
    console.log(`Server đang chạy tại http://localhost:${PORT}`);
});
```

### Cách test API

```bash
# Lấy danh sách người dùng
curl http://localhost:3000/api/users

# Tạo người dùng mới
curl -X POST http://localhost:3000/api/users \
  -H "Content-Type: application/json" \
  -d '{"name":"Người dùng thử nghiệm","email":"test@example.com"}'

# Lấy người dùng theo ID
curl http://localhost:3000/api/users/1
```

## Kết luận
Express.js cung cấp một cách tiếp cận nhanh chóng và linh hoạt để triển khai các API tuân thủ kiến trúc REST, là kỹ năng quan trọng đối với lập trình viên backend JavaScript.
