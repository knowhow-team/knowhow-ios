//
//  TextRecord.swift
//  konwHow
//
//  Created by F1reC on 2025/7/26.
//

import Foundation
import SwiftUI

// MARK: - Text Record API Models

struct TextRecordRequest: Codable, APIRequestBody {
    let userId: Int
    let text: String
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case text
    }
}

struct TextRecordResponse: Codable {
    let message: String
    let recordId: Int
    let taskId: Int
    let title: String
    
    enum CodingKeys: String, CodingKey {
        case message
        case recordId = "record_id"
        case taskId = "task_id"
        case title
    }
}

// MARK: - Task Status Models

struct TaskInfo: Codable {
    let taskId: Int
    let userId: Int
    let createdAt: String
    let updatedAt: String
    let langgraphStatus: Int
    let summaryStatus: Int
    let errorMessage: String?
    let createdArticlesInfo: [Article]
    let updatedArticlesInfo: [Article]
    
    enum CodingKeys: String, CodingKey {
        case taskId = "task_id"
        case userId = "user_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case langgraphStatus = "langgraph_status"
        case summaryStatus = "summary_status"
        case errorMessage = "error_message"
        case createdArticlesInfo = "created_articles_info"
        case updatedArticlesInfo = "updated_articles_info"
    }
}

struct TaskStatusResponse: Codable {
    let message: String
    let task: TaskInfo
}

// MARK: - Task Status Enum

enum TaskStatus: Int, CaseIterable {
    case waiting = 0
    case processing = 1
    case completed = 2
    
    var description: String {
        switch self {
        case .waiting:
            return "等待中"
        case .processing:
            return "处理中"
        case .completed:
            return "处理完成"
        }
    }
    
    var isFinished: Bool {
        return self == .completed
    }
}

// MARK: - Article with Badge Info

enum ArticleBadgeType {
    case created
    case updated
    
    var title: String {
        switch self {
        case .created:
            return "新建"
        case .updated:
            return "更新"
        }
    }
    
    var color: Color {
        switch self {
        case .created:
            return Color.green
        case .updated:
            return Color.blue
        }
    }
    
    var icon: String {
        switch self {
        case .created:
            return "plus.circle.fill"
        case .updated:
            return "arrow.clockwise.circle.fill"
        }
    }
}

struct ArticleWithBadge {
    let article: Article
    let badgeType: ArticleBadgeType
}
