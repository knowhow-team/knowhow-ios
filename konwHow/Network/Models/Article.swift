//
//  Article.swift
//  konwHow
//
//  Created by F1reC on 2025/7/26.
//

import Foundation

// MARK: - API Response Models

struct ArticleTag: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
}

struct UserTag: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let userId: Int
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, name
        case userId = "user_id"
        case createdAt = "created_at"
    }
}

struct TagsResponse: Codable {
    let tags: [UserTag]
    let totalCount: Int
    
    enum CodingKeys: String, CodingKey {
        case tags
        case totalCount = "total_count"
    }
}

struct ArticleAuthor: Codable, Identifiable, Hashable {
    let id: Int
    let username: String
    let avatarUrl: String
    
    enum CodingKeys: String, CodingKey {
        case id, username
        case avatarUrl = "avatar_url"
    }
}

struct Article: Codable, Identifiable {
    let id: Int
    let title: String
    let summary: String
    let status: String?
    let createdAt: String
    let updatedAt: String?
    let finishedAt: String?
    let tags: [ArticleTag]
    let author: ArticleAuthor?
    
    enum CodingKeys: String, CodingKey {
        case id, title, summary, status, tags, author
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case finishedAt = "finished_at"
    }
}

struct ArticlesResponse: Codable {
    let articles: [Article]
    let message: String
    let page: Int
    let perPage: Int
    let total: Int
    
    enum CodingKeys: String, CodingKey {
        case articles, message, page, total
        case perPage = "per_page"
    }
}

// MARK: - Article Detail Models

struct ArticleDetail: Codable, Identifiable {
    let id: Int
    let title: String
    let summary: String
    let content: String
    let status: String?
    let createdAt: String
    let updatedAt: String?
    let finishedAt: String?
    let tags: [ArticleTag]
    let author: ArticleAuthor?
    let recommendations: [Article]
    
    enum CodingKeys: String, CodingKey {
        case id, title, summary, content, status, tags, author, recommendations
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case finishedAt = "finished_at"
    }
}

struct ArticleDetailResponse: Codable {
    let article: ArticleDetail
    let message: String
}

// MARK: - Extension for UI Display

extension Article {
    /// 转换为 KnowledgeItem 以兼容现有 UI
    func toKnowledgeItem() -> KnowledgeItem {
        let categoryString = tags.map { $0.name }.joined(separator: ", ")
        return KnowledgeItem(
            title: title,
            description: summary,
            category: categoryString.isEmpty ? "未分类" : categoryString
        )
    }
    
    /// 格式化创建时间为可读格式
    var formattedCreatedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        if let date = formatter.date(from: createdAt) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "yyyy年MM月dd日"
            return displayFormatter.string(from: date)
        }
        return createdAt
    }
    
    /// 获取主要标签（第一个标签）
    var primaryTag: String {
        tags.first?.name ?? "未分类"
    }
    
    /// 检查文章是否已发布
    var isPublished: Bool {
        status == "published"
    }
}

extension ArticleDetail {
    /// 格式化更新时间为可读格式
    var formattedUpdatedDate: String {
        guard let updatedAt = updatedAt else { return formattedCreatedDate }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        if let date = formatter.date(from: updatedAt) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "yyyy年MM月dd日"
            return displayFormatter.string(from: date)
        }
        return updatedAt
    }
    
    /// 格式化创建时间为可读格式
    var formattedCreatedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        if let date = formatter.date(from: createdAt) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "yyyy年MM月dd日"
            return displayFormatter.string(from: date)
        }
        return createdAt
    }
    
    /// 获取主要标签（第一个标签）
    var primaryTag: String {
        tags.first?.name ?? "未分类"
    }
    
    /// 检查文章是否已发布
    var isPublished: Bool {
        status == "published"
    }
}