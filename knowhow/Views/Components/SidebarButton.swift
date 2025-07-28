//
//  SidebarButton.swift
//  knowhow
//
//  Created by F1reC on 2025/7/25.
//

import SwiftUI

struct SidebarButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "line.3.horizontal")
                .font(.system(size: 22, weight: .medium))
                .foregroundColor(.black)
                .frame(width: 44, height: 44)
                .background(Color.clear) // 透明背景
                .cornerRadius(10)
                // 移除阴影，实现完全透明效果
        }
    }
}

#Preview {
    SidebarButton(action: {})
        .padding()
} 
