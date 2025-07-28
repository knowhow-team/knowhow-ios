//
//  ContentView.swift
//  knowhow
//
//  Created by F1reC on 2025/7/25.
//

import SwiftUI
import Foundation

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var showSidebar = false // 侧边栏状态提升到这里
    
    // 任务处理相关状态
    @State private var showTaskPopup = false
    @State private var currentTaskId: Int?
    @State private var taskTitle = ""
    @State private var taskStatus: TaskStatus = .waiting
    @State private var pollingTimer: Timer?
    @State private var newArticlesWithBadges: [ArticleWithBadge] = []
    @State private var showNewArticles = false
    @State private var selectedArticleId: Int? // 选中的文章ID
    
    @StateObject private var apiClient: APIClient
    @StateObject private var userManager = UserManager.shared
    
    init() {
        let config = APIConfig(
            baseURL: "http://***REMOVED***/api",
            userID: UserManager.shared.userId,
            timeout: 30.0
        )
        self._apiClient = StateObject(wrappedValue: APIClient(config: config))
    }
    
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
            
            // 任务处理弹窗
            TaskProcessingPopup(
                title: taskTitle,
                status: taskStatus,
                isPresented: $showTaskPopup,
                onDismiss: {
                    // 当弹窗被手动关闭时，显示施工状态
                    if selectedTab == 0 { // 只在知识库页面显示
                        NotificationCenter.default.post(
                            name: NSNotification.Name("ShowConstructionStatus"),
                            object: nil
                        )
                    }
                }
            )
            .zIndex(2000)
            
            // 新文章展示
            if showNewArticles {
                NewArticlesDisplay(
                    articlesWithBadges: newArticlesWithBadges,
                    onDismiss: {
                        withAnimation {
                            showNewArticles = false
                        }
                        
                        // 隐藏施工状态并通知知识库刷新数据
                        NotificationCenter.default.post(
                            name: NSNotification.Name("HideConstructionStatus"),
                            object: nil
                        )
                        
                        NotificationCenter.default.post(
                            name: NSNotification.Name("RefreshKnowledgeBase"),
                            object: nil
                        )
                    },
                    onArticleTap: { articleId in
                        // 关闭新文章弹窗
                        withAnimation {
                            showNewArticles = false
                        }
                        
                        // 隐藏施工状态并通知知识库刷新数据
                        NotificationCenter.default.post(
                            name: NSNotification.Name("HideConstructionStatus"),
                            object: nil
                        )
                        
                        NotificationCenter.default.post(
                            name: NSNotification.Name("RefreshKnowledgeBase"),
                            object: nil
                        )
                        
                        // 导航到文章详情页
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            selectedArticleId = articleId
                        }
                    }
                )
                .transition(.scale.combined(with: .opacity))
                .zIndex(2000)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("StartTaskPolling"))) { notification in
            handleTaskPollingNotification(notification)
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
        .onDisappear {
            cleanupTasks()
        }
    }
    
    // MARK: - Task Processing Methods
    
    private func handleTaskPollingNotification(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let taskId = userInfo["taskId"] as? Int,
              let title = userInfo["title"] as? String else {
            return
        }
        
        // 设置任务状态并开始轮询
        currentTaskId = taskId
        taskTitle = title
        taskStatus = .waiting
        showTaskPopup = true
        
        startPollingTaskStatus()
    }
    
    @MainActor
    private func startPollingTaskStatus() {
        guard let taskId = currentTaskId else { return }
        
        pollingTimer?.invalidate()
        pollingTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            Task {
                await self.checkTaskStatus(taskId: taskId)
            }
        }
        
        // 立即检查一次状态
        Task {
            await checkTaskStatus(taskId: taskId)
        }
    }
    
    @MainActor
    private func checkTaskStatus(taskId: Int) async {
        let response = await apiClient.get(
            endpoint: "v1/articles/tasks/\(taskId)",
            responseType: TaskStatusResponse.self
        )
        
        if response.isSuccess, let data = response.data {
            let langgraphStatus = TaskStatus(rawValue: data.task.langgraphStatus) ?? .waiting
            
            taskStatus = langgraphStatus
            
            if langgraphStatus.isFinished {
                // 任务完成，停止轮询
                stopPollingTaskStatus()
                
                // 收集新创建和更新的文章，添加badge信息
                var articlesWithBadges: [ArticleWithBadge] = []
                
                // 添加新建的文章
                for article in data.task.createdArticlesInfo {
                    articlesWithBadges.append(ArticleWithBadge(article: article, badgeType: .created))
                }
                
                // 添加更新的文章
                for article in data.task.updatedArticlesInfo {
                    articlesWithBadges.append(ArticleWithBadge(article: article, badgeType: .updated))
                }
                
                newArticlesWithBadges = articlesWithBadges
                
                // 延迟一下显示完成状态，然后展示新文章
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    showTaskPopup = false
                    
                    if !newArticlesWithBadges.isEmpty {
                        withAnimation {
                            showNewArticles = true
                        }
                    }
                }
                
                print("✅ 任务完成，生成了 \(articlesWithBadges.count) 篇文章")
            } else {
                print("🔄 任务状态: \(langgraphStatus.description)")
            }
        } else if let error = response.error {
            print("❌ 检查任务状态失败: \(error.localizedDescription)")
        }
    }
    
    private func stopPollingTaskStatus() {
        pollingTimer?.invalidate()
        pollingTimer = nil
    }
    
    private func cleanupTasks() {
        stopPollingTaskStatus()
        currentTaskId = nil
        showTaskPopup = false
        newArticlesWithBadges = []
        showNewArticles = false
        selectedArticleId = nil
    }
}

#Preview {
    ContentView()
}
