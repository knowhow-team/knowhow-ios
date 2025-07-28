//
//  knowhowApp.swift
//  knowhow
//
//  Created by F1reC on 2025/7/25.
//

import SwiftUI

@main
struct knowhowApp: App {
    @StateObject private var userManager = UserManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(userManager)
                .onAppear {
                    initializeApp()
                }
        }
    }
    
    private func initializeApp() {
        // 应用启动时的初始化逻辑
        print("📱 应用启动 - 当前用户ID: \(userManager.userId)")
        
        // 如果需要，可以在这里进行用户认证检查
        // 或从服务器获取用户信息
        
        // 临时设置默认用户ID为 "1"
        if userManager.currentUserId.isEmpty {
            userManager.setUserId("1")
        }
    }
}
