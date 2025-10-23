---
title: "Sử dụng Java Socket: Xây dựng Chat Server và Client đơn giản"
date: 2025-10-14T00:00:00+07:00
draft: false
categories: ["Java", "Backend/Mạng"]
type: "post"
---

**Mở đầu:** Không gì tuyệt vời hơn việc tự tay xây dựng một ứng dụng trò chuyện (Chat) để củng cố kiến thức về lập trình Socket. Bài viết này sẽ hướng dẫn chi tiết cách tạo một ứng dụng chat đa luồng (multi-threaded) cơ bản bằng Java Socket.

## Nội dung chính:

### Cơ chế Socket trong Java

Java cung cấp hai lớp chính để làm việc với Socket:
- **ServerSocket**: Sử dụng ở phía Server để lắng nghe và chấp nhận kết nối
- **Socket**: Sử dụng ở cả Client và Server để giao tiếp

### Thiết kế Server đa luồng

Server cần xử lý đồng thời nhiều Client, vì vậy mỗi kết nối Client sẽ được xử lý bởi một Thread riêng biệt.

#### 1. Chat Server Implementation

```java
import java.io.*;
import java.net.*;
import java.util.*;
import java.util.concurrent.CopyOnWriteArrayList;

public class ChatServer {
    private static final int PORT = 12345;
    private static List<ClientHandler> clients = new CopyOnWriteArrayList<>();
    
    public static void main(String[] args) {
        System.out.println("Chat Server đang khởi động...");
        
        try (ServerSocket serverSocket = new ServerSocket(PORT)) {
            System.out.println("Server đang lắng nghe trên port " + PORT);
            
            while (true) {
                Socket clientSocket = serverSocket.accept();
                System.out.println("Client mới kết nối: " + clientSocket.getInetAddress());
                
                // Tạo thread mới cho mỗi client
                ClientHandler clientHandler = new ClientHandler(clientSocket);
                clients.add(clientHandler);
                
                Thread clientThread = new Thread(clientHandler);
                clientThread.start();
            }
        } catch (IOException e) {
            System.err.println("Lỗi Server: " + e.getMessage());
        }
    }
    
    // Broadcast tin nhắn đến tất cả clients
    public static void broadcastMessage(String message, ClientHandler sender) {
        for (ClientHandler client : clients) {
            if (client != sender && client.isConnected()) {
                client.sendMessage(message);
            }
        }
    }
    
    // Xóa client khi disconnect
    public static void removeClient(ClientHandler client) {
        clients.remove(client);
        System.out.println("Client đã disconnect. Số clients hiện tại: " + clients.size());
    }
}
```

#### 2. Client Handler Class

```java
class ClientHandler implements Runnable {
    private Socket socket;
    private BufferedReader input;
    private PrintWriter output;
    private String username;
    private boolean connected = true;
    
    public ClientHandler(Socket socket) {
        this.socket = socket;
        try {
            input = new BufferedReader(new InputStreamReader(socket.getInputStream()));
            output = new PrintWriter(socket.getOutputStream(), true);
        } catch (IOException e) {
            System.err.println("Lỗi khởi tạo ClientHandler: " + e.getMessage());
        }
    }
    
    @Override
    public void run() {
        try {
            // Nhận username từ client
            output.println("Nhập username của bạn:");
            username = input.readLine();
            
            if (username == null || username.trim().isEmpty()) {
                username = "Guest_" + socket.getPort();
            }
            
            System.out.println(username + " đã tham gia chat");
            ChatServer.broadcastMessage("*** " + username + " đã tham gia chat ***", this);
            
            // Lắng nghe tin nhắn từ client
            String message;
            while (connected && (message = input.readLine()) != null) {
                if (message.equalsIgnoreCase("/quit")) {
                    break;
                }
                
                // Xử lý các lệnh đặc biệt
                if (message.startsWith("/")) {
                    handleCommand(message);
                } else {
                    // Broadcast tin nhắn bình thường
                    String formattedMessage = "[" + username + "]: " + message;
                    System.out.println(formattedMessage);
                    ChatServer.broadcastMessage(formattedMessage, this);
                }
            }
        } catch (IOException e) {
            System.err.println("Lỗi giao tiếp với client " + username + ": " + e.getMessage());
        } finally {
            disconnect();
        }
    }
    
    private void handleCommand(String command) {
        switch (command.toLowerCase()) {
            case "/help":
                sendMessage("Các lệnh khả dụng:");
                sendMessage("/help - Hiển thị trợ giúp");
                sendMessage("/users - Hiển thị danh sách người dùng online");
                sendMessage("/quit - Thoát khỏi chat");
                break;
                
            case "/users":
                sendMessage("Người dùng online: " + ChatServer.clients.size());
                for (ClientHandler client : ChatServer.clients) {
                    if (client.isConnected()) {
                        sendMessage("- " + client.getUsername());
                    }
                }
                break;
                
            default:
                sendMessage("Lệnh không hợp lệ. Gõ /help để xem danh sách lệnh.");
                break;
        }
    }
    
    public void sendMessage(String message) {
        if (output != null && connected) {
            output.println(message);
        }
    }
    
    public void disconnect() {
        connected = false;
        try {
            if (input != null) input.close();
            if (output != null) output.close();
            if (socket != null) socket.close();
        } catch (IOException e) {
            System.err.println("Lỗi khi đóng kết nối: " + e.getMessage());
        }
        
        ChatServer.broadcastMessage("*** " + username + " đã rời khỏi chat ***", this);
        ChatServer.removeClient(this);
    }
    
    public boolean isConnected() {
        return connected && !socket.isClosed();
    }
    
    public String getUsername() {
        return username;
    }
}
```

### Luồng Dữ liệu và Chat Client

#### 3. Chat Client Implementation

```java
import java.io.*;
import java.net.*;
import java.util.Scanner;

public class ChatClient {
    private static final String SERVER_HOST = "localhost";
    private static final int SERVER_PORT = 12345;
    
    private Socket socket;
    private BufferedReader input;
    private PrintWriter output;
    private Scanner scanner;
    
    public ChatClient() {
        scanner = new Scanner(System.in);
    }
    
    public void start() {
        try {
            // Kết nối đến server
            socket = new Socket(SERVER_HOST, SERVER_PORT);
            System.out.println("Đã kết nối đến Chat Server!");
            
            // Khởi tạo input/output streams
            input = new BufferedReader(new InputStreamReader(socket.getInputStream()));
            output = new PrintWriter(socket.getOutputStream(), true);
            
            // Tạo thread để nhận tin nhắn từ server
            Thread messageReceiver = new Thread(new MessageReceiver());
            messageReceiver.setDaemon(true);
            messageReceiver.start();
            
            // Thread chính để gửi tin nhắn
            String message;
            while (true) {
                message = scanner.nextLine();
                
                if (message.equalsIgnoreCase("/quit")) {
                    output.println(message);
                    break;
                }
                
                output.println(message);
            }
            
        } catch (IOException e) {
            System.err.println("Lỗi kết nối: " + e.getMessage());
        } finally {
            disconnect();
        }
    }
    
    private void disconnect() {
        try {
            if (input != null) input.close();
            if (output != null) output.close();
            if (socket != null) socket.close();
            scanner.close();
        } catch (IOException e) {
            System.err.println("Lỗi khi đóng kết nối: " + e.getMessage());
        }
        System.out.println("Đã ngắt kết nối khỏi server.");
    }
    
    // Inner class để nhận tin nhắn từ server
    private class MessageReceiver implements Runnable {
        @Override
        public void run() {
            try {
                String message;
                while ((message = input.readLine()) != null) {
                    System.out.println(message);
                }
            } catch (IOException e) {
                System.err.println("Kết nối đến server đã bị ngắt.");
            }
        }
    }
    
    public static void main(String[] args) {
        ChatClient client = new ChatClient();
        client.start();
    }
}
```

### Minh họa Code hoàn chỉnh

#### 4. Enhanced Chat Server với tính năng nâng cao

```java
import java.io.*;
import java.net.*;
import java.text.SimpleDateFormat;
import java.util.*;
import java.util.concurrent.CopyOnWriteArrayList;

public class EnhancedChatServer {
    private static final int PORT = 12345;
    private static List<ClientHandler> clients = new CopyOnWriteArrayList<>();
    private static SimpleDateFormat dateFormat = new SimpleDateFormat("HH:mm:ss");
    
    public static void main(String[] args) {
        System.out.println("=== Enhanced Chat Server ===");
        System.out.println("Server khởi động tại: " + new Date());
        
        try (ServerSocket serverSocket = new ServerSocket(PORT)) {
            System.out.println("Server đang lắng nghe trên port " + PORT);
            
            // Shutdown hook để đóng server một cách graceful
            Runtime.getRuntime().addShutdownHook(new Thread(() -> {
                System.out.println("\nServer đang shutdown...");
                broadcastMessage("*** Server đang shutdown ***", null);
                for (ClientHandler client : clients) {
                    client.disconnect();
                }
            }));
            
            while (true) {
                Socket clientSocket = serverSocket.accept();
                String clientIP = clientSocket.getInetAddress().getHostAddress();
                System.out.println("[" + dateFormat.format(new Date()) + "] " +
                                 "Client mới từ: " + clientIP);
                
                ClientHandler clientHandler = new ClientHandler(clientSocket);
                clients.add(clientHandler);
                
                Thread clientThread = new Thread(clientHandler);
                clientThread.setName("Client-" + clientIP);
                clientThread.start();
            }
        } catch (IOException e) {
            System.err.println("Lỗi Server: " + e.getMessage());
        }
    }
    
    public static void broadcastMessage(String message, ClientHandler sender) {
        String timestamp = "[" + dateFormat.format(new Date()) + "] ";
        String fullMessage = timestamp + message;
        
        for (ClientHandler client : clients) {
            if (client != sender && client.isConnected()) {
                client.sendMessage(fullMessage);
            }
        }
    }
    
    public static void removeClient(ClientHandler client) {
        clients.remove(client);
        System.out.println("[" + dateFormat.format(new Date()) + "] " +
                         "Client removed. Active clients: " + clients.size());
    }
    
    public static List<ClientHandler> getClients() {
        return new ArrayList<>(clients);
    }
}
```

#### 5. Cách chạy ứng dụng

```bash
# Compile các file Java
javac ChatServer.java
javac ChatClient.java

# Chạy Server
java ChatServer

# Chạy Client (trong terminal khác)
java ChatClient
```

#### 6. Ví dụ sử dụng

```
Server Console:
=== Enhanced Chat Server ===
Server khởi động tại: Mon Oct 14 10:30:00 ICT 2025
Server đang lắng nghe trên port 12345
[10:30:15] Client mới từ: 127.0.0.1
MinhLong đã tham gia chat
[10:30:25] [MinhLong]: Xin chào mọi người!

Client Console:
Đã kết nối đến Chat Server!
Nhập username của bạn:
MinhLong
*** MinhLong đã tham gia chat ***
Xin chào mọi người!
[10:30:25] [MinhLong]: Xin chào mọi người!
```

### Tính năng mở rộng

```java
// Thêm vào ClientHandler class
private void handlePrivateMessage(String command) {
    // Format: /msg username message
    String[] parts = command.split(" ", 3);
    if (parts.length >= 3) {
        String targetUser = parts[1];
        String message = parts[2];
        
        for (ClientHandler client : ChatServer.getClients()) {
            if (client.getUsername().equals(targetUser)) {
                client.sendMessage("[Private from " + username + "]: " + message);
                sendMessage("[Private to " + targetUser + "]: " + message);
                return;
            }
        }
        sendMessage("Người dùng " + targetUser + " không tồn tại.");
    } else {
        sendMessage("Cú pháp: /msg <username> <message>");
    }
}
```

## Kết luận
Bài tập Socket chat là một cách hiệu quả để làm chủ Lập trình Mạng I/O trong Java và hiểu về các vấn đề đồng thời (Concurrency). Qua việc xây dựng ứng dụng này, bạn đã học được cách:

- Sử dụng ServerSocket và Socket
- Xử lý đa luồng (Multi-threading)
- Quản lý Input/Output Streams
- Xử lý kết nối và ngắt kết nối
- Broadcast messages đến multiple clients

Đây là nền tảng quan trọng để phát triển các ứng dụng mạng phức tạp hơn trong Java.
