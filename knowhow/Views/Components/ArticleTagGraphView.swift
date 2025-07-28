//
// ArticleTagGraphView.swift
// knowhow
//
// Created by Sichao He on 2025/7/26.
//

import SwiftUI
import Grape

// 数据类型定义已移至 GraphModels.swift

struct ArticleTagGraphView: View {
    // MARK: - 主题色
    private let themeColor = Color(red: 0.2, green: 0.6, blue: 0.4)
    private let highlightColor = Color.yellow // 拖拽时的高亮颜色
    
    // MARK: - 数据源
    private let graphData: GraphData = {
        let user = GraphUser(id: "user1", name: "张三")
        let allArticles = [
            GraphArticle(id: "article1", title: "Swift编程指南：从入门到精通的完整教程", userId: "user1", tagIds: ["tag1", "tag2"]),
            GraphArticle(id: "article2", title: "iOS开发最佳实践与性能优化技巧", userId: "user1", tagIds: ["tag1", "tag3", "tag4"]),
            GraphArticle(id: "article3", title: "SwiftUI布局详解：掌握现代iOS界面开发", userId: "user1", tagIds: ["tag2", "tag3"]),
            GraphArticle(id: "article4", title: "机器学习在移动端的应用与实践", userId: "user2", tagIds: ["tag4", "tag5"]),
        ]
        let allTags = [
            GraphTag(id: "tag1", name: "Swift"),
            GraphTag(id: "tag2", name: "iOS"),
            GraphTag(id: "tag3", name: "SwiftUI"),
            GraphTag(id: "tag4", name: "性能优化"),
            GraphTag(id: "tag5", name: "机器学习"),
        ]
        let articles = allArticles.filter { $0.userId == user.id }
        let usedTagIds = Set(articles.flatMap { $0.tagIds })
        let tags = allTags.filter { usedTagIds.contains($0.id) }
        let userTagLinks = usedTagIds.map { (user.id, $0) }
        let tagArticleLinks = articles.flatMap { article in
            article.tagIds.map { ($0, article.id) }
        }
        return GraphData(
            users: [user],
            articles: articles,
            tags: tags,
            userTagLinks: userTagLinks,
            tagArticleLinks: tagArticleLinks
        )
    }()
    
    @State private var graphStates = ForceDirectedGraphState(
        initialIsRunning: true,
        initialModelTransform: .identity.scale(by: 1.0)
    )
    
    @State private var selectedArticle: GraphArticle?
    @State private var showingArticleTitle = false
    
    // MARK: - 新增：交互状态
    @State private var draggingNodeID: String? = nil
    
    var body: some View {
        NavigationView {
            VStack {
                ForceDirectedGraph(states: graphStates) {
                    // 用户根节点
                    Series(graphData.users) { user in
                        NodeMark(id: user.id)
                            .symbol(.circle)
                            .symbolSize(radius: 40.0)
                            .foregroundStyle(themeColor.gradient)
                            // ✅ 新增：拖拽高亮反馈
                            .stroke(
                                draggingNodeID == user.id ? highlightColor : .white,
                                StrokeStyle(lineWidth: draggingNodeID == user.id ? 5 : 4)
                            )
                            .annotation(user.name, alignment: .center) {
                                Text(user.name)
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                            }
                    }
                    
                    // 标签节点
                    Series(graphData.tags) { tag in
                        NodeMark(id: tag.id)
                            .symbol(.ellipse)
                            .symbolSize(CGSize(width: 60, height: 30))
                            .foregroundStyle(.orange.gradient)
                            // ✅ 新增：拖拽高亮反馈
                            .stroke(
                                draggingNodeID == tag.id ? highlightColor : .white,
                                StrokeStyle(lineWidth: draggingNodeID == tag.id ? 4 : 2)
                            )
                            .annotation(tag.name, alignment: .center) {
                                Text(tag.name)
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(.black)
                            }
                    }
                    
                    // 文章节点
                    Series(graphData.articles) { article in
                        NodeMark(id: article.id)
                            .symbol(.circle)
                            .symbolSize(radius: 15.0)
                            .foregroundStyle(Color.green.opacity(0.8).gradient)
                            // ✅ 新增：拖拽高亮反馈
                            .stroke(
                                draggingNodeID == article.id ? highlightColor : .white,
                                StrokeStyle(lineWidth: draggingNodeID == article.id ? 4 : 2)
                            )
                            .annotation("📄", alignment: .center) {
                                Text("📄")
                                    .font(.system(size: 12))
                            }
                    }
                    
                    // 用户到标签的连接
                    Series(graphData.userTagLinks) { link in
                        LinkMark(from: link.0, to: link.1)
                            .stroke(themeColor.opacity(0.8), StrokeStyle(lineWidth: 3.0))
                    }
                    
                    // 标签到文章的连接
                    Series(graphData.tagArticleLinks) { link in
                        LinkMark(from: link.0, to: link.1)
                            .stroke(.gray.opacity(0.6), StrokeStyle(lineWidth: 2.0))
                    }
                } force: {
                    .manyBody(strength: -200)
                    .center(strength: 0.1)
                    .link(originalLength: .constant(100.0), stiffness: .weightedByDegree { _, _ in 0.6 })
                    .collide(radius: .constant(30))
                    .radial(center: SIMD2(0, 0), strength: 0.2)
                }
                // ✅ 新增：交互层
                .graphOverlay { proxy in
                    Rectangle()
                        .fill(.clear)
                        .contentShape(Rectangle())
                        // 点击手势
                        .withGraphTapGesture(proxy, of: String.self) { nodeId in
                            if let article = graphData.articles.first(where: { $0.id == nodeId }) {
                                selectedArticle = article
                                showingArticleTitle = true
                            }
                        }
                        // 拖拽手势
                        .withGraphDragGesture(proxy, of: String.self, action: handleDrag)
                        // 缩放手势
                        .withGraphMagnifyGesture(proxy)
                }
                // ✅ 新增：美化修饰符
                .background(Color(.systemGroupedBackground))
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                .padding()
            }
            .background(Color.white.edgesIgnoringSafeArea(.all)) // 给整个视图一个背景色
            .alert("文章标题", isPresented: $showingArticleTitle) {
                Button("确定") { }
            } message: {
                if let article = selectedArticle {
                    Text(article.title)
                }
            }
            .navigationTitle("张三的文章网络")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(graphStates.isRunning ? "暂停" : "继续") {
                        graphStates.isRunning.toggle()
                    }
                    .tint(themeColor)
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack(spacing: 12) {
                        HStack(spacing: 4) { Circle().fill(themeColor).frame(width: 10, height: 10); Text("用户").font(.caption) }
                        HStack(spacing: 4) { Circle().fill(Color.orange).frame(width: 10, height: 10); Text("标签").font(.caption) }
                        HStack(spacing: 4) { Circle().fill(Color.green.opacity(0.8)).frame(width: 10, height: 10); Text("文章").font(.caption) }
                    }
                    .padding(.leading, 8)
                }
            }
        }
    }
    
    // ✅ 新增：拖拽处理函数
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

#Preview {
    ArticleTagGraphView()
}
