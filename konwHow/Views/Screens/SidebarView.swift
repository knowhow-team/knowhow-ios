//
//  SidebarView.swift
//  konwHow
//
//  Created by F1reC on 2025/7/25.
//

import SwiftUI

struct SidebarView: View {
    @Binding var isPresented: Bool
    @State private var showVoiceRecord = false
    
    var body: some View {
        ZStack {
            // 背景色 - 白色，与主页面一致
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 顶部区域
                HStack {
                    Spacer()
                    
                    // 关闭按钮
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isPresented = false
                        }
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.black)
                            .frame(width: 32, height: 32)
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(8)
                            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                // 主内容区域 - 白色背景，与主页面一致
                VStack(spacing: 16) {
                    // UI组件信息卡片 - 白色背景，与知识卡片一致
                    VStack(spacing: 12) {
                        // 原始语音记录 - 可点击
                        Button(action: {
                            showVoiceRecord = true
                        }) {
                            Text("原始语音记录")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.white)
                                .cornerRadius(8)
                                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 1)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Text("#tag 1")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.white)
                            .cornerRadius(8)
                            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 1)
                        
                        Text("#tag 2")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.white)
                            .cornerRadius(8)
                            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 1)
                        
                        Text("#tag 3")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.white)
                            .cornerRadius(8)
                            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 1)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 40)
                    
                    Spacer()
                }
            }
        }
        .transition(.move(edge: .leading))
        .fullScreenCover(isPresented: $showVoiceRecord) {
            VoiceRecordView()
        }
    }
}

// 扩展View以支持部分圆角
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

#Preview {
    SidebarView(isPresented: .constant(true))
} 