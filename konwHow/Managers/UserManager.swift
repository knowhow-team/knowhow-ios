//
//  UserManager.swift
//  konwHow
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
    
    /// 清除所有用户数据
    func clearUserData() {
        UserDefaults.standard.removeObject(forKey: userIdKey)
        UserDefaults.standard.removeObject(forKey: isLoggedInKey)
        currentUserId = "1"
        isLoggedIn = false
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