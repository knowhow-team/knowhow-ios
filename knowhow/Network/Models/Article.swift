//
//  Article.swift
//  knowhow
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

// MARK: - Article Relationships Models (Updated for new API format)

/// 简化的文章引用关系 - 新API格式只返回ID
struct ArticleRelationship: Codable, Identifiable {
    let citingArticle: ArticleReference
    let referencedArticle: ArticleReference
    
    // 使用引用文章的ID作为关系的唯一标识
    var id: String {
        "\(citingArticle.id)_\(referencedArticle.id)"
    }
    
    enum CodingKeys: String, CodingKey {
        case citingArticle = "citing_article"
        case referencedArticle = "referenced_article"
    }
}

/// 文章引用信息 - 只包含ID
struct ArticleReference: Codable {
    let id: Int
}

/// 包含文章列表的标签信息
struct TagWithArticles: Codable, Identifiable {
    let id: Int
    let name: String
    let articles: [TaggedArticle]
}

/// 标签下的文章信息
struct TaggedArticle: Codable, Identifiable {
    let id: Int
    let name: String
}

/// 新的关系API响应格式
struct RelationshipsResponse: Codable {
    let relationships: [ArticleRelationship]
    let tags: [TagWithArticles]
    let userId: Int
    let username: String
    
    enum CodingKeys: String, CodingKey {
        case relationships, tags, username
        case userId = "user_id"
    }
}

// MARK: - User Models

struct User: Codable, Identifiable {
    let id: Int
    let username: String
    let email: String
    let bio: String
    let avatarUrl: String
    let phone: String
    let createdAt: String
    let updatedAt: String
    let lastLogin: String?
    
    enum CodingKeys: String, CodingKey {
        case id, username, email, bio, phone
        case avatarUrl = "avatar_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case lastLogin = "last_login"
    }
}

struct UserResponse: Codable {
    let user: User
    
    // 如果API直接返回用户对象而不是包装在user字段中，可以使用这个初始化器
    init(from decoder: Decoder) throws {
        // 先尝试直接解析为User
        if let user = try? User(from: decoder) {
            self.user = user
        } else {
            // 如果失败，尝试从容器中获取user字段
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.user = try container.decode(User.self, forKey: .user)
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case user
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
