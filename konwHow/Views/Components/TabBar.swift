//
//  TabBar.swift
//  konwHow
//
//  Created by F1reC on 2025/7/25.
//

import SwiftUI

struct TabBar: View {
    @Binding var selectedTab: Int
    
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
            
            // 中央按钮 - 减少偏移避免遮挡
            Button(action: {
                // 中央按钮动作
            }) {
                ZStack {
                    Circle()
                        .fill(Color(red: 0.2, green: 0.8, blue: 0.4))
                        .frame(width: 64, height: 64)
                        .shadow(color: Color(red: 0.2, green: 0.8, blue: 0.4).opacity(0.25), radius: 12, x: 0, y: 6)
                    
                    // 使用垂直线条图标来模拟音频波形 - 调整尺寸
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
            .offset(y: -16) // 减少偏移量，从-24改为-16
            
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
        .padding(.horizontal, 50)
        .padding(.vertical, 12)
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: -4)
    }
}

#Preview {
    TabBar(selectedTab: .constant(0))
} 