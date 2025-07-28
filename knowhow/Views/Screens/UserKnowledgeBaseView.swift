//
//  UserKnowledgeBaseView.swift
//  knowhow
//
//  Created by F1reC on 2025/7/26.
//

import SwiftUI
import Foundation

struct UserKnowledgeBaseView: View {
    let userId: String
    let username: String
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var articleService = ArticleService()
    @State private var selectedArticleId: Int?
    
    // MARK: - User Info States
    @State private var userInfo: User?
    @State private var isLoadingUserInfo = true
    
    // MARK: - Paywall States
    @State private var showPaywall = false
    @State private var paywallArticleId: Int?
    @State private var paywallArticleTitle: String = ""
    
    // API Client
    @StateObject private var apiClient: APIClient
    
    init(userId: String, username: String) {
        self.userId = userId
        self.username = username
        
        let config = APIConfig(
            baseURL: "http://***REMOVED***/api",
            userID: UserManager.shared.userId,
            timeout: 30.0
        )
        self._apiClient = StateObject(wrappedValue: APIClient(config: config))
    }
    
    var body: some View {
        ZStack {
            // 主背景 - 白色
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 自定义顶部导航栏
                customNavigationBar
                
                // 主内容区域
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 16) {
                            // 知识图谱组件（使用真实API数据）
                            ArticleKnowledgeGraphView()
                                .environmentObject(articleService)
                                .frame(height: 400)
                            
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
                                    ForEach(articleService.articles.sorted { article1, article2 in
                                        // 按 finishedAt 降序排列（最新的在前）
                                        (article1.finishedAt ?? "") > (article2.finishedAt ?? "")
                                    }) { article in
                                        CommunityCard(
                                            article: article,
                                            showAuthor: false,
                                            onTap: {
                                                selectedArticleId = article.id
                                            }
                                        )
                                        .onAppear {
                                            if article.id == articleService.articles.last?.id && articleService.canLoadMore {
                                                Task {
                                                    await articleService.loadMoreArticles()
                                                }
                                            }
                                        }
                                    }
                                    
                                    // 底部加载指示器
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
                        .padding(.bottom, 60)
                    }
                }
                .background(Color.white)
                
                Spacer()
            }
        }
        .task {
            await loadUserData()
        }
        .refreshable {
            await refreshAllData()
        }
        // 付费墙 Sheet
        .sheet(isPresented: $showPaywall) {
            PaywallSheet(
                username: userInfo?.username ?? username,
                userAvatarUrl: userInfo?.avatarUrl,
                articleTitle: paywallArticleTitle,
                onContinue: {
                    // 关闭付费墙，打开文章详情
                    showPaywall = false
                    selectedArticleId = paywallArticleId
                },
                onDismiss: {
                    // 关闭付费墙，清理状态
                    showPaywall = false
                    paywallArticleId = nil
                    paywallArticleTitle = ""
                }
            )
        }
        // 文章详情 Sheet
        .sheet(isPresented: Binding<Bool>(
            get: { selectedArticleId != nil },
            set: { if !$0 { 
                selectedArticleId = nil
                // 同时清理付费墙状态
                paywallArticleId = nil
                paywallArticleTitle = ""
            } }
        )) {
            if let articleId = selectedArticleId {
                NavigationView {
                    ArticleDetailView(articleId: articleId)
                }
            }
        }
    }
    
    // MARK: - Custom Navigation Bar
    
    private var customNavigationBar: some View {
        ZStack {
            // 渐变背景
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: Color(red: 0.2, green: 0.8, blue: 0.4).opacity(0.4), location: 0.0),
                    .init(color: Color(red: 0.2, green: 0.8, blue: 0.4).opacity(0.0), location: 1.0)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea(.all, edges: .top)
            
            // 导航内容
            HStack {
                // 返回按钮
                Button(action: {
                    // 清理状态并返回
                    articleService.setCurrentViewingUser(nil)
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.black)
                        .frame(width: 44, height: 44)
                }
                
                Spacer()
                
                // 用户名标题
                VStack(spacing: 2) {
                    Text(userInfo?.username ?? username)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black)
                    Text("的知识库")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.black.opacity(0.7))
                }
                
                Spacer()
                
                // 占位空间保持居中
                Color.clear
                    .frame(width: 44, height: 44)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
        .frame(height: 80)
    }
    
    // MARK: - Data Loading Methods
    
    private func loadUserInfo() async {
        isLoadingUserInfo = true
        
        let response = await apiClient.get(
            endpoint: "v1/users/\(userId)",
            responseType: User.self
        )
        
        isLoadingUserInfo = false
        
        if response.isSuccess, let userData = response.data {
            userInfo = userData
            print("✅ 用户信息加载成功: \(userData.username)")
        } else if let error = response.error {
            print("❌ 用户信息加载失败: \(error.localizedDescription)")
        }
    }
    
    private func loadUserData() async {
        // 设置当前查看的用户ID
        articleService.setCurrentViewingUser(userId)
        
        // 并行加载用户信息和其他数据
        async let userInfoTask = loadUserInfo()
        async let articlesTask = articleService.fetchMyArticles(userId: userId)
        async let tagsTask = articleService.fetchUserTags(userId: userId)
        async let graphTask = articleService.loadKnowledgeGraphData(userId: userId)
        
        await userInfoTask
        await articlesTask
        await tagsTask
        await graphTask
    }
    
    private func refreshAllData() async {
        print("🔄 开始刷新用户 \(username) 的数据...")
        
        // 确保设置正确的用户ID
        articleService.setCurrentViewingUser(userId)
        articleService.clearError()
        
        await withTaskGroup(of: Void.self) { group in
            // 1. 刷新用户信息
            group.addTask {
                await self.loadUserInfo()
            }
            
            // 2. 刷新文章列表
            group.addTask {
                await self.articleService.refreshUserArticles(userId: self.userId)
            }
            
            // 3. 刷新用户标签列表
            group.addTask {
                await self.articleService.fetchUserTags(userId: self.userId)
            }
            
            // 4. 刷新知识图谱数据
            group.addTask {
                await self.articleService.loadKnowledgeGraphData(userId: self.userId)
            }
        }
        
        print("✅ 用户 \(username) 数据刷新完成")
    }
}

// MARK: - Extension for ArticleService

extension ArticleService {
    /// 刷新指定用户的文章列表
    func refreshUserArticles(userId: String) async {
        // 使用现有的 refreshArticles 方法，但传入指定的 userId
        // 先重置状态
        currentPage = 1
        lastError = nil
        // 直接调用 fetchMyArticles，内部会处理任务取消
        await fetchMyArticles(userId: userId, tagId: selectedTagId, page: currentPage)
    }
}

#Preview {
    UserKnowledgeBaseView(userId: "1", username: "测试用户")
}
