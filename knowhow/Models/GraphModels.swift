//
//  GraphModels.swift
//  knowhow
//
//  Created by F1reC on 2025/7/26.
//

import Foundation

// MARK: - Shared Graph Data Models

/// 图谱用户节点
struct GraphUser {
    let id: String    // "user_{id}"
    let name: String  // username
}

/// 图谱标签节点
struct GraphTag {
    let id: String    // "tag_{id}"
    let name: String  // tag.name
}

/// 图谱文章节点
struct GraphArticle {
    let id: String       // "article_{id}"
    let title: String    // article.title
    let userId: String   // "user_{userId}"
    let tagIds: [String] // ["tag_{tagId}", ...]
}

/// 知识图谱数据结构
struct KnowledgeGraphData {
    let users: [GraphUser]
    let articles: [GraphArticle]
    let tags: [GraphTag]
    let userTagLinks: [(String, String)]
    let tagArticleLinks: [(String, String)]
    let articleLinks: [(String, String)] // 文章间引用关系
}

/// 简化的图数据结构（用于ArticleTagGraphView）
struct GraphData {
    let users: [GraphUser]
    let articles: [GraphArticle]
    let tags: [GraphTag]
    let userTagLinks: [(String, String)]
    let tagArticleLinks: [(String, String)]
}
