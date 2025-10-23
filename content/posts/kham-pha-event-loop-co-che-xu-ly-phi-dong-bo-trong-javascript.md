---
title: "Khám phá Event Loop: Cơ chế xử lý phi đồng bộ trong JavaScript"
date: 2025-10-16T00:00:00+07:00
draft: false
categories: ["JavaScript", "Mạng & Web"]
type: "post"
---

**Mở đầu:** Tính chất phi đồng bộ (asynchronous) là chìa khóa để JavaScript (đặc biệt là Node.js) xử lý hàng ngàn kết nối mạng đồng thời chỉ với một luồng (thread) duy nhất. Bài viết này đi sâu vào cơ chế Event Loop huyền thoại.

## Nội dung chính:

### Thế nào là Phi đồng bộ?

#### **Blocking vs Non-blocking I/O**

```javascript
// BLOCKING I/O (Synchronous) - Tệ cho performance
console.log("1. Bắt đầu");

// Giả sử đây là một tác vụ mất 3 giây
function heavyTask() {
    const start = Date.now();
    while (Date.now() - start < 3000) {
        // Block thread trong 3 giây
    }
    return "Heavy task completed";
}

console.log("2. Trước heavy task");
const result = heavyTask(); // BLOCK tại đây 3 giây
console.log("3. Sau heavy task:", result);
console.log("4. Kết thúc");

// Output (với delay 3 giây):
// 1. Bắt đầu
// 2. Trước heavy task
// (chờ 3 giây...)
// 3. Sau heavy task: Heavy task completed
// 4. Kết thúc
```

```javascript
// NON-BLOCKING I/O (Asynchronous) - Tốt cho performance
console.log("1. Bắt đầu");

console.log("2. Trước async task");

// Async task sử dụng setTimeout
setTimeout(() => {
    console.log("3. Async task completed");
}, 3000);

console.log("4. Sau async task");
console.log("5. Kết thúc");

// Output (ngay lập tức):
// 1. Bắt đầu
// 2. Trước async task
// 4. Sau async task
// 5. Kết thúc
// (sau 3 giây...)
// 3. Async task completed
```

### Các thành phần chính của Event Loop

#### **1. Call Stack (Ngăn xếp cuộc gọi)**

```javascript
function first() {
    console.log("First function");
    second();
}

function second() {
    console.log("Second function");
    third();
}

function third() {
    console.log("Third function");
}

first();

// Call Stack trace:
// 1. first() được push vào stack
// 2. second() được push vào stack
// 3. third() được push vào stack
// 4. third() hoàn thành, pop khỏi stack
// 5. second() hoàn thành, pop khỏi stack
// 6. first() hoàn thành, pop khỏi stack
```

#### **2. Web APIs / C++ APIs**

```javascript
// Các hàm này được xử lý bởi Web APIs (browser) hoặc C++ APIs (Node.js)
setTimeout(() => console.log("Timer"), 1000);
fetch('https://api.example.com/data');
fs.readFile('file.txt', callback);
setInterval(() => console.log("Interval"), 2000);
```

#### **3. Callback Queue (Task Queue)**

```javascript
// Callback Queue example
console.log("1. Start");

setTimeout(() => console.log("2. Timer 1"), 0);
setTimeout(() => console.log("3. Timer 2"), 0);

console.log("4. End");

// Output:
// 1. Start
// 4. End
// 2. Timer 1
// 3. Timer 2
```

### Quy trình hoạt động Event Loop

#### **Event Loop Algorithm:**

```javascript
// Mô phỏng Event Loop
function eventLoopSimulation() {
    const callStack = [];
    const callbackQueue = [];
    const webAPIs = {};
    
    // 1. Kiểm tra Call Stack
    function isCallStackEmpty() {
        return callStack.length === 0;
    }
    
    // 2. Event Loop chính
    function eventLoop() {
        // Nếu Call Stack rỗng và có callback trong queue
        if (isCallStackEmpty() && callbackQueue.length > 0) {
            // Lấy callback đầu tiên từ queue
            const callback = callbackQueue.shift();
            // Đẩy vào Call Stack
            callStack.push(callback);
            // Thực thi callback
            callback();
            callStack.pop();
        }
    }
    
    // 3. Mô phỏng Web API
    function simulateWebAPI(callback, delay) {
        setTimeout(() => {
            callbackQueue.push(callback);
        }, delay);
    }
}
```

#### **Ví dụ chi tiết về thứ tự thực thi:**

```javascript
console.log("=== Event Loop Demo ===");

// 1. Synchronous code
console.log("1. Start");

// 2. setTimeout với delay 0
setTimeout(() => {
    console.log("2. setTimeout 0ms");
}, 0);

// 3. Promise (Microtask)
Promise.resolve().then(() => {
    console.log("3. Promise microtask");
});

// 4. setTimeout với delay
setTimeout(() => {
    console.log("4. setTimeout 100ms");
}, 100);

// 5. Synchronous code
console.log("5. End");

// 6. setImmediate (Node.js only)
setImmediate(() => {
    console.log("6. setImmediate");
});

// 7. process.nextTick (Node.js only)
process.nextTick(() => {
    console.log("7. process.nextTick");
});

// Output trong Node.js:
// 1. Start
// 5. End
// 7. process.nextTick
// 3. Promise microtask
// 2. setTimeout 0ms
// 6. setImmediate
// 4. setTimeout 100ms
```

### Ví dụ thực tế với Network I/O

#### **1. HTTP Requests với Event Loop:**

```javascript
const http = require('http');
const url = require('url');

console.log("Server starting...");

const server = http.createServer((req, res) => {
    const parsedUrl = url.parse(req.url, true);
    
    console.log(`Request received: ${req.method} ${req.url}`);
    
    // Mô phỏng async operation
    if (parsedUrl.pathname === '/fast') {
        // Fast response
        setImmediate(() => {
            res.writeHead(200, { 'Content-Type': 'application/json' });
            res.end(JSON.stringify({ 
                message: 'Fast response', 
                timestamp: Date.now() 
            }));
        });
    } 
    else if (parsedUrl.pathname === '/slow') {
        // Slow response with setTimeout
        setTimeout(() => {
            res.writeHead(200, { 'Content-Type': 'application/json' });
            res.end(JSON.stringify({ 
                message: 'Slow response after 2 seconds', 
                timestamp: Date.now() 
            }));
        }, 2000);
    }
    else if (parsedUrl.pathname === '/promise') {
        // Promise-based response
        Promise.resolve()
            .then(() => {
                return { message: 'Promise response', timestamp: Date.now() };
            })
            .then(data => {
                res.writeHead(200, { 'Content-Type': 'application/json' });
                res.end(JSON.stringify(data));
            });
    }
    else {
        res.writeHead(404, { 'Content-Type': 'text/plain' });
        res.end('Not Found');
    }
});

server.listen(3000, () => {
    console.log("Server listening on port 3000");
});

// Test với nhiều requests đồng thời
function testConcurrentRequests() {
    const startTime = Date.now();
    
    // Gửi 100 requests đồng thời
    for (let i = 0; i < 100; i++) {
        http.get('http://localhost:3000/fast', (res) => {
            let data = '';
            res.on('data', chunk => data += chunk);
            res.on('end', () => {
                console.log(`Request ${i} completed in ${Date.now() - startTime}ms`);
            });
        });
    }
}
```

#### **2. Event Loop với Database Operations:**

```javascript
const fs = require('fs').promises;

async function demonstrateAsyncFlow() {
    console.log("=== Async Flow Demo ===");
    
    console.log("1. Start");
    
    // File I/O (async)
    fs.readFile('package.json', 'utf8')
        .then(data => {
            console.log("4. File read completed");
        })
        .catch(err => {
            console.log("4. File read error:", err.message);
        });
    
    // Timer
    setTimeout(() => {
        console.log("5. Timer 1000ms completed");
    }, 1000);
    
    // Immediate
    setImmediate(() => {
        console.log("3. setImmediate executed");
    });
    
    // Promise
    Promise.resolve().then(() => {
        console.log("2. Promise resolved");
    });
    
    console.log("6. End");
}

demonstrateAsyncFlow();
```

#### **3. Event Loop Priority Order:**

```javascript
function priorityDemo() {
    console.log("=== Priority Demo ===");
    
    // 1. process.nextTick (highest priority)
    process.nextTick(() => console.log("1. nextTick"));
    
    // 2. Promise microtasks
    Promise.resolve().then(() => console.log("2. Promise"));
    
    // 3. setImmediate
    setImmediate(() => console.log("3. setImmediate"));
    
    // 4. setTimeout
    setTimeout(() => console.log("4. setTimeout"), 0);
    
    // 5. I/O callbacks
    require('fs').readFile(__filename, () => {
        console.log("5. I/O callback");
        
        // Nested callbacks
        setImmediate(() => console.log("6. nested setImmediate"));
        setTimeout(() => console.log("7. nested setTimeout"), 0);
    });
    
    console.log("0. Synchronous");
}

priorityDemo();
```

### Ví dụ thực tế: Chat Server với Event Loop

```javascript
const net = require('net');

class AsyncChatServer {
    constructor(port = 3001) {
        this.port = port;
        this.clients = new Set();
        this.messageQueue = [];
        this.server = null;
    }
    
    start() {
        this.server = net.createServer((socket) => {
            this.handleNewClient(socket);
        });
        
        this.server.listen(this.port, () => {
            console.log(`Async Chat Server listening on port ${this.port}`);
        });
        
        // Process message queue asynchronously
        this.processMessageQueue();
    }
    
    handleNewClient(socket) {
        console.log(`New client connected: ${socket.remoteAddress}:${socket.remotePort}`);
        this.clients.add(socket);
        
        // Handle data asynchronously
        socket.on('data', (data) => {
            // Add to message queue instead of processing immediately
            this.messageQueue.push({
                sender: socket,
                message: data.toString().trim(),
                timestamp: Date.now()
            });
        });
        
        socket.on('close', () => {
            console.log(`Client disconnected: ${socket.remoteAddress}:${socket.remotePort}`);
            this.clients.delete(socket);
        });
        
        socket.on('error', (err) => {
            console.error('Socket error:', err.message);
            this.clients.delete(socket);
        });
    }
    
    processMessageQueue() {
        // Process messages asynchronously using setImmediate
        setImmediate(() => {
            if (this.messageQueue.length > 0) {
                const { sender, message, timestamp } = this.messageQueue.shift();
                this.broadcastMessage(sender, message, timestamp);
            }
            
            // Continue processing queue
            this.processMessageQueue();
        });
    }
    
    broadcastMessage(sender, message, timestamp) {
        const formattedMessage = `[${new Date(timestamp).toLocaleTimeString()}] ${message}\n`;
        
        // Broadcast to all clients asynchronously
        this.clients.forEach(client => {
            if (client !== sender && !client.destroyed) {
                // Use setImmediate to avoid blocking
                setImmediate(() => {
                    client.write(formattedMessage);
                });
            }
        });
    }
}

// Start the server
const chatServer = new AsyncChatServer(3001);
chatServer.start();
```

### Performance Monitoring với Event Loop

```javascript
// Monitor Event Loop lag
function monitorEventLoop() {
    let start = process.hrtime.bigint();
    
    setImmediate(() => {
        const end = process.hrtime.bigint();
        const lag = Number(end - start) / 1000000; // Convert to milliseconds
        
        console.log(`Event Loop Lag: ${lag.toFixed(2)}ms`);
        
        // Continue monitoring
        setTimeout(monitorEventLoop, 1000);
    });
}

monitorEventLoop();

// CPU intensive task that blocks Event Loop
function simulateBlockingTask() {
    console.log("Starting blocking task...");
    const start = Date.now();
    
    // Block for 100ms
    while (Date.now() - start < 100) {
        // CPU intensive work
    }
    
    console.log("Blocking task completed");
}

// Non-blocking alternative
function simulateNonBlockingTask() {
    console.log("Starting non-blocking task...");
    
    function chunk() {
        const start = Date.now();
        
        // Work for 10ms chunks
        while (Date.now() - start < 10) {
            // CPU intensive work
        }
        
        // Yield control back to Event Loop
        setImmediate(() => {
            // Continue if more work needed
            console.log("Non-blocking chunk completed");
        });
    }
    
    chunk();
}
```

## Kết luận

Hiểu Event Loop là điều kiện tiên quyết để viết code JavaScript (Node.js) backend hiệu suất cao, tránh các vấn đề tắc nghẽn (blocking). Những điểm quan trọng:

### **Key Takeaways:**

1. **Single Thread**: JavaScript chạy trên một thread duy nhất
2. **Non-blocking I/O**: Sử dụng callbacks, promises, async/await
3. **Event Loop Priority**: process.nextTick > Promise > setImmediate > setTimeout
4. **Avoid Blocking**: Chia nhỏ CPU-intensive tasks
5. **Monitor Performance**: Theo dõi Event Loop lag

### **Best Practices:**

- Sử dụng async/await thay vì callback hell
- Tránh synchronous I/O operations
- Chia nhỏ các tác vụ CPU-intensive
- Sử dụng streaming cho large data
- Monitor Event Loop health trong production

Event Loop là trái tim của Node.js performance - master nó để xây dựng các ứng dụng scalable!
