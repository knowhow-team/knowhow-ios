//
//  FullscreenKnowledgeGraphView.swift
//  knowhow
//
//  Created by F1reC on 2025/7/26.
//

import SwiftUI
import Grape

// MARK: - Fullscreen Knowledge Graph View

struct FullscreenKnowledgeGraphView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var articleService: ArticleService
    @State private var selectedArticleId: Int?
    
    // MARK: - Graph State
    @State private var graphStates = ForceDirectedGraphState(
        initialIsRunning: true,
        initialModelTransform: .identity.scale(by: 0.9)
    )
    
    // MARK: - 主题色
    private let themeColor = Color(red: 0.3203125, green: 0.8125, blue: 0.46484375)
    private let highlightColor = Color.yellow // 拖拽时的高亮颜色
    
    // MARK: - 交互状态
    @State private var draggingNodeID: String? = nil
    
    // MARK: - 连接长度调试变量 (与ArticleKnowledgeGraphView完全一致)
    @State private var userTagLinkLength: Double = 80.0
    @State private var tagTagLinkLength: Double = 160.0
    @State private var tagArticleLinkLength: Double = 120.0
    @State private var articleTagLinkLength: Double = 120.0
    @State private var articleArticleLinkLength: Double = 20.0
    
    var body: some View {
        ZStack {
            // 背景
            Color(red: 0.96, green: 0.98, blue: 0.96)
                .ignoresSafeArea(.all)
            
            VStack(spacing: 0) {
                // 自定义顶部导航栏
                customNavigationBar
                
                // 主内容
                if articleService.isLoadingGraph {
                    loadingView
                } else if let error = articleService.lastError {
                    errorView(message: error)
                } else {
                    fullscreenGraphView
                }
            }
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
    
    // MARK: - Custom Navigation Bar
    
    private var customNavigationBar: some View {
        HStack {
            // 关闭按钮
            Button(action: {
                dismiss()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .medium))
                    Text("关闭")
                        .font(.system(size: 17, weight: .medium))
                }
                .foregroundColor(themeColor)
            }
            
            Spacer()
            
            // 标题
            Text("知识图谱")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.black)
            
            Spacer()
            
            // 重置按钮
            Button(action: {
                // 重置图谱状态
                graphStates = ForceDirectedGraphState(
                    initialIsRunning: true,
                    initialModelTransform: .identity.scale(by: 0.9)
                )
            }) {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(themeColor)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 16)
        .background(
            Color(red: 0.96, green: 0.98, blue: 0.96)
                .ignoresSafeArea(.all, edges: .top)
        )
    }
    
    // MARK: - Subviews
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.2)
            Text("加载知识图谱...")
                .foregroundColor(.gray)
                .font(.system(size: 16))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func errorView(message: String) -> some View {
        VStack(spacing: 20) {
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
                .padding(.horizontal, 40)
            
            Button("重新加载") {
                Task {
                    await articleService.loadKnowledgeGraphData()
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
            .background(themeColor)
            .foregroundColor(.white)
            .cornerRadius(6)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var fullscreenGraphView: some View {
        let graphData = buildKnowledgeGraphData()
        
        return ForceDirectedGraph(states: graphStates) {
            // 用户根节点（全屏时稍大）
            if let user = graphData.users.first {
                Series([user]) { user in
                    NodeMark(id: user.id)
                        .symbol(.circle)
                        .symbolSize(radius: 25.0)
                        .foregroundStyle(themeColor.gradient)
                        .stroke(
                            draggingNodeID == user.id ? highlightColor : .white,
                            StrokeStyle(lineWidth: draggingNodeID == user.id ? 5 : 4)
                        )
                        .annotation(user.name, alignment: .center) {
                            Text(user.name)
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                        }
                }
            }
            
            // 标签节点（全屏时更大）
            Series(graphData.tags) { tag in
                NodeMark(id: tag.id)
                    .symbol(.rect(cornerRadius: 5))
                    .symbolSize(CGSize(width: max(80, CGFloat(tag.name.count * 12 + 24)), height: 32))
                    .foregroundStyle(Color(red: 0.97265625, green: 0.97265625, blue: 0.97265625).opacity(1.0))
                    .stroke(
                        draggingNodeID == tag.id ? highlightColor : Color.clear,
                        StrokeStyle(lineWidth: draggingNodeID == tag.id ? 3 : 0)
                    )
                    .annotation(tag.name, alignment: .center) {
                        HStack(spacing: 2) {
                            Text("#")
                                .font(.system(size: 7, weight: .bold))
                                .foregroundColor(Color(red: 0.2, green: 0.6, blue: 0.3))
                            
                            Text(tag.name)
                                .font(.system(size: 8, weight: .medium))
                                .foregroundColor(.black)
                                .lineLimit(1)
                        }
                    }
            }
            
            // 文章节点（全屏时更大）
            Series(graphData.articles) { article in
                NodeMark(id: article.id)
                    .symbol(.circle)
                    .symbolSize(radius: 25.0)
                    .foregroundStyle(Color(red: 0.91796875, green:0.91796875, blue:0.91796875))
                    .stroke(
                        draggingNodeID == article.id ? highlightColor : .white,
                        StrokeStyle(lineWidth: draggingNodeID == article.id ? 4 : 2)
                    )
                    .annotation("💡", alignment: .center) {
                        Text("💡")
                            .font(.system(size: 15))
                    }
            }
            
            // 用户到标签的连接
            Series(graphData.userTagLinks) { link in
                LinkMark(from: link.0, to: link.1)
                    .stroke(themeColor.opacity(0.25), StrokeStyle(lineWidth: 2.0, lineJoin: .bevel))
            }
            
            // 标签到文章的连接
            Series(graphData.tagArticleLinks) { link in
                LinkMark(from: link.0, to: link.1)
                    .stroke(.cyan.opacity(0.4), StrokeStyle(lineWidth: 1.5, lineJoin: .bevel))
            }
            
            // 文章间引用关系连接
            Series(graphData.articleLinks) { link in
                LinkMark(from: link.0, to: link.1)
                    .stroke(.blue.opacity(0.7), StrokeStyle(lineWidth: 2.5, dash: [5, 3]))
            }
        } force: {
            // 为用户节点设置更强的中心力
            .manyBody(strength: -150) // 增加排斥力
            .center(strength: 0.3)    // 增加中心引力
            .link(
                originalLength: .varied { edge, lookup in
                    let sourceId = String(describing: edge.source)
                    let targetId = String(describing: edge.target)
                    
                    // 用户到标签的连接
                    if (sourceId.hasPrefix("user_") && targetId.hasPrefix("tag_")) ||
                       (sourceId.hasPrefix("tag_") && targetId.hasPrefix("user_")) {
                        return self.userTagLinkLength
                    }
                    // 标签到标签的连接
                    else if sourceId.hasPrefix("tag_") && targetId.hasPrefix("tag_") {
                        return self.tagTagLinkLength
                    }
                    // 标签到文章的连接
                    else if (sourceId.hasPrefix("tag_") && targetId.hasPrefix("article_")) ||
                            (sourceId.hasPrefix("article_") && targetId.hasPrefix("tag_")) {
                        return self.tagArticleLinkLength
                    }
                    // 文章到文章的连接
                    else if sourceId.hasPrefix("article_") && targetId.hasPrefix("article_") {
                        return self.articleArticleLinkLength
                    }
                    // 默认连接
                    else {
                        return 80.0
                    }
                },
                stiffness: .weightedByDegree { _, _ in 0.6 } // 保持固定刚度
            )
            .collide(radius: .constant(35)) // 增加碰撞半径
        }
        .graphOverlay { proxy in
            Rectangle()
                .fill(.clear)
                .contentShape(Rectangle())
                .withGraphTapGesture(proxy, of: String.self) { nodeId in
                    if let articleId = Int(nodeId.replacingOccurrences(of: "article_", with: "")) {
                        selectedArticleId = articleId
                    }
                }
                .withGraphDragGesture(proxy, of: String.self, action: handleDrag)
                .withGraphMagnifyGesture(proxy)
        }
        .background(Color.white)
        .cornerRadius(20) // 与原版保持一致
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5) // 添加阴影效果
        .padding(.horizontal, 16)
        .padding(.bottom, 32) // iPad 全屏时底部留更多空间
    }
    
    // MARK: - Data Processing (复用 ArticleKnowledgeGraphView 的逻辑)
    
    private func buildKnowledgeGraphData() -> KnowledgeGraphData {
        guard let user = articleService.userInfo else {
            return KnowledgeGraphData(users: [], articles: [], tags: [], userTagLinks: [], tagArticleLinks: [], articleLinks: [])
        }
        
        let tagsWithArticles = articleService.tagsWithArticles
        let relationships = articleService.articleRelationships
        
        // 构建用户节点
        let graphUser = GraphUser(id: "user_\(user.id)", name: user.username)
        
        // 构建标签节点（直接从API数据获取）
        let graphTags = tagsWithArticles.map { tag in
            GraphTag(id: "tag_\(tag.id)", name: tag.name)
        }
        
        // 收集所有文章（从tags中的articles数组获取）
        var allArticlesMap: [Int: TaggedArticle] = [:]
        for tag in tagsWithArticles {
            for article in tag.articles {
                allArticlesMap[article.id] = article
            }
        }
        
        // 构建文章节点，并记录每个文章对应的标签
        var articleTagMap: [Int: [Int]] = [:] // 文章ID -> 标签ID数组
        for tag in tagsWithArticles {
            for article in tag.articles {
                if articleTagMap[article.id] == nil {
                    articleTagMap[article.id] = []
                }
                articleTagMap[article.id]?.append(tag.id)
            }
        }
        
        let graphArticles = allArticlesMap.values.map { article in
            GraphArticle(
                id: "article_\(article.id)",
                title: article.name,
                userId: "user_\(user.id)",
                tagIds: (articleTagMap[article.id] ?? []).map { "tag_\($0)" }
            )
        }
        
        // 构建连接关系
        // 1. 用户到标签的连接（用户拥有所有标签）
        let userTagLinks = graphTags.map { (graphUser.id, $0.id) }
        
        // 2. 标签到文章的连接（直接从 tagsWithArticles 获取）
        let tagArticleLinks = tagsWithArticles.flatMap { tag in
            tag.articles.map { ("tag_\(tag.id)", "article_\($0.id)") }
        }
        
        // 3. 文章间引用关系（从 relationships 获取）
        let articleLinks = relationships.map { relationship in
            ("article_\(relationship.citingArticle.id)", "article_\(relationship.referencedArticle.id)")
        }
        
        return KnowledgeGraphData(
            users: [graphUser],
            articles: graphArticles,
            tags: graphTags,
            userTagLinks: userTagLinks,
            tagArticleLinks: tagArticleLinks,
            articleLinks: articleLinks
        )
    }
    
    // MARK: - Interaction Handlers
    
    private func handleDrag(_ state: GraphDragState<String>?) {
        switch state {
        case .node(let id):
            if draggingNodeID != id {
                draggingNodeID = id
            }
        case .background:
            draggingNodeID = nil
        case nil:
            draggingNodeID = nil
        }
    }
}

// MARK: - Preview

#Preview {
    FullscreenKnowledgeGraphView()
        .environmentObject(ArticleService())
}
