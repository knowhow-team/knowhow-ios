//
//  ArticleDetailView.swift
//  knowhow
//
//  Created by F1reC on 2025/7/26.
//

import SwiftUI
import MarkdownView

// MARK: - Article Detail View

struct ArticleDetailView: View {
    let articleId: Int
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var apiClient: APIClient
    @State private var articleDetail: ArticleDetail?
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var selectedRecommendationId: Int? // 选中的推荐文章ID
    @State private var selectedAuthor: ArticleAuthor? // 选中的作者信息
    
    init(articleId: Int) {
        self.articleId = articleId
        
        let config = APIConfig(
            baseURL: "http://***REMOVED***/api",
            userID: UserManager.shared.userId,
            timeout: 30.0
        )
        self._apiClient = StateObject(wrappedValue: APIClient(config: config))
    }
    
    var body: some View {
        contentView
            .task {
                await loadArticleDetail()
            }
            .sheet(isPresented: Binding<Bool>(
                get: { selectedAuthor != nil },
                set: { if !$0 { selectedAuthor = nil } }
            )) {
                if let author = selectedAuthor {
                    NavigationView {
                        UserKnowledgeBaseView(
                            userId: "\(author.id)",
                            username: author.username
                        )
                    }
                }
            }
    }
    
    private var contentView: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            if isLoading {
                loadingView
            } else if let errorMessage = errorMessage {
                errorView(message: errorMessage)
            } else if let article = articleDetail {
                articleContentView(article: article)
            }
        }
        .navigationBarHidden(true)
    }
    
    // MARK: - Subviews
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("加载中...")
                .foregroundColor(.gray)
                .font(.system(size: 16))
        }
    }
    
    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 24))
                .foregroundColor(.orange)
            Text("加载失败")
                .font(.headline)
                .foregroundColor(.primary)
            Text(message)
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("重新加载") {
                Task {
                    await loadArticleDetail()
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
            .background(Color(red: 0.2, green: 0.8, blue: 0.4))
            .foregroundColor(.white)
            .cornerRadius(6)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func articleContentView(article: ArticleDetail) -> some View {
        VStack(spacing: 0) {
            // 顶部导航栏
            headerView
            
            // 滚动内容
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // 文章标题
                    titleSection(article: article)
                        .padding(.bottom, 20)
                    
                    // 作者信息（Medium风格）
                    if let author = article.author {
                        authorSection(author: author, article: article)
                            .padding(.bottom, 20)
                    }
                    
                    // 文章摘要
                    summarySection(article: article)
                        .padding(.bottom, 16)
                    
                    // 标签
                    if !article.tags.isEmpty {
                        tagsSection(article: article)
                            .padding(.bottom, 24)
                    }
                    
                    // 文章正文
                    contentSection(article: article)
                        .padding(.bottom, 24)
                    
                    // 推荐文章
                    if !article.recommendations.isEmpty {
                        recommendationsSection(recommendations: article.recommendations)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
    }
    
    private var headerView: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.black)
                    .frame(width: 44, height: 44)
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(8)
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 16)
    }
    
    private func titleSection(article: ArticleDetail) -> some View {
        Text(article.title)
            .font(.system(size: 28, weight: .bold))
            .foregroundColor(.black)
            .lineLimit(nil)
            .fixedSize(horizontal: false, vertical: true)
    }
    
    private func summarySection(article: ArticleDetail) -> some View {
        Text(article.summary.processCitationReferences())
            .font(.system(size: 18, weight: .regular))
            .foregroundColor(.gray)
            .lineLimit(nil)
            .fixedSize(horizontal: false, vertical: true)
    }
    
    private func authorSection(author: ArticleAuthor, article: ArticleDetail) -> some View {
        HStack(spacing: 12) {
            // 头像 - 添加点击交互
            Button(action: {
                selectedAuthor = author
            }) {
                AsyncImage(url: URL(string: author.avatarUrl)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            Text(String(author.username.prefix(1)))
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.gray)
                        )
                }
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color(red: 0.2, green: 0.8, blue: 0.4).opacity(0.3), lineWidth: 2)
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            // 用户名 - 也添加点击交互
            Button(action: {
                selectedAuthor = author
            }) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(author.username)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.black)
                    
                    Text(article.formattedUpdatedDate)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
            
            // 访问指示图标
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.gray.opacity(0.6))
        }
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.clear)
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedAuthor = author
                }
        )
    }
    
    private func contentSection(article: ArticleDetail) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // 分隔线
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 1)
                .padding(.vertical, 8)
            
            // Markdown内容渲染（处理引用标识符）
            MarkdownView(article.content.processCitationReferences())
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(.black)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    private func tagsSection(article: ArticleDetail) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(article.tags) { tag in
                    ArticleDetailTagView(tagName: tag.name)
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.horizontal, -20) // 抵消外层padding，让滚动区域完整
    }
    
    private func recommendationsSection(recommendations: [Article]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 1)
                .padding(.vertical, 8)
            
            Text("本文提及了...")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.black)
            
            LazyVStack(spacing: 12) {
                ForEach(recommendations) { article in
                    ZStack {
                        // 隐藏的 NavigationLink
                        NavigationLink(
                            destination: ArticleDetailView(articleId: article.id),
                            tag: article.id,
                            selection: $selectedRecommendationId
                        ) {
                            EmptyView()
                        }
                        .hidden()
                        
                        // 纯净的 CommunityCard，没有任何样式影响
                        CommunityCard(
                            article: article, 
                            showAuthor: false,
                            onTap: {
                                selectedRecommendationId = article.id
                            }
                        )
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func parseMarkdownContent(_ content: String) -> String {
        // 简单的Markdown解析，去掉标记符号
        return content
            .replacingOccurrences(of: "# ", with: "")
            .replacingOccurrences(of: "## ", with: "")
            .replacingOccurrences(of: "### ", with: "")
            .replacingOccurrences(of: "**", with: "")
            .replacingOccurrences(of: "__", with: "")
            .replacingOccurrences(of: "*", with: "")
            .replacingOccurrences(of: "_", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    @MainActor
    private func loadArticleDetail() async {
        isLoading = true
        errorMessage = nil
        
        let response = await apiClient.get(
            endpoint: "v1/articles/\(articleId)",
            responseType: ArticleDetailResponse.self
        )
        
        isLoading = false
        
        if response.isSuccess, let data = response.data {
            articleDetail = data.article
            print("✅ 文章详情加载成功: \(data.article.title)")
        } else if let error = response.error {
            errorMessage = error.localizedDescription
            print("❌ 文章详情加载失败: \(error.localizedDescription)")
        }
    }
}

// MARK: - Article Detail Tag View Component

struct ArticleDetailTagView: View {
    let tagName: String
    
    var body: some View {
        HStack(spacing: 0) {
            Text("#")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(red: 0.2, green: 0.6, blue: 0.3)) // 深绿色
            
            Text(tagName)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.black)
                .lineLimit(1)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Color.gray.opacity(0.08))
        .cornerRadius(6)
    }
}

// MARK: - Preview

#Preview {
    NavigationView {
        ArticleDetailView(articleId: 15)
    }
}
