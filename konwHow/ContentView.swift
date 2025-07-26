//
//  ContentView.swift
//  konwHow
//
//  Created by F1reC on 2025/7/25.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var showSidebar = false // 侧边栏状态提升到这里
    
    var body: some View {
        ZStack {
            // 主内容区域
            VStack(spacing: 0) {
                // 根据选中的tab显示不同内容
                if selectedTab == 0 {
                    KnowledgeBaseView(showSidebar: $showSidebar) // 传递侧边栏状态
                } else {
                    CommunityView()
                }
                
                // 底部导航栏
                TabBar(selectedTab: $selectedTab)
            }
            
            // 侧边栏覆盖层 - 在最顶层，可以覆盖Tab栏
            if showSidebar {
                GeometryReader { geometry in
                    HStack(spacing: 0) {
                        // 侧边栏内容 - 占2/3屏幕宽度，覆盖整个屏幕高度
                        SidebarView(isPresented: $showSidebar)
                            .frame(width: geometry.size.width * 2/3)
                            .clipped() // 确保内容不会溢出
                        
                        // 右侧透明区域 - 占1/3屏幕宽度，点击可关闭侧边栏
                        Rectangle()
                            .fill(Color.clear)
                            .contentShape(Rectangle()) // 确保透明区域可以响应点击
                            .frame(width: geometry.size.width * 1/3)
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    showSidebar = false
                                }
                            }
                    }
                }
                .ignoresSafeArea(.all) // 覆盖整个屏幕包括安全区域
                .transition(.move(edge: .leading)) // 滑入动画
                .zIndex(1000) // 最高层级
            }
        }
    }
}

#Preview {
    ContentView()
}
