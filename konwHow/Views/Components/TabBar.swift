//
//  TabBar.swift
//  konwHow
//
//  Created by F1reC on 2025/7/25.
//

import SwiftUI

struct TabBar: View {
    @Binding var selectedTab: Int
    @State private var showRecording = false
    
    var body: some View {
        HStack {
            // 知识库 Tab - 精确匹配设计图
            VStack(spacing: 3) {
                Image(systemName: "doc.text.fill")
                    .font(.system(size: 24))
                    .foregroundColor(selectedTab == 0 ? Color(red: 0.2, green: 0.8, blue: 0.4) : Color.gray.opacity(0.5))
                Text("知识库")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(selectedTab == 0 ? Color(red: 0.2, green: 0.8, blue: 0.4) : Color.gray.opacity(0.5))
            }
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.2)) {
                    selectedTab = 0
                }
            }
            
            Spacer()
            
            // 中央按钮 - 录音功能
            Button(action: {
                showRecording = true
            }) {
                ZStack {
                    Circle()
                        .fill(Color(red: 0.2, green: 0.8, blue: 0.4))
                        .frame(width: 64, height: 64)
                        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 3) // 更轻微的阴影
                    
                    // 使用垂直线条图标来模拟音频波形 - 精确匹配设计图
                    HStack(spacing: 2.5) {
                        Rectangle()
                            .fill(Color.white)
                            .frame(width: 2.5, height: 10)
                        Rectangle()
                            .fill(Color.white)
                            .frame(width: 2.5, height: 18)
                        Rectangle()
                            .fill(Color.white)
                            .frame(width: 2.5, height: 14)
                        Rectangle()
                            .fill(Color.white)
                            .frame(width: 2.5, height: 22)
                        Rectangle()
                            .fill(Color.white)
                            .frame(width: 2.5, height: 16)
                    }
                }
            }
            .offset(y: -24) // 增加浮动效果，让按钮更明显地浮在Tab栏上方
            
            Spacer()
            
            // 社区 Tab - 精确匹配设计图
            VStack(spacing: 3) {
                Image(systemName: "person.2.fill")
                    .font(.system(size: 24))
                    .foregroundColor(selectedTab == 1 ? Color(red: 0.2, green: 0.8, blue: 0.4) : Color.gray.opacity(0.5))
                Text("社区")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(selectedTab == 1 ? Color(red: 0.2, green: 0.8, blue: 0.4) : Color.gray.opacity(0.5))
            }
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.2)) {
                    selectedTab = 1
                }
            }
        }
        .padding(.horizontal, 75) // 进一步减少水平边距，让tab更靠近中心
        .padding(.vertical, 0) // 恢复合适的垂直padding
        .background(Color.white) // 使用纯白色背景，无任何边框效果
        .fullScreenCover(isPresented: $showRecording) {
            RecordingView()
        }
    }
}

#Preview {
    TabBar(selectedTab: .constant(0))
} 