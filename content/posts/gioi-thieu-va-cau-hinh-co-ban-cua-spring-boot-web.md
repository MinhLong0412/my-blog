---
title: "Giới thiệu và Cấu hình Cơ bản của Spring Boot Web"
date: 2025-10-15T00:00:00+07:00
draft: false
categories: ["Java", "Backend/Mạng"]
type: "post"
---

**Mở đầu:** Spring Boot là framework de facto (thực tế) trong phát triển ứng dụng backend Java, đặc biệt là các dịch vụ vi mô (Microservices). Bài viết này là lời giới thiệu về Spring Boot và hướng dẫn cấu hình một dự án Web cơ bản.

## Nội dung chính:

### Spring Boot là gì?

Spring Boot là một framework được xây dựng trên nền tảng Spring Framework, mang đến những lợi ích cốt lõi:

#### **Lợi ích chính:**
- **Auto-configuration**: Tự động cấu hình các thành phần dựa trên dependencies có trong classpath
- **Opinionated defaults**: Cung cấp các cấu hình mặc định hợp lý
- **Embedded server**: Tích hợp sẵn Tomcat, Jetty, Undertow
- **Production-ready**: Metrics, health checks, monitoring sẵn có
- **No XML configuration**: Sử dụng annotation và Java configuration

#### **So sánh với Spring truyền thống:**

```xml
<!-- Spring truyền thống cần cấu hình XML phức tạp -->
<beans xmlns="http://www.springframework.org/schema/beans">
    <bean id="dataSource" class="org.springframework.jdbc.datasource.DriverManagerDataSource">
        <property name="driverClassName" value="com.mysql.jdbc.Driver"/>
        <property name="url" value="jdbc:mysql://localhost:3306/mydb"/>
    </bean>
    
    <bean id="sessionFactory" class="org.springframework.orm.hibernate5.LocalSessionFactoryBean">
        <property name="dataSource" ref="dataSource"/>
        <!-- Nhiều cấu hình khác... -->
    </bean>
</beans>
```

```java
// Spring Boot chỉ cần annotation đơn giản
@SpringBootApplication
public class MyApplication {
    public static void main(String[] args) {
        SpringApplication.run(MyApplication.class, args);
    }
}
```

### Khởi tạo Dự án

#### **1. Sử dụng Spring Initializr**

Truy cập https://start.spring.io/ và cấu hình:

```
Project: Maven Project
Language: Java
Spring Boot: 3.1.5
Project Metadata:
  Group: com.minhlong
  Artifact: spring-boot-web-demo
  Name: spring-boot-web-demo
  Package name: com.minhlong.springbootwebdemo
  Packaging: Jar
  Java: 17

Dependencies:
  - Spring Web
  - Spring Boot DevTools (optional)
```

#### **2. Cấu trúc project được tạo:**

```
spring-boot-web-demo/
├── src/
│   ├── main/
│   │   ├── java/
│   │   │   └── com/minhlong/springbootwebdemo/
│   │   │       └── SpringBootWebDemoApplication.java
│   │   └── resources/
│   │       ├── application.properties
│   │       ├── static/
│   │       └── templates/
│   └── test/
├── target/
├── pom.xml
└── README.md
```

#### **3. File pom.xml được tạo:**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0">
    <modelVersion>4.0.0</modelVersion>
    
    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>3.1.5</version>
        <relativePath/>
    </parent>
    
    <groupId>com.minhlong</groupId>
    <artifactId>spring-boot-web-demo</artifactId>
    <version>0.0.1-SNAPSHOT</version>
    <name>spring-boot-web-demo</name>
    <description>Demo project for Spring Boot Web</description>
    
    <properties>
        <java.version>17</java.version>
    </properties>
    
    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-devtools</artifactId>
            <scope>runtime</scope>
            <optional>true</optional>
        </dependency>
        
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>
    </dependencies>
    
    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>
        </plugins>
    </build>
</project>
```

### Tạo Controller đầu tiên

#### **1. Main Application Class:**

```java
package com.minhlong.springbootwebdemo;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class SpringBootWebDemoApplication {
    public static void main(String[] args) {
        SpringApplication.run(SpringBootWebDemoApplication.class, args);
    }
}
```

#### **2. Tạo Controller cơ bản:**

```java
package com.minhlong.springbootwebdemo.controller;

import org.springframework.web.bind.annotation.*;
import java.time.LocalDateTime;
import java.util.*;

@RestController
@RequestMapping("/api")
public class HelloController {
    
    // GET endpoint đơn giản
    @GetMapping("/hello")
    public String sayHello() {
        return "Xin chào từ Spring Boot!";
    }
    
    // GET với path variable
    @GetMapping("/hello/{name}")
    public String sayHelloToUser(@PathVariable String name) {
        return "Xin chào " + name + "! Chào mừng đến với Spring Boot.";
    }
    
    // GET với request parameter
    @GetMapping("/greet")
    public String greetUser(@RequestParam(defaultValue = "Guest") String name,
                           @RequestParam(defaultValue = "vi") String lang) {
        if ("en".equals(lang)) {
            return "Hello " + name + "!";
        }
        return "Xin chào " + name + "!";
    }
    
    // Trả về JSON object
    @GetMapping("/user")
    public Map<String, Object> getUserInfo() {
        Map<String, Object> user = new HashMap<>();
        user.put("id", 1);
        user.put("name", "Lê Trần Minh Long");
        user.put("email", "long@example.com");
        user.put("timestamp", LocalDateTime.now());
        return user;
    }
    
    // Trả về danh sách JSON
    @GetMapping("/users")
    public List<Map<String, Object>> getAllUsers() {
        List<Map<String, Object>> users = new ArrayList<>();
        
        Map<String, Object> user1 = new HashMap<>();
        user1.put("id", 1);
        user1.put("name", "Lê Trần Minh Long");
        user1.put("email", "long@example.com");
        
        Map<String, Object> user2 = new HashMap<>();
        user2.put("id", 2);
        user2.put("name", "Nguyễn Văn A");
        user2.put("email", "a@example.com");
        
        users.add(user1);
        users.add(user2);
        
        return users;
    }
}
```

#### **3. Tạo Data Transfer Object (DTO):**

```java
package com.minhlong.springbootwebdemo.model;

import java.time.LocalDateTime;

public class User {
    private Long id;
    private String name;
    private String email;
    private LocalDateTime createdAt;
    
    // Constructors
    public User() {
        this.createdAt = LocalDateTime.now();
    }
    
    public User(Long id, String name, String email) {
        this.id = id;
        this.name = name;
        this.email = email;
        this.createdAt = LocalDateTime.now();
    }
    
    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
```

#### **4. Controller sử dụng DTO:**

```java
package com.minhlong.springbootwebdemo.controller;

import com.minhlong.springbootwebdemo.model.User;
import org.springframework.web.bind.annotation.*;
import java.util.*;

@RestController
@RequestMapping("/api/v2")
public class UserController {
    
    private List<User> users = new ArrayList<>();
    private Long nextId = 1L;
    
    // Constructor để khởi tạo dữ liệu mẫu
    public UserController() {
        users.add(new User(nextId++, "Lê Trần Minh Long", "long@example.com"));
        users.add(new User(nextId++, "Nguyễn Văn A", "a@example.com"));
    }
    
    // GET - Lấy tất cả users
    @GetMapping("/users")
    public List<User> getAllUsers() {
        return users;
    }
    
    // GET - Lấy user theo ID
    @GetMapping("/users/{id}")
    public User getUserById(@PathVariable Long id) {
        return users.stream()
                .filter(user -> user.getId().equals(id))
                .findFirst()
                .orElse(null);
    }
    
    // POST - Tạo user mới
    @PostMapping("/users")
    public User createUser(@RequestBody User user) {
        user.setId(nextId++);
        users.add(user);
        return user;
    }
    
    // PUT - Cập nhật user
    @PutMapping("/users/{id}")
    public User updateUser(@PathVariable Long id, @RequestBody User updatedUser) {
        for (int i = 0; i < users.size(); i++) {
            User user = users.get(i);
            if (user.getId().equals(id)) {
                updatedUser.setId(id);
                users.set(i, updatedUser);
                return updatedUser;
            }
        }
        return null;
    }
    
    // DELETE - Xóa user
    @DeleteMapping("/users/{id}")
    public boolean deleteUser(@PathVariable Long id) {
        return users.removeIf(user -> user.getId().equals(id));
    }
}
```

### Chạy và Thử nghiệm

#### **1. Chạy ứng dụng:**

```bash
# Sử dụng Maven
mvn spring-boot:run

# Hoặc chạy từ IDE (Run main method)

# Hoặc build và chạy jar
mvn clean package
java -jar target/spring-boot-web-demo-0.0.1-SNAPSHOT.jar
```

#### **2. Log khi khởi động:**

```
  .   ____          _            __ _ _
 /\\ / ___'_ __ _ _(_)_ __  __ _ \ \ \ \
( ( )\___ | '_ | '_| | '_ \/ _` | \ \ \ \
 \\/  ___)| |_)| | | | | || (_| |  ) ) ) )
  '  |____| .__|_| |_|_| |_\__, | / / / /
 =========|_|==============|___/=/_/_/_/
 :: Spring Boot ::                (v3.1.5)

2025-10-15T10:30:00.123  INFO --- [main] c.m.s.SpringBootWebDemoApplication : Starting SpringBootWebDemoApplication
2025-10-15T10:30:01.456  INFO --- [main] o.s.b.w.embedded.tomcat.TomcatWebServer : Tomcat initialized with port(s): 8080 (http)
2025-10-15T10:30:02.789  INFO --- [main] c.m.s.SpringBootWebDemoApplication : Started SpringBootWebDemoApplication in 2.666 seconds
```

#### **3. Test các endpoint:**

```bash
# Test bằng cURL
curl http://localhost:8080/api/hello
# Response: Xin chào từ Spring Boot!

curl http://localhost:8080/api/hello/MinhLong
# Response: Xin chào MinhLong! Chào mừng đến với Spring Boot.

curl http://localhost:8080/api/greet?name=Long&lang=en
# Response: Hello Long!

curl http://localhost:8080/api/user
# Response: {"id":1,"name":"Lê Trần Minh Long","email":"long@example.com","timestamp":"2025-10-15T10:30:05"}

# Test POST với JSON
curl -X POST http://localhost:8080/api/v2/users \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","email":"test@example.com"}'
```

#### **4. File cấu hình application.properties:**

```properties
# Server configuration
server.port=8080
server.servlet.context-path=/

# Logging configuration
logging.level.com.minhlong=DEBUG
logging.level.org.springframework.web=INFO

# Development configuration
spring.devtools.restart.enabled=true
spring.devtools.livereload.enabled=true

# JSON configuration
spring.jackson.serialization.write-dates-as-timestamps=false
spring.jackson.serialization.indent-output=true
```

#### **5. Test bằng Postman:**

Tạo collection với các request:
- GET `http://localhost:8080/api/hello`
- GET `http://localhost:8080/api/v2/users`
- POST `http://localhost:8080/api/v2/users` với body JSON
- PUT `http://localhost:8080/api/v2/users/1` với body JSON
- DELETE `http://localhost:8080/api/v2/users/1`

## Kết luận

Spring Boot giúp lập trình viên Java tập trung vào logic nghiệp vụ thay vì cấu hình phức tạp, tăng tốc độ phát triển ứng dụng Web/API. Những lợi ích chính:

- **Rapid Development**: Khởi tạo project nhanh chóng
- **Convention over Configuration**: Ít cấu hình, nhiều quy ước
- **Built-in Features**: Embedded server, auto-configuration
- **Production Ready**: Metrics, health checks có sẵn
- **Easy Testing**: Test framework tích hợp sẵn

Spring Boot là nền tảng lý tưởng để xây dựng microservices và REST APIs trong Java ecosystem.
