//
//  UserDebugView.swift
//  konwHow
//
//  Created by F1reC on 2025/7/26.
//

import SwiftUI

struct UserDebugView: View {
    @EnvironmentObject var userManager: UserManager
    @State private var newUserId: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("用户调试信息")
                .font(.headline)
                .padding(.bottom, 8)
            
            // 当前用户信息
            Group {
                HStack {
                    Text("当前用户ID:")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text(userManager.currentUserId)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Spacer()
                }
                
                HStack {
                    Text("登录状态:")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text(userManager.isLoggedIn ? "已登录" : "未登录")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(userManager.isLoggedIn ? .green : .red)
                    Spacer()
                }
            }
            
            Divider()
            
            // 用户ID设置
            VStack(alignment: .leading, spacing: 8) {
                Text("设置用户ID")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                HStack {
                    TextField("输入新的用户ID", text: $newUserId)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button("设置") {
                        if !newUserId.trimmingCharacters(in: .whitespaces).isEmpty {
                            userManager.setUserId(newUserId.trimmingCharacters(in: .whitespaces))
                            newUserId = ""
                        }
                    }
                    .disabled(newUserId.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            
            // 快捷设置按钮
            HStack(spacing: 12) {
                Button("用户1") {
                    userManager.setUserId("1")
                }
                .buttonStyle(.bordered)
                
                Button("用户2") {
                    userManager.setUserId("2")
                }
                .buttonStyle(.bordered)
                
                Button("用户3") {
                    userManager.setUserId("3")
                }
                .buttonStyle(.bordered)
                
                Spacer()
            }
            
            Divider()
            
            // 操作按钮
            HStack(spacing: 12) {
                Button("登出") {
                    userManager.logout()
                }
                .buttonStyle(.bordered)
                .foregroundColor(.orange)
                
                Button("清除数据") {
                    userManager.clearUserData()
                }
                .buttonStyle(.bordered)
                .foregroundColor(.red)
                
                Spacer()
            }
        }
        .padding(16)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    UserDebugView()
        .environmentObject(UserManager.shared)
        .padding()
}