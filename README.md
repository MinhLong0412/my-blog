# Blog Lập Trình Mạng

> Bầu trời trên cao, cát dưới chân và bình yên bên trong

Blog cá nhân về lập trình mạng, được xây dựng bằng Hugo và theme Gokarna.

## Nội dung

Blog này bao gồm các chủ đề:

- **JavaScript & Node.js**: Lập trình mạng với JavaScript, Express.js, WebSocket
- **Java Backend**: Spring Boot, HTTP Client/Server, Socket Programming  
- **Phân tích công nghệ**: So sánh giữa các công nghệ backend

## Cấu trúc

```
├── content/
│   ├── posts/           # Các bài viết blog
│   └── _index.md        # Trang chủ
├── themes/gokarna/      # Theme Hugo
├── static/              # File tĩnh (images, css, js)
└── hugo.toml           # Cấu hình Hugo
```

## Development

### Yêu cầu

- Hugo Extended v0.148.0+
- Git

### Chạy local

```bash
# Clone repository với submodules
git clone --recursive https://github.com/MinhLong0412/my-blog.git
cd my-blog

# Nếu đã clone rồi, initialize submodules
git submodule update --init --recursive

# Chạy development server
./dev.sh
# hoặc
hugo server -D --config hugo.dev.toml
```

Blog sẽ được phục vụ tại `http://localhost:1313`

## Deployment

Blog được tự động deploy lên GitHub Pages khi có commit vào branch `main` thông qua GitHub Actions.

### Setup GitHub Pages

1. Vào Settings → Pages
2. Source: GitHub Actions
3. Workflow sẽ tự động chạy khi push code

## Theme

Sử dụng [Gokarna theme](https://github.com/526avijitgupta/gokarna) - một theme Hugo minimal và responsive.

## License

Content của blog thuộc về tác giả. Theme Gokarna có license riêng.
