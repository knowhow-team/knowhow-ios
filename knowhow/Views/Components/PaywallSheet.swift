//
//  PaywallSheet.swift
//  knowhow
//
//  Created by F1reC on 2025/7/26.
//

import SwiftUI

// MARK: - Paywall Sheet Component

struct PaywallSheet: View {
    let username: String
    let userAvatarUrl: String?
    let articleTitle: String
    let onContinue: () -> Void
    let onDismiss: () -> Void
    
    // MARK: - 主题色
    private let themeColor = Color(red: 0.2, green: 0.8, blue: 0.4)
    private let buttonColor = Color(red: 82/255, green: 208/255, blue: 119/255)
    private let backgroundColor = Color(red: 0.96, green: 0.98, blue: 0.96)
    
    var body: some View {
        ZStack {
            // 背景
            backgroundColor
                .ignoresSafeArea(.all)
            
            VStack(spacing: 0) {
                // 顶部关闭按钮
                topBar
                
                // 主要内容
                ScrollView {
                    VStack(spacing: 32) {
                        // 用户信息区域
                        userInfoSection
                        
                        // 订阅说明区域
                        subscriptionInfoSection
                        
                        
                        // 行为按钮区域
                        actionButtonsSection
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 20)
                }
                
                Spacer()
            }
        }
    }
    
    // MARK: - Subviews
    
    private var topBar: some View {
        HStack {
            Spacer()
            
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.gray)
                    .frame(width: 32, height: 32)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
            }
        }
        .padding(.top, 20)
        .padding(.horizontal, 24)
    }
    
    private var userInfoSection: some View {
        VStack(spacing: 16) {
            // 用户头像
            ZStack {
                Circle()
                    .fill(themeColor.gradient)
                    .frame(width: 80, height: 80)
                
                if let avatarUrl = userAvatarUrl, !avatarUrl.isEmpty {
                    // 如果有头像URL，使用网络图片
                    AsyncImage(url: URL(string: avatarUrl)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                    } placeholder: {
                        // 加载中显示首字母
                        Text(String(username.prefix(1)).uppercased())
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                    }
                } else {
                    // 没有头像URL，显示首字母
                    Text(String(username.prefix(1)).uppercased())
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .shadow(color: themeColor.opacity(0.3), radius: 8, x: 0, y: 4)
            
            // 用户名
            Text(username)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.black)
            
            // 订阅状态标识
            HStack(spacing: 8) {
                Image(systemName: "star.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.orange)
                
                Text("专业创作者")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.orange)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.orange.opacity(0.1))
            .cornerRadius(12)
        }
    }
    
    private var subscriptionInfoSection: some View {
        VStack(spacing: 20) {
            // 主标题
            Text("解锁\(username)的知识库")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
            
            // 描述文本
            Text("访问专业创作者的深度内容和独家见解")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
            
            // 特权列表
            VStack(spacing: 16) {
                FeatureRow(
                    icon: "doc.richtext.fill",
                    title: "深度文章",
                    description: "获取完整的专业内容和分析"
                )
                
                FeatureRow(
                    icon: "network",
                    title: "知识图谱",
                    description: "探索作者的知识网络和思维导图"
                )
                
                FeatureRow(
                    icon: "sparkles",
                    title: "独家见解",
                    description: "访问作者的私人笔记和想法"
                )
            }
            .padding(.top, 8)
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    
    private var actionButtonsSection: some View {
        VStack(spacing: 16) {
            // 继续访问按钮
            Button(action: onContinue) {
                HStack {
                    Text("继续访问")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Image(systemName: "arrow.right")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .background(buttonColor.gradient)
                .cornerRadius(12)
                .shadow(color: buttonColor.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            
            // 次要按钮 - 了解更多
            Button(action: {
                // TODO: 实现了解更多功能
            }) {
                Text("了解订阅详情")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(themeColor)
                    .padding(.vertical, 12)
            }
        }
    }
}

// MARK: - Feature Row Component

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    private let themeColor = Color(red: 0.2, green: 0.8, blue: 0.4)
    
    var body: some View {
        HStack(spacing: 16) {
            // 图标
            ZStack {
                Circle()
                    .fill(themeColor.opacity(0.1))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(themeColor)
            }
            
            // 文本内容
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .lineLimit(nil)
            }
            
            Spacer()
        }
    }
}

// MARK: - Preview

#Preview {
    PaywallSheet(
        username: "熔熔",
        userAvatarUrl: "https://example.com/avatar.jpg",
        articleTitle: "小米汽车SU7、雷军与北京：科技巨头的跨界之作",
        onContinue: {
            print("继续访问")
        },
        onDismiss: {
            print("关闭付费墙")
        }
    )
}
