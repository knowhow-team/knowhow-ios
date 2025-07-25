//
//  SidebarView.swift
//  konwHow
//
//  Created by F1reC on 2025/7/25.
//

import SwiftUI

struct SidebarView: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack {
            // 背景色 - 浅灰色
            Color(red: 0.95, green: 0.95, blue: 0.95)
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
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                // 主内容区域 - 浅绿色背景
                ZStack {
                    Color(red: 0.96, green: 0.98, blue: 0.96)
                        .cornerRadius(20, corners: [.bottomLeft, .bottomRight])
                    
                    VStack(spacing: 16) {
                        // UI组件信息卡片
                        VStack(spacing: 12) {
                            Text("原始语音记录")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color(red: 0.9, green: 0.9, blue: 0.9))
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                            
                            Text("#tag 1")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color(red: 0.9, green: 0.9, blue: 0.9))
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                            
                            Text("#tag 2")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color(red: 0.9, green: 0.9, blue: 0.9))
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                            
                            Text("#tag 3")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color(red: 0.9, green: 0.9, blue: 0.9))
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 40)
                        
                        Spacer()
                    }
                }
            }
        }
        .transition(.move(edge: .leading))
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