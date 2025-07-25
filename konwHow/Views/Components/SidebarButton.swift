//
//  SidebarButton.swift
//  konwHow
//
//  Created by F1reC on 2025/7/25.
//

import SwiftUI

struct SidebarButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "line.3.horizontal")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.black)
                .frame(width: 44, height: 44)
                .background(Color.white.opacity(0.8))
                .cornerRadius(8)
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
    }
}

#Preview {
    SidebarButton(action: {})
        .padding()
} 