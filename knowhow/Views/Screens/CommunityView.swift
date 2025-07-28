//
//  CommunityView.swift
//  knowhow
//
//  Created by F1reC on 2025/7/25.
//

import SwiftUI

struct CommunityView: View {
    @StateObject private var articleService = ArticleService()
    @State private var selectedArticleId: Int? // 选中的文章ID
    
    var body: some View {
        ZStack {
            // 背景色 - 白色，与设计稿一致
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 顶部标题区域
                HStack {
                    Text("社区推荐")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 8)
                
                // 主内容区域
                ScrollView {
                    VStack(spacing: 8) {
                        if articleService.isLoading && !articleService.hasData {
                            // 首次加载状态
                            VStack(spacing: 16) {
                                ProgressView()
                                    .scaleEffect(1.2)
                                Text("加载推荐文章...")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 16))
                            }
                            .frame(maxWidth: .infinity, minHeight: 200)
                        } else if let errorMessage = articleService.lastError {
                            // 错误状态
                            VStack(spacing: 16) {
                                Image(systemName: "exclamationmark.triangle")
                                    .font(.system(size: 32))
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
                                        await articleService.refreshRecommendedArticles()
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 8)
                                .background(Color(red: 0.2, green: 0.8, blue: 0.4))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            }
                            .frame(maxWidth: .infinity, minHeight: 200)
                        } else if articleService.articles.isEmpty {
                            // 空数据状态
                            VStack(spacing: 16) {
                                Image(systemName: "doc.text")
                                    .font(.system(size: 32))
                                    .foregroundColor(.gray)
                                Text("暂无推荐文章")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Text("目前还没有推荐的文章，请稍后再来看看！")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                            .frame(maxWidth: .infinity, minHeight: 200)
                        } else {
                            // 推荐文章列表
                            
                            LazyVStack(spacing: 12) {
                                ForEach(articleService.articles) { article in
                                    CommunityCard(
                                        article: article,
                                        onTap: {
                                            selectedArticleId = article.id
                                        }
                                    )
                                    .onAppear {
                                        if article.id == articleService.articles.last?.id && articleService.canLoadMore {
                                            Task {
                                                await articleService.loadMoreRecommendedArticles()
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
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 120) // 避免Tab栏遮挡
                }
                
                Spacer()
            }
        }
        .task {
            await loadRecommendedArticles()
        }
        .refreshable {
            await articleService.refreshRecommendedArticles()
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
    
    private func loadRecommendedArticles() async {
        await articleService.fetchRecommendedArticles()
    }
}

#Preview {
    CommunityView()
} 
