//
//  ArticleService.swift
//  knowhow
//
//  Created by F1reC on 2025/7/26.
//

import Foundation
import SwiftUI

// MARK: - Article API Service
@MainActor
class ArticleService: ObservableObject {
    private let apiClient: APIClient
    private var currentTask: Task<Void, Never>?
    private let userManager = UserManager.shared
    
    @Published var articles: [Article] = []
    @Published var isLoading = false
    @Published var lastError: String?
    @Published var currentPage = 1
    @Published var totalPages = 1
    @Published var totalArticles = 0
    
    // Tag相关状态
    @Published var userTags: [UserTag] = []
    @Published var selectedTagId: Int? = nil
    @Published var isLoadingTags = false
    
    // 知识图谱相关状态
    @Published var articleRelationships: [ArticleRelationship] = []
    @Published var tagsWithArticles: [TagWithArticles] = []
    @Published var userInfo: User?
    @Published var isLoadingGraph = false
    
    // 当前查看的用户ID（用于查看其他用户知识库时）
    @Published var currentViewingUserId: String?
    
    init() {
        // 配置 API 客户端
        let config = APIConfig(
            baseURL: "http://***REMOVED***/api",
            userID: userManager.userId,
            timeout: 30.0,
            headers: [
                "Content-Type": "application/json",
                "Accept": "application/json"
            ]
        )
        self.apiClient = APIClient(config: config)
    }
    
    // MARK: - API Methods
    
    /// 获取用户的文章列表
    func fetchMyArticles(userId: String? = nil, tagId: Int? = nil, page: Int = 1, perPage: Int = 10) async {
        // 取消之前的请求
        currentTask?.cancel()
        
        // 创建新的任务
        currentTask = Task {
            // 检查任务是否已被取消
            guard !Task.isCancelled else { return }
            
            isLoading = true
            lastError = nil
            
            var queryParams = [
                "user_id": userId ?? userManager.userId,
                "page": "\(page)",
                "per_page": "\(perPage)"
            ]
            
            // 添加tag筛选参数
            if let tagId = tagId {
                queryParams["tag_id"] = "\(tagId)"
            }
            
            // 再次检查取消状态
            guard !Task.isCancelled else {
                isLoading = false
                return
            }
            
            let response = await apiClient.get(
                endpoint: "v1/articles/my-articles",
                queryParams: queryParams,
                responseType: ArticlesResponse.self
            )
            
            // 检查任务是否在请求过程中被取消
            guard !Task.isCancelled else {
                isLoading = false
                return
            }
            
            isLoading = false
            
            if response.isSuccess, let articlesResponse = response.data {
                // 根据页码决定是替换还是追加数据
                if articlesResponse.page == 1 {
                    // 第一页：替换所有数据
                    articles = articlesResponse.articles
                } else {
                    // 后续页面：追加新数据
                    articles.append(contentsOf: articlesResponse.articles)
                }
                
                currentPage = articlesResponse.page
                totalArticles = articlesResponse.total
                totalPages = max(1, Int(ceil(Double(articlesResponse.total) / Double(articlesResponse.perPage))))
                
                print("✅ 成功获取文章列表: 第\(articlesResponse.page)页，当前共\(articles.count)篇文章")
            } else if let error = response.error {
                // 忽略取消错误，避免显示给用户
                if case .networkError(let networkError) = error,
                   let urlError = networkError as? URLError,
                   urlError.code == .cancelled {
                    print("🔄 请求被取消（正常行为）")
                    return
                }
                
                // 同时检查错误描述中是否包含 "cancelled"
                if error.localizedDescription.lowercased().contains("cancelled") {
                    print("🔄 请求被取消（正常行为）")
                    return
                }
                
                lastError = error.localizedDescription
                print("❌ 获取文章列表失败: \(error.localizedDescription)")
            }
        }
        
        // 等待任务完成
        await currentTask?.value
    }
    
    /// 刷新文章列表（重置到第一页）
    func refreshArticles() async {
        // 取消当前任务并重置状态
        currentTask?.cancel()
        currentPage = 1
        lastError = nil
        await fetchMyArticles(userId: currentViewingUserId, tagId: selectedTagId, page: currentPage)
    }
    
    /// 加载更多文章（下一页）
    func loadMoreArticles() async {
        guard currentPage < totalPages, !isLoading else { return }
        
        let nextPage = currentPage + 1
        await fetchMyArticles(userId: currentViewingUserId, tagId: selectedTagId, page: nextPage)
    }
    
    /// 加载更多推荐文章（下一页）
    func loadMoreRecommendedArticles() async {
        guard currentPage < totalPages, !isLoading else { return }
        
        let nextPage = currentPage + 1
        await fetchRecommendedArticles(page: nextPage)
    }
    
    /// 获取推荐文章列表
    func fetchRecommendedArticles(userId: String? = nil, page: Int = 1, perPage: Int = 10) async {
        // 取消之前的请求
        currentTask?.cancel()
        
        // 创建新的任务
        currentTask = Task {
            // 检查任务是否已被取消
            guard !Task.isCancelled else { return }
            
            isLoading = true
            lastError = nil
            
            let queryParams = [
                "user_id": userId ?? userManager.userId,
                "page": "\(page)",
                "per_page": "\(perPage)"
            ]
            
            // 再次检查取消状态
            guard !Task.isCancelled else {
                isLoading = false
                return
            }
            
            let response = await apiClient.get(
                endpoint: "v1/articles/recommendations",
                queryParams: queryParams,
                responseType: ArticlesResponse.self
            )
            
            // 检查任务是否在请求过程中被取消
            guard !Task.isCancelled else {
                isLoading = false
                return
            }
            
            isLoading = false
            
            if response.isSuccess, let articlesResponse = response.data {
                // 根据页码决定是替换还是追加数据
                if articlesResponse.page == 1 {
                    // 第一页：替换所有数据
                    articles = articlesResponse.articles
                } else {
                    // 后续页面：追加新数据
                    articles.append(contentsOf: articlesResponse.articles)
                }
                
                currentPage = articlesResponse.page
                totalArticles = articlesResponse.total
                totalPages = max(1, Int(ceil(Double(articlesResponse.total) / Double(articlesResponse.perPage))))
                
                print("✅ 成功获取推荐文章列表: 第\(articlesResponse.page)页，当前共\(articles.count)篇文章")
            } else if let error = response.error {
                // 忽略取消错误，避免显示给用户
                if case .networkError(let networkError) = error,
                   let urlError = networkError as? URLError,
                   urlError.code == .cancelled {
                    print("🔄 请求被取消（正常行为）")
                    return
                }
                
                // 同时检查错误描述中是否包含 "cancelled"
                if error.localizedDescription.lowercased().contains("cancelled") {
                    print("🔄 请求被取消（正常行为）")
                    return
                }
                
                lastError = error.localizedDescription
                print("❌ 获取推荐文章列表失败: \(error.localizedDescription)")
            }
        }
        
        // 等待任务完成
        await currentTask?.value
    }
    
    /// 刷新推荐文章列表（重置到第一页）
    func refreshRecommendedArticles() async {
        // 取消当前任务并重置状态
        currentTask?.cancel()
        currentPage = 1
        lastError = nil
        await fetchRecommendedArticles(page: currentPage)
    }
    
    /// 清除错误信息
    func clearError() {
        lastError = nil
    }
    
    // MARK: - Tag相关方法
    
    /// 获取用户的标签列表
    func fetchUserTags(userId: String? = nil) async {
        isLoadingTags = true
        // 不清除lastError，避免影响主要内容显示
        
        let response = await apiClient.get(
            endpoint: "v1/users/\(userId ?? userManager.userId)/tags",
            responseType: TagsResponse.self
        )
        
        isLoadingTags = false
        
        if response.isSuccess, let tagsResponse = response.data {
            userTags = tagsResponse.tags
            print("✅ 成功获取用户标签: \(userTags.count) 个标签")
        } else if let error = response.error {
            // 标签获取失败不影响主界面，只在控制台记录
            print("❌ 获取用户标签失败: \(error.localizedDescription)")
            // 不设置lastError，避免影响文章列表显示
        }
    }
    
    /// 选择标签进行筛选
    func selectTag(_ tagId: Int?) async {
        selectedTagId = tagId
        // 重新加载文章列表
        await refreshArticles()
    }
    
    /// 清除标签筛选
    func clearTagFilter() async {
        selectedTagId = nil
        await refreshArticles()
    }
    
    /// 设置当前查看的用户ID（用于查看其他用户知识库）
    func setCurrentViewingUser(_ userId: String?) {
        currentViewingUserId = userId
        // 清除之前的状态
        selectedTagId = nil
        articles = []
        userTags = []
    }
    
    // MARK: - Convenience Methods
    
    /// 将 Article 数组转换为 KnowledgeItem 数组（兼容现有 UI）
    var knowledgeItems: [KnowledgeItem] {
        articles.map { $0.toKnowledgeItem() }
    }
    
    /// 检查是否有错误
    var hasError: Bool {
        lastError != nil
    }
    
    /// 检查是否有数据
    var hasData: Bool {
        !articles.isEmpty
    }
    
    /// 检查是否可以加载更多
    var canLoadMore: Bool {
        currentPage < totalPages && !isLoading
    }
    
    /// 检查指定标签是否被选中
    func isTagSelected(_ tagId: Int) -> Bool {
        selectedTagId == tagId
    }
    
    // MARK: - Knowledge Graph Methods
    
    /// 获取文章关系数据（新API格式，包含用户信息和标签数据）
    func fetchArticleRelationships(userId: String? = nil) async {
        isLoadingGraph = true
        // 不清除lastError，避免影响主要内容显示
        
        let queryParams = [
            "user_id": userId ?? userManager.userId
        ]
        
        let response = await apiClient.get(
            endpoint: "v1/articles/relationships",
            queryParams: queryParams,
            responseType: RelationshipsResponse.self
        )
        
        isLoadingGraph = false
        
        if response.isSuccess, let relationshipsResponse = response.data {
            // 更新文章关系数据
            articleRelationships = relationshipsResponse.relationships
            
            // 更新标签-文章关系数据
            tagsWithArticles = relationshipsResponse.tags
            
            // 创建用户信息对象（从API响应中构建）
            userInfo = User(
                id: relationshipsResponse.userId,
                username: relationshipsResponse.username,
                email: "", // API未返回，使用空值
                bio: "",
                avatarUrl: "",
                phone: "",
                createdAt: "",
                updatedAt: "",
                lastLogin: nil
            )
            
            print("✅ 成功获取知识图谱数据: \(articleRelationships.count) 个关系, \(tagsWithArticles.count) 个标签")
        } else if let error = response.error {
            // 知识图谱获取失败不影响主界面，只在控制台记录
            print("❌ 获取知识图谱数据失败: \(error.localizedDescription)")
            // 不设置lastError，避免影响文章列表显示
        }
    }
    
    /// 加载知识图谱所需的所有数据（新API一次性返回所有数据）
    func loadKnowledgeGraphData(userId: String? = nil) async {
        let targetUserId = userId ?? userManager.userId
        print("📊 开始加载用户 \(targetUserId) 的知识图谱数据...")
        
        // 新API一次性返回用户信息、文章关系和标签数据
        await fetchArticleRelationships(userId: targetUserId)
        
        if userInfo != nil {
            print("📊 用户 \(targetUserId) 的知识图谱数据加载完成")
        } else {
            print("⚠️ 用户 \(targetUserId) 的知识图谱数据加载失败")
        }
    }
}
