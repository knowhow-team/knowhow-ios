//
//  KnowledgeBaseView.swift
//  konwHow
//
//  Created by F1reC on 2025/7/25.
//

import SwiftUI

struct KnowledgeBaseView: View {
    @State private var knowledgeItems: [KnowledgeItem] = []
    @State private var showSidebar = false
    
    var body: some View {
        ZStack {
            // 背景色 - 非常浅的绿色
            Color(red: 0.96, green: 0.98, blue: 0.96)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 顶部区域 - 精确匹配设计图
                VStack(spacing: 8) {
                    // Cody 标题 - 更大更粗的字体
                    Text("Cody")
                        .font(.system(size: 42, weight: .black))
                        .italic()
                        .foregroundColor(.black)
                }
                .padding(.top, 40)
                .padding(.bottom, 20)
                
                // 内容区域 - 包括知识图谱、标签和卡片
                ScrollView {
                    VStack(spacing: 16) {
                        // 知识图谱组件（临时Canvas版本）
                        CanvasKnowledgeGraphView()
                            .frame(height: 250)
                        
                        // #adx 标签 - 左对齐，与卡片同层级
                        HStack {
                            TagView(text: "#adx")
                            
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        
                        // 卡片列表
                        LazyVStack(spacing: 8) {
                            ForEach(knowledgeItems) { item in
                                KnowledgeCard(item: item)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 120) // 增加底部间距，避免Tab栏遮挡
                }
                
                // 移除固定高度的Spacer，改用padding
            }
            
            // 侧边栏按钮 - 左上角
            VStack {
                HStack {
                    SidebarButton(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showSidebar = true
                        }
                    })
                    .padding(.leading, 20)
                    .padding(.top, 60)
                    
                    Spacer()
                }
                Spacer()
            }
        }
        .onAppear {
            loadKnowledgeItems()
        }
        .overlay(
            // 侧边栏覆盖层
            Group {
                if showSidebar {
                    SidebarView(isPresented: $showSidebar)
                        .zIndex(1)
                }
            }
        )
    }
    
    private func loadKnowledgeItems() {
        // 模拟数据
        knowledgeItems = [
            KnowledgeItem(
                title: "AdventureX",
                description: "adx 是中国最大的一场黑客松，2025年有871人参加，参与人数众多，氛围热烈！",
                category: "Adv"
            ),
            KnowledgeItem(
                title: "AdventureX",
                description: "adx 是中国最大的一场黑客松，2025年有871人参加，参与人数众多，氛围热烈！",
                category: "Adv"
            ),
            KnowledgeItem(
                title: "AdventureX",
                description: "adx 是中国最大的一场黑客松，2025年有871人参加，参与人数众多，氛围热烈！",
                category: "Adv"
            ),
            KnowledgeItem(
                title: "AdventureX",
                description: "adx 是中国最大的一场黑客松，2025年有871人参加，参与人数众多，氛围热烈！",
                category: "Adv"
            )
        ]
    }
}

#Preview {
    KnowledgeBaseView()
} 