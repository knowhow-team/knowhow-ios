//
//  CommunityView.swift
//  konwHow
//
//  Created by F1reC on 2025/7/25.
//

import SwiftUI

struct CommunityView: View {
    var body: some View {
        ZStack {
            Color(red: 0.96, green: 0.98, blue: 0.96)
                .ignoresSafeArea()
            
            VStack {
                Text("社区")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.black)
                
                Text("社区功能开发中...")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
            }
        }
    }
}

#Preview {
    CommunityView()
} 