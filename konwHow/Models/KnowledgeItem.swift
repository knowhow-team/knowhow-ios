//
//  KnowledgeItem.swift
//  konwHow
//
//  Created by F1reC on 2025/7/25.
//

import Foundation

struct KnowledgeItem: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let category: String
} 