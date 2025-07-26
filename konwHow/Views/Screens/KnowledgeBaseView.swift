//
//  KnowledgeBaseView.swift
//  konwHow
//
//  Created by F1reC on 2025/7/25.
//

import SwiftUI
import Foundation

struct KnowledgeBaseView: View {
    @StateObject private var articleService = ArticleService()
    @State private var knowledgeItems: [KnowledgeItem] = []
    @Binding var showSidebar: Bool // 接收外部传入的侧边栏状态
    @State private var showConstructionStatus = false // 施工状态
    @State private var selectedArticleId: Int? // 选中的文章ID
    
    var body: some View {
        ZStack {
            // 主背景 - 白色
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 顶部渐变区域 - 包含Cody logo，扩展到灵动岛区域
                ZStack {
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color(red: 0.2, green: 0.8, blue: 0.4).opacity(0.4), location: 0.0), // 顶部30%透明度
                            .init(color: Color(red: 0.2, green: 0.8, blue: 0.4).opacity(0.0), location: 1.0)  // 底部0%透明度
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea(.all, edges: .top) // 确保渐变延伸到顶部安全区域
                    
                    // Cody logo - 显示在渐变区域内
                    VStack(spacing: 4) {
                        Text("Cody")
                            .font(.system(size: 32, weight: .black))
                            .italic()
                            .foregroundColor(.black)
                        
                        // 施工状态提示
                        if showConstructionStatus {
                            Text("知识库施工中......")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.black.opacity(0.6))
                                .scalShimmer()
                        }
                    }
                    .padding(.top, 0) // 增加顶部padding，避免与灵动岛重叠
                }
                .frame(height: 80) // 增加高度，确保有足够空间
                
                // 主内容区域 - 白色背景
                VStack(spacing: 0) {
                    // 内容区域 - 包括知识图谱、标签和卡片
                    ScrollView {
                        VStack(spacing: 16) {
                            // 知识图谱组件（使用Grape实现）
                            KnowledgeGraphView()
                                .frame(height: 250)
                            
                            // Tag筛选区域
                            TagFilterSection()
                                .environmentObject(articleService)
                            
                            // 卡片列表
                            if articleService.isLoading && !articleService.hasData {
                                // 首次加载状态
                                VStack(spacing: 16) {
                                    ProgressView()
                                        .scaleEffect(1.2)
                                    Text("加载中...")
                                        .foregroundColor(.gray)
                                        .font(.system(size: 16))
                                }
                                .frame(maxWidth: .infinity, minHeight: 150)
                            } else if let errorMessage = articleService.lastError {
                                // 错误状态
                                VStack(spacing: 16) {
                                    Image(systemName: "exclamationmark.triangle")
                                        .font(.system(size: 24))
                                        .foregroundColor(.orange)
                                    Text("加载失败")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    Text(errorMessage)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal)
                                    
                                    Button("重新加载") {
                                        Task {
                                            await articleService.refreshArticles()
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 6)
                                    .background(Color(red: 0.2, green: 0.8, blue: 0.4))
                                    .foregroundColor(.white)
                                    .cornerRadius(6)
                                }
                                .frame(maxWidth: .infinity, minHeight: 150)
                                .padding(.horizontal, 20)
                            } else {
                                // 知识卡片列表
                                LazyVStack(spacing: 8) {
                                    ForEach(articleService.articles) { article in
                                        CommunityCard(
                                            article: article, 
                                            showAuthor: false,
                                            onTap: {
                                                selectedArticleId = article.id
                                            }
                                        )
                                        .onAppear {
                                            // 当最后一个item出现时，自动加载更多
                                            if article.id == articleService.articles.last?.id && articleService.canLoadMore {
                                                Task {
                                                    await articleService.loadMoreArticles()
                                                }
                                            }
                                        }
                                    }
                                    
                                    // 底部加载指示器 - 只在有更多数据时显示
                                    if articleService.canLoadMore || (articleService.isLoading && articleService.currentPage > 1) {
                                        HStack {
                                            Spacer()
                                            ProgressView()
                                                .scaleEffect(0.8)
                                            Text("加载中...")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                            Spacer()
                                        }
                                        .padding(.vertical, 16)
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                        .padding(.top, 8)
                        .padding(.bottom, 120) // 增加底部间距，避免Tab栏遮挡
                    }
                }
                .background(Color.white) // 确保内容区域是白色背景
                
                Spacer()
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
                    .padding(.top, 20)
                    
                    Spacer()
                }
                Spacer()
            }
        }
        .task {
            await loadKnowledgeItems()
            await articleService.fetchUserTags()
        }
        .refreshable {
            await articleService.refreshArticles()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("RefreshKnowledgeBase"))) { _ in
            Task {
                await articleService.refreshArticles()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ShowConstructionStatus"))) { _ in
            showConstructionStatus = true
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("HideConstructionStatus"))) { _ in
            showConstructionStatus = false
        }
        .sheet(isPresented: Binding<Bool>(
            get: { selectedArticleId != nil },
            set: { if !$0 { selectedArticleId = nil } }
        )) {
            if let articleId = selectedArticleId {
                NavigationView {
                    ArticleDetailView(articleId: articleId)
                }
            }
        }
    }
    
    private func loadKnowledgeItems() async {
        await articleService.fetchMyArticles()
    }
}

#Preview {
    KnowledgeBaseView(showSidebar: .constant(false))
}

// MARK: - Tag Filter Section Component

struct TagFilterSection: View {
    @EnvironmentObject private var articleService: ArticleService
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 筛选按钮ScrollView
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    // "全部"按钮
                    FilterTagButton(
                        tagName: "全部",
                        isSelected: articleService.selectedTagId == nil,
                        onTap: {
                            Task {
                                await articleService.clearTagFilter()
                            }
                        }
                    )
                    
                    // 用户标签按钮
                    ForEach(articleService.userTags) { tag in
                        FilterTagButton(
                            tagName: tag.name,
                            isSelected: articleService.isTagSelected(tag.id),
                            onTap: {
                                Task {
                                    await articleService.selectTag(tag.id)
                                }
                            }
                        )
                    }
                }
                .padding(.leading, 20) // 只设置左侧padding
            }
        }
    }
}

// MARK: - Filter Tag Button Component

struct FilterTagButton: View {
    let tagName: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 2) {
                Text("#")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(isSelected ? Color.white : Color(red: 0.2, green: 0.6, blue: 0.3))
                
                Text(tagName)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isSelected ? Color.white : Color.black)
                    .lineLimit(1)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                isSelected ? 
                Color(red: 0.2, green: 0.8, blue: 0.4) : // 选中时深绿色
                Color.gray.opacity(0.08) // 未选中时浅灰色
            )
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
} 