//
//  UserManager.swift
//  knowhow
//
//  Created by F1reC on 2025/7/26.
//

import Foundation
import SwiftUI

// MARK: - User Manager
@MainActor
class UserManager: ObservableObject {
    // 单例实例
    static let shared = UserManager()
    
    // 用户信息
    @Published var currentUserId: String = "1"
    @Published var isLoggedIn: Bool = true
    
    // UserDefaults 键值
    private let userIdKey = "currentUserId"
    private let isLoggedInKey = "isLoggedIn"
    
    private init() {
        loadUserData()
    }
    
    // MARK: - 用户数据管理
    
    /// 从 UserDefaults 加载用户数据
    private func loadUserData() {
        if let savedUserId = UserDefaults.standard.object(forKey: userIdKey) as? String {
            currentUserId = savedUserId
        } else {
            // 如果没有保存的用户ID，使用默认值 "1"
            currentUserId = "1"
            saveUserData()
        }
        
        isLoggedIn = UserDefaults.standard.bool(forKey: isLoggedInKey)
        if UserDefaults.standard.object(forKey: isLoggedInKey) == nil {
            // 首次启动，默认为已登录状态
            isLoggedIn = true
            saveUserData()
        }
    }
    
    /// 保存用户数据到 UserDefaults
    private func saveUserData() {
        UserDefaults.standard.set(currentUserId, forKey: userIdKey)
        UserDefaults.standard.set(isLoggedIn, forKey: isLoggedInKey)
    }
    
    /// 设置用户ID
    func setUserId(_ userId: String) {
        currentUserId = userId
        isLoggedIn = true
        saveUserData()
    }
    
    /// 登出用户
    func logout() {
        isLoggedIn = false
        saveUserData()
    }
    
    struct ResetDataResponse: Codable {
        let demoData: DemoData
        let message: String
        let resetStats: ResetStats
        
        enum CodingKeys: String, CodingKey {
            case demoData = "demo_data"
            case message
            case resetStats = "reset_stats"
        }
    }
    
    struct DemoData: Codable {
        let articlesCount: Int
        let relationshipsCount: Int
        let tagsCount: Int
        let userId: Int
        let username: String
        
        enum CodingKeys: String, CodingKey {
            case articlesCount = "articles_count"
            case relationshipsCount = "relationships_count"
            case tagsCount = "tags_count"
            case userId = "user_id"
            case username
        }
    }

    struct ResetStats: Codable {
        let createdArticles: Int
        let createdRelationships: Int
        let createdTags: Int
        let deletedArticles: Int
        let deletedRecords: Int
        let deletedTags: Int
        let deletedTasks: Int
        
        enum CodingKeys: String, CodingKey {
            case createdArticles = "created_articles"
            case createdRelationships = "created_relationships"
            case createdTags = "created_tags"
            case deletedArticles = "deleted_articles"
            case deletedRecords = "deleted_records"
            case deletedTags = "deleted_tags"
            case deletedTasks = "deleted_tasks"
        }
    }
    
    /// 清除该用户数据
    func clearUserData() async{
        let user_id = Int(currentUserId)!
        
        // 配置 API 客户端
        let config = APIConfig(
            baseURL: "http://***REMOVED***/api",
            userID: currentUserId,
            timeout: 30.0,
            headers: [
                "Content-Type": "application/json",
                "Accept": "application/json"
            ]
        )
        let apiClient = APIClient(config: config)
        
        let queryParams: [String: Any] = [:]
        
        let response = await apiClient.delete(
            endpoint: "v1/articles/reset-data/\(user_id)",
            responseType: ResetDataResponse.self
        )
        
        // 简单处理 - 假设能执行到这里就是成功了
        DispatchQueue.main.async {
            UIRefreshControl()
        }
        
        print("用户数据清除成功")
    }


    
    // MARK: - 便捷方法
    
    /// 获取当前用户ID（非空）
    var userId: String {
        return currentUserId.isEmpty ? "1" : currentUserId
    }
    
    /// 检查是否有有效用户ID
    var hasValidUserId: Bool {
        return !currentUserId.isEmpty && isLoggedIn
    }
}

// MARK: - Environment Key
struct UserManagerKey: EnvironmentKey {
    static let defaultValue = UserManager.shared
}

extension EnvironmentValues {
    var userManager: UserManager {
        get { self[UserManagerKey.self] }
        set { self[UserManagerKey.self] = newValue }
    }
}
