//
//  ContentView.swift
//  konwHow
//
//  Created by F1reC on 2025/7/25.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
            // 主内容区域
            VStack(spacing: 0) {
                // 根据选中的tab显示不同内容
                if selectedTab == 0 {
                    KnowledgeBaseView(  )
                } else {
                    CommunityView()
                }
                
                // 底部导航栏
                TabBar(selectedTab: $selectedTab)
            }
        }
    }
}

#Preview {
    ContentView()
}
