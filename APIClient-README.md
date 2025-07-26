# APIClient 封装组件

一个用于 SwiftUI 应用的前后端连接封装组件，提供简洁易用的 API 调用接口。

## 功能特性

- 🔧 **灵活配置**: 支持配置 baseURL、userID、超时时间和自定义请求头
- 🌐 **多种 HTTP 方法**: 支持 GET、POST、PUT、DELETE、PATCH
- 📦 **泛型支持**: 类型安全的请求和响应处理
- ❌ **完善的错误处理**: 详细的错误分类和本地化错误信息
- 🔄 **异步支持**: 基于 async/await 的现代异步编程
- 📱 **SwiftUI 集成**: 作为 ObservableObject，无缝集成到 SwiftUI 视图中

## 核心组件

### APIConfig
配置 API 客户端的基本参数：
```swift
let config = APIConfig(
    baseURL: "https://api.example.com",
    userID: "user123",
    timeout: 30.0,
    headers: ["Authorization": "Bearer token"]
)
```

### APIClient
主要的 API 客户端类，提供以下方法：
- `request()` - 通用请求方法
- `get()` - GET 请求
- `post()` - POST 请求  
- `put()` - PUT 请求
- `delete()` - DELETE 请求

### APIResponse
标准化的响应格式，包含：
- `data` - 响应数据
- `statusCode` - HTTP 状态码
- `headers` - 响应头
- `error` - 错误信息
- `isSuccess` - 是否成功

## 使用示例

### 1. 基本设置

```swift
// 创建配置
let config = APIConfig(
    baseURL: "https://api.knowhow.com",
    userID: "user123",
    headers: ["Authorization": "Bearer your-token"]
)

// 创建客户端
let apiClient = APIClient(config: config)
```

### 2. 定义数据模型

```swift
struct User: Codable {
    let id: String
    let name: String
    let email: String
}

struct CreateUserRequest: Codable, APIRequestBody {
    let name: String
    let email: String
}
```

### 3. GET 请求

```swift
let response = await apiClient.get(
    endpoint: "users",
    queryParams: ["page": "1", "limit": "10"],
    responseType: [User].self
)

if response.isSuccess, let users = response.data {
    print("获取到 \(users.count) 个用户")
} else if let error = response.error {
    print("错误: \(error.localizedDescription)")
}
```

### 4. POST 请求

```swift
let newUser = CreateUserRequest(name: "张三", email: "zhangsan@example.com")
let response = await apiClient.post(
    endpoint: "users",
    body: newUser,
    responseType: User.self
)

if response.isSuccess, let user = response.data {
    print("创建用户成功: \(user.name)")
}
```

### 5. 在 SwiftUI 中使用

```swift
struct ContentView: View {
    @StateObject private var apiClient = APIClient(config: myConfig)
    @State private var users: [User] = []
    
    var body: some View {
        List(users, id: \.id) { user in
            Text(user.name)
        }
        .task {
            let response = await apiClient.get(
                endpoint: "users",
                responseType: [User].self
            )
            if let data = response.data {
                users = data
            }
        }
        .overlay {
            if apiClient.isLoading {
                ProgressView("加载中...")
            }
        }
    }
}
```

## 错误处理

APIClient 提供详细的错误分类：

- `invalidURL` - 无效的 URL
- `noData` - 无数据
- `decodingError` - 数据解码错误
- `networkError` - 网络错误
- `serverError` - 服务器错误
- `unauthorized` - 未授权
- `timeout` - 请求超时

## 请求体支持

支持多种请求体格式：

```swift
// Codable 对象
struct RequestData: Codable, APIRequestBody {
    let name: String
}

// 字典
let dictBody: [String: Any] = ["name": "test"]

// 字符串
let stringBody = "raw text data"
```

## 自定义配置

可以为单个请求添加额外的请求头：

```swift
let response = await apiClient.request(
    endpoint: "users",
    method: .POST,
    body: requestData,
    additionalHeaders: ["X-Custom-Header": "value"],
    responseType: User.self
)
```

## 最佳实践

1. **复用 APIClient 实例**: 创建单例或在应用级别管理
2. **错误处理**: 始终检查 `response.error` 和 `response.isSuccess`
3. **类型安全**: 使用强类型的 Codable 模型
4. **用户体验**: 利用 `isLoading` 属性显示加载状态
5. **超时设置**: 根据网络环境调整合适的超时时间

## 依赖

- iOS 15.0+
- SwiftUI
- Foundation

该组件已集成到 konwHow 项目中，位于 `konwHow/Models/APIClient.swift`。