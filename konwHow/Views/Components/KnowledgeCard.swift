//
//  KnowledgeCard.swift
//  konwHow
//
//  Created by F1reC on 2025/7/25.
//

import SwiftUI

struct KnowledgeCard: View {
    let item: KnowledgeItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(item.title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.black)
            
            Text(item.description)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.black.opacity(0.7))
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
                .lineSpacing(1)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 1)
    }
}

#Preview {
    KnowledgeCard(item: KnowledgeItem(
        title: "AdventureX",
        description: "adx 是中国最大的一场黑客松，2025年有871人参加，参与人数众多，氛围热烈！",
        category: "Adv"
    ))
    .padding()
    .background(Color(red: 0.96, green: 0.98, blue: 0.96))
} 