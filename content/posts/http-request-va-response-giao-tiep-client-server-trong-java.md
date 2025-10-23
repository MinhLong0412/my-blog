---
title: "HTTP Request và Response: Giao tiếp Client-Server trong Java"
date: 2025-10-13T00:00:00+07:00
draft: false
categories: ["Java", "Backend/Mạng"]
type: "post"
---

**Mở đầu:** Java là lựa chọn hàng đầu cho các hệ thống doanh nghiệp. Để Java giao tiếp với thế giới web, chúng ta cần hiểu rõ cách nó xử lý các giao dịch HTTP. Bài viết này sẽ tập trung vào cấu trúc của HTTP Request và Response trong bối cảnh Java.

## Nội dung chính:

### Cấu trúc HTTP cơ bản

HTTP (HyperText Transfer Protocol) là giao thức giao tiếp giữa client và server. Mỗi giao dịch HTTP bao gồm:

#### HTTP Request
- **Method**: GET, POST, PUT, DELETE, etc.
- **URL**: Đường dẫn tới tài nguyên
- **Headers**: Metadata về request
- **Body**: Dữ liệu gửi kèm (chủ yếu với POST/PUT)

#### HTTP Response
- **Status Code**: 200 (OK), 404 (Not Found), 500 (Internal Server Error), etc.
- **Headers**: Metadata về response
- **Body**: Dữ liệu phản hồi

### Java Utility for HTTP

#### 1. Sử dụng HttpURLConnection (Java 1.1+)

```java
import java.io.*;
import java.net.*;

public class HttpClientExample {
    
    // Yêu cầu GET
    public static String sendGetRequest(String urlString) throws IOException {
        URL url = new URL(urlString);
        HttpURLConnection connection = (HttpURLConnection) url.openConnection();
        
        // Thiết lập phương thức và tiêu đề
        connection.setRequestMethod("GET");
        connection.setRequestProperty("User-Agent", "Java HTTP Client");
        connection.setRequestProperty("Accept", "application/json");
        
        // Đọc phản hồi
        int responseCode = connection.getResponseCode();
        System.out.println("Mã phản hồi: " + responseCode);
        
        BufferedReader reader = new BufferedReader(
            new InputStreamReader(connection.getInputStream())
        );
        
        StringBuilder response = new StringBuilder();
        String line;
        while ((line = reader.readLine()) != null) {
            response.append(line);
        }
        reader.close();
        
        return response.toString();
    }
    
    // Yêu cầu POST với dữ liệu JSON
    public static String sendPostRequest(String urlString, String jsonData) throws IOException {
        URL url = new URL(urlString);
        HttpURLConnection connection = (HttpURLConnection) url.openConnection();
        
        // Thiết lập cho yêu cầu POST
        connection.setRequestMethod("POST");
        connection.setRequestProperty("Content-Type", "application/json");
        connection.setRequestProperty("Accept", "application/json");
        connection.setDoOutput(true);
        
        // Ghi dữ liệu vào thân yêu cầu
        try (OutputStream os = connection.getOutputStream()) {
            byte[] input = jsonData.getBytes("utf-8");
            os.write(input, 0, input.length);
        }
        
        // Đọc phản hồi
        int responseCode = connection.getResponseCode();
        
        BufferedReader reader = new BufferedReader(
            new InputStreamReader(
                responseCode >= 200 && responseCode < 300 
                    ? connection.getInputStream() 
                    : connection.getErrorStream()
            )
        );
        
        StringBuilder response = new StringBuilder();
        String line;
        while ((line = reader.readLine()) != null) {
            response.append(line);
        }
        reader.close();
        
        return response.toString();
    }
}
```

#### 2. Sử dụng HttpClient (Java 11+)

```java
import java.net.http.*;
import java.net.URI;
import java.time.Duration;

public class ModernHttpClient {
    
    private static final HttpClient client = HttpClient.newBuilder()
        .connectTimeout(Duration.ofSeconds(10))
        .build();
    
    // GET Request
    public static String sendGetRequest(String url) throws Exception {
        HttpRequest request = HttpRequest.newBuilder()
            .uri(URI.create(url))
            .header("Accept", "application/json")
            .GET()
            .build();
        
        HttpResponse<String> response = client.send(request, 
            HttpResponse.BodyHandlers.ofString());
        
        System.out.println("Status Code: " + response.statusCode());
        System.out.println("Headers: " + response.headers().map());
        
        return response.body();
    }
    
    // POST Request
    public static String sendPostRequest(String url, String jsonData) throws Exception {
        HttpRequest request = HttpRequest.newBuilder()
            .uri(URI.create(url))
            .header("Content-Type", "application/json")
            .header("Accept", "application/json")
            .POST(HttpRequest.BodyPublishers.ofString(jsonData))
            .build();
        
        HttpResponse<String> response = client.send(request, 
            HttpResponse.BodyHandlers.ofString());
        
        return response.body();
    }
    
    // Async Request
    public static void sendAsyncRequest(String url) {
        HttpRequest request = HttpRequest.newBuilder()
            .uri(URI.create(url))
            .build();
        
        client.sendAsync(request, HttpResponse.BodyHandlers.ofString())
            .thenApply(HttpResponse::body)
            .thenAccept(System.out::println)
            .join();
    }
}
```

### Xử lý Server-Side

#### 1. Sử dụng Servlet

```java
import javax.servlet.*;
import javax.servlet.http.*;
import java.io.*;

public class UserServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Đọc parameters từ URL
        String userId = request.getParameter("id");
        String format = request.getParameter("format");
        
        // Đọc headers
        String userAgent = request.getHeader("User-Agent");
        String acceptHeader = request.getHeader("Accept");
        
        System.out.println("User ID: " + userId);
        System.out.println("Format: " + format);
        System.out.println("User Agent: " + userAgent);
        
        // Tạo response
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.setStatus(HttpServletResponse.SC_OK);
        
        // Ghi dữ liệu vào response body
        PrintWriter out = response.getWriter();
        out.println("{");
        out.println("  \"id\": \"" + userId + "\",");
        out.println("  \"name\": \"Lê Trần Minh Long\",");
        out.println("  \"email\": \"long@example.com\"");
        out.println("}");
        out.close();
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Đọc request body
        StringBuilder jsonBuilder = new StringBuilder();
        BufferedReader reader = request.getReader();
        String line;
        while ((line = reader.readLine()) != null) {
            jsonBuilder.append(line);
        }
        String requestBody = jsonBuilder.toString();
        
        System.out.println("Nội dung yêu cầu: " + requestBody);
        
        // Xử lý dữ liệu và tạo response
        response.setContentType("application/json");
        response.setStatus(HttpServletResponse.SC_CREATED);
        
        PrintWriter out = response.getWriter();
        out.println("{\"message\": \"User created successfully\"}");
        out.close();
    }
}
```

#### 2. Sử dụng Spring Boot Controller

```java
import org.springframework.web.bind.annotation.*;
import org.springframework.http.*;
import javax.servlet.http.HttpServletRequest;

@RestController
@RequestMapping("/api/users")
public class UserController {
    
    @GetMapping("/{id}")
    public ResponseEntity<User> getUser(
            @PathVariable String id,
            @RequestParam(required = false) String format,
            @RequestHeader("User-Agent") String userAgent,
            HttpServletRequest request) {
        
        System.out.println("User ID: " + id);
        System.out.println("Format: " + format);
        System.out.println("User Agent: " + userAgent);
        System.out.println("Request URL: " + request.getRequestURL());
        
        User user = new User(id, "Lê Trần Minh Long", "long@example.com");
        
        return ResponseEntity.ok()
            .header("Custom-Header", "Custom-Value")
            .body(user);
    }
    
    @PostMapping
    public ResponseEntity<String> createUser(
            @RequestBody User user,
            @RequestHeader HttpHeaders headers) {
        
        System.out.println("Received user: " + user);
        System.out.println("Loại nội dung: " + headers.getContentType());
        
        return ResponseEntity.status(HttpStatus.CREATED)
            .body("{\"message\": \"User created successfully\"}");
    }
    
    // Custom error handling
    @GetMapping("/error")
    public ResponseEntity<String> errorExample() {
        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
            .header("Error-Type", "Validation")
            .body("{\"error\": \"Invalid request parameters\"}");
    }
}

class User {
    private String id;
    private String name;
    private String email;
    
    // Constructors, getters, setters
    public User(String id, String name, String email) {
        this.id = id;
        this.name = name;
        this.email = email;
    }
    
    // getters và setters...
}
```

### Tạo Response

#### Custom Response với Headers và Status Codes

```java
public class ResponseHelper {
    
    public static void sendJsonResponse(HttpServletResponse response, 
                                      int statusCode, 
                                      String jsonContent) throws IOException {
        // Thiết lập status code
        response.setStatus(statusCode);
        
        // Thiết lập headers
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.setHeader("Cache-Control", "no-cache");
        response.setHeader("Access-Control-Allow-Origin", "*");
        
        // Ghi content
        PrintWriter out = response.getWriter();
        out.print(jsonContent);
        out.flush();
    }
    
    public static void sendErrorResponse(HttpServletResponse response, 
                                       int statusCode, 
                                       String errorMessage) throws IOException {
        String errorJson = String.format(
            "{\"error\": \"%s\", \"status\": %d}", 
            errorMessage, statusCode
        );
        
        sendJsonResponse(response, statusCode, errorJson);
    }
}
```

### Ví dụ hoàn chỉnh

```java
public class HttpExample {
    
    public static void main(String[] args) {
        try {
            // Kiểm tra yêu cầu GET
            String getResponse = HttpClientExample.sendGetRequest(
                "https://jsonplaceholder.typicode.com/users/1"
            );
            System.out.println("Phản hồi GET: " + getResponse);
            
            // Kiểm tra yêu cầu POST
            String jsonData = "{\"name\": \"Minh Long\", \"email\": \"long@example.com\"}";
            String postResponse = HttpClientExample.sendPostRequest(
                "https://jsonplaceholder.typicode.com/users", 
                jsonData
            );
            System.out.println("Phản hồi POST: " + postResponse);
            
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
```

## Kết luận
Việc nắm vững cơ chế Request/Response bằng các API gốc của Java giúp lập trình viên hiểu rõ hơn về các framework cao cấp như Spring hoạt động như thế nào. Kiến thức này là nền tảng quan trọng để phát triển các ứng dụng web và microservices với Java.
