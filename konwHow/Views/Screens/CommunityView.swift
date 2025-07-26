//
//  CommunityView.swift
//  konwHow
//
//  Created by F1reC on 2025/7/25.
//

import SwiftUI

struct CommunityView: View {
    @State private var knowledgeItems: [KnowledgeItem] = []
    
    var body: some View {
        ZStack {
            // 背景色 - 白色，与设计稿一致
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
               
                
                // 主内容区域
                ScrollView {
                    VStack(spacing: 8) {
                        // 知识卡片列表
                        LazyVStack(spacing: 8) {
                            ForEach(knowledgeItems) { item in
                                KnowledgeCard(item: item)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 120) // 避免Tab栏遮挡
                }
                
                Spacer()
            }
        }
        .onAppear {
            loadKnowledgeItems()
        }
    }
    
    private func loadKnowledgeItems() {
        // 模拟数据 - 与知识库界面相同的内容
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
    CommunityView()
} 