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
            // 背景色 - 绿色渐变，与主页面顶部一致
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.2, green: 0.8, blue: 0.4), // 较深的绿色
                    Color(red: 0.96, green: 0.98, blue: 0.96) // 较浅的绿色
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea(.all) // 忽略所有安全区域，覆盖整个屏幕
            
            VStack(spacing: 0) {
                // 顶部标题区域
                VStack(spacing: 20) {
                   
                    
                    // 装饰性分隔线
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.black.opacity(0.0),
                                    Color.black.opacity(0.2),
                                    Color.black.opacity(0.0)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: 1)
                        .padding(.horizontal, 40)
                        .padding(.top, 100) // 增加顶部间距，避开灵动岛区域
                }
                
                // 主内容区域 - 融入绿色背景
                VStack(spacing: 0) {
                    Spacer().frame(height: 40)
                    
                    // 原始记录 - 与tag样式保持一致
                    Button(action: {
                        showVoiceRecord = true
                    }) {
                        HStack(spacing: 16) {
                            Text("原始记录")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.black.opacity(0.8))
                            
                            Spacer()
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 24)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(0.4))
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal, 20)
                    
                    Spacer().frame(height: 32)
                    
                    // 标签分组
                    VStack(alignment: .leading, spacing: 16) {
                        Text("知识分类")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.black.opacity(0.7))
                            .padding(.leading, 24)
                        
                        VStack(spacing: 12) {
                            ForEach(["#tag 1", "#tag 2", "#tag 3"], id: \.self) { tag in
                                HStack(spacing: 16) {
                                   
                                    
                                    Text(tag)
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundColor(.black.opacity(0.8))
                                    
                                    Spacer()
                                }
                                .padding(.vertical, 12)
                                .padding(.horizontal, 24)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.white.opacity(0.4))
                                )
                                .onTapGesture {
                                    // 处理标签点击
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    Spacer()
                    
                    // 底部安全区域占位
                    Color.clear
                        .frame(height: 100) // 为Tab栏预留空间
                }
            }
        }
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