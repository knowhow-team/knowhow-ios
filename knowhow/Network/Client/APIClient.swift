//
//  APIClient.swift
//  knowhow
//
//  Created by F1reC on 2025/7/26.
//

import Foundation
import SwiftUI

// MARK: - API Configuration
struct APIConfig {
    let baseURL: String
    let userID: String
    let timeout: TimeInterval
    let headers: [String: String]
    
    init(baseURL: String, userID: String, timeout: TimeInterval = 30.0, headers: [String: String] = [:]) {
        self.baseURL = baseURL
        self.userID = userID
        self.timeout = timeout
        self.headers = headers
    }
}

// MARK: - HTTP Methods
enum HTTPMethod: String, CaseIterable {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
    case PATCH = "PATCH"
}

// MARK: - API Errors
enum APIError: LocalizedError {
    case invalidURL
    case noData
    case decodingError(Error)
    case networkError(Error)
    case serverError(statusCode: Int, message: String?)
    case unauthorized
    case timeout
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .serverError(let statusCode, let message):
            return "Server error (\(statusCode)): \(message ?? "Unknown error")"
        case .unauthorized:
            return "Unauthorized access"
        case .timeout:
            return "Request timeout"
        case .unknown:
            return "Unknown error occurred"
        }
    }
}

// MARK: - API Response
struct APIResponse<T> {
    let data: T?
    let statusCode: Int
    let headers: [AnyHashable: Any]
    let error: APIError?
    
    var isSuccess: Bool {
        return (200...299).contains(statusCode) && error == nil
    }
}

// MARK: - Request Body Protocol
protocol APIRequestBody {
    func toData() throws -> Data
}

extension APIRequestBody where Self: Codable {
    func toData() throws -> Data {
        return try JSONEncoder().encode(self)
    }
}

extension Dictionary: APIRequestBody where Key == String, Value: Codable {
    func toData() throws -> Data {
        return try JSONSerialization.data(withJSONObject: self)
    }
}

extension String: APIRequestBody {
    func toData() throws -> Data {
        guard let data = self.data(using: .utf8) else {
            throw APIError.decodingError(NSError(domain: "StringEncoding", code: -1))
        }
        return data
    }
}

// MARK: - API Client
@MainActor
class APIClient: ObservableObject {
    private let config: APIConfig
    private let session: URLSession
    
    @Published var isLoading = false
    @Published var lastError: APIError?
    
    init(config: APIConfig) {
        self.config = config
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = config.timeout
        configuration.timeoutIntervalForResource = config.timeout * 2
        
        self.session = URLSession(configuration: configuration)
    }
    
    // MARK: - Generic Request Method
    func request<T: Codable, B: APIRequestBody>(
        endpoint: String,
        method: HTTPMethod = .GET,
        body: B? = nil,
        queryParams: [String: String] = [:],
        additionalHeaders: [String: String] = [:],
        responseType: T.Type
    ) async -> APIResponse<T> {
        
        isLoading = true
        lastError = nil
        
        defer {
            isLoading = false
        }
        
        // Construct URL
        guard var urlComponents = URLComponents(string: "\(config.baseURL)/\(endpoint)") else {
            let error = APIError.invalidURL
            lastError = error
            return APIResponse(data: nil, statusCode: -1, headers: [:], error: error)
        }
        
        // Add query parameters
        if !queryParams.isEmpty {
            urlComponents.queryItems = queryParams.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        
        guard let url = urlComponents.url else {
            let error = APIError.invalidURL
            lastError = error
            return APIResponse(data: nil, statusCode: -1, headers: [:], error: error)
        }
        
        // Create request
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        // Set headers
        var headers = config.headers
        headers["Content-Type"] = "application/json"
        headers["User-ID"] = config.userID
        
        // Add additional headers
        for (key, value) in additionalHeaders {
            headers[key] = value
        }
        
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        // Set body
        if let body = body {
            do {
                request.httpBody = try body.toData()
            } catch {
                let apiError = APIError.decodingError(error)
                lastError = apiError
                return APIResponse(data: nil, statusCode: -1, headers: [:], error: apiError)
            }
        }
        
        // Perform request
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                let error = APIError.unknown
                lastError = error
                return APIResponse(data: nil, statusCode: -1, headers: [:], error: error)
            }
            
            let statusCode = httpResponse.statusCode
            let responseHeaders = httpResponse.allHeaderFields
            
            // Handle HTTP errors
            if !(200...299).contains(statusCode) {
                let errorMessage = String(data: data, encoding: .utf8)
                let error: APIError
                
                switch statusCode {
                case 401:
                    error = .unauthorized
                case 408:
                    error = .timeout
                default:
                    error = .serverError(statusCode: statusCode, message: errorMessage)
                }
                
                lastError = error
                return APIResponse(data: nil, statusCode: statusCode, headers: responseHeaders, error: error)
            }
            
            // Decode response
            do {
                let decodedData = try JSONDecoder().decode(T.self, from: data)
                return APIResponse(data: decodedData, statusCode: statusCode, headers: responseHeaders, error: nil)
            } catch {
                let apiError = APIError.decodingError(error)
                lastError = apiError
                return APIResponse(data: nil, statusCode: statusCode, headers: responseHeaders, error: apiError)
            }
            
        } catch {
            let apiError: APIError
            
            if let urlError = error as? URLError {
                switch urlError.code {
                case .timedOut:
                    apiError = .timeout
                case .notConnectedToInternet, .networkConnectionLost:
                    apiError = .networkError(urlError)
                default:
                    apiError = .networkError(urlError)
                }
            } else {
                apiError = .networkError(error)
            }
            
            lastError = apiError
            return APIResponse(data: nil, statusCode: -1, headers: [:], error: apiError)
        }
    }
    
    // MARK: - Convenience Methods
    
    func get<T: Codable>(
        endpoint: String,
        queryParams: [String: String] = [:],
        responseType: T.Type
    ) async -> APIResponse<T> {
        return await request(
            endpoint: endpoint,
            method: .GET,
            body: nil as String?,
            queryParams: queryParams,
            responseType: responseType
        )
    }
    
    func post<T: Codable, B: APIRequestBody>(
        endpoint: String,
        body: B,
        responseType: T.Type
    ) async -> APIResponse<T> {
        return await request(
            endpoint: endpoint,
            method: .POST,
            body: body,
            responseType: responseType
        )
    }
    
    func put<T: Codable, B: APIRequestBody>(
        endpoint: String,
        body: B,
        responseType: T.Type
    ) async -> APIResponse<T> {
        return await request(
            endpoint: endpoint,
            method: .PUT,
            body: body,
            responseType: responseType
        )
    }
    
    func delete<T: Codable>(
        endpoint: String,
        responseType: T.Type
    ) async -> APIResponse<T> {
        return await request(
            endpoint: endpoint,
            method: .DELETE,
            body: nil as String?,
            responseType: responseType
        )
    }
}

// MARK: - Usage Examples (for documentation)
/*
 使用示例：
 
 // 1. 创建配置
 let config = APIConfig(
     baseURL: "https://api.example.com",
     userID: "user123",
     timeout: 30.0,
     headers: ["Authorization": "Bearer token"]
 )
 
 // 2. 创建客户端
 let apiClient = APIClient(config: config)
 
 // 3. 定义数据模型
 struct User: Codable {
     let id: String
     let name: String
     let email: String
 }
 
 struct CreateUserRequest: Codable, APIRequestBody {
     let name: String
     let email: String
 }
 
 // 4. 使用 API
 
 // GET 请求
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
 
 // POST 请求
 let newUser = CreateUserRequest(name: "张三", email: "zhangsan@example.com")
 let createResponse = await apiClient.post(
     endpoint: "users",
     body: newUser,
     responseType: User.self
 )
 
 if createResponse.isSuccess, let user = createResponse.data {
     print("创建用户成功: \(user.name)")
 }
 
 // 在 SwiftUI 中使用
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
     }
 }
 */
