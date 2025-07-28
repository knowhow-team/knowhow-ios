//
//  TagView.swift
//  knowhow
//
//  Created by F1reC on 2025/7/25.
//

import SwiftUI

struct TagView: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.system(size: 16, weight: .bold))
            .foregroundColor(Color(red: 0.2, green: 0.8, blue: 0.4))
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(Color(red: 0.98, green: 0.98, blue: 0.96))
            )
    }
}

#Preview {
    TagView(text: "#adx")
        .padding()
} 
