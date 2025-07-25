//
//  VoiceRecordView.swift
//  konwHow
//
//  Created by F1reC on 2025/7/25.
//

import SwiftUI

struct VoiceRecordView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // 背景色 - 白色
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 顶部区域 - 包含Cody标题
                VStack(spacing: 8) {
                    // Cody 标题
                    Text("Cody")
                        .font(.system(size: 42, weight: .black))
                        .italic()
                        .foregroundColor(.black)
                }
                .padding(.top, 40)
                .padding(.bottom, 20)
                
                // 主内容区域
                ScrollView {
                    VStack(spacing: 12) {
                        // 语音记录卡片
                        ForEach(0..<3) { index in
                            VoiceRecordCard(
                                timestamp: "21:32 7.24-2025",
                                content: "adx 是中国最大的一场黑客松，2025年有871人参加，参与人数众多，氛围热烈！"
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 120) // 避免Tab栏遮挡
                }
                
                Spacer()
            }
            
            // 返回按钮 - 左上角
            VStack {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.black)
                            .frame(width: 44, height: 44)
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(8)
                            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                    }
                    .padding(.leading, 20)
                    .padding(.top, 60)
                    
                    Spacer()
                }
                Spacer()
            }
        }
    }
}

// 语音记录卡片组件
struct VoiceRecordCard: View {
    let timestamp: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 时间戳
            Text(timestamp)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.black)
            
            // 语音内容
            Text(content)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.black.opacity(0.7))
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
                .lineSpacing(2)
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
    VoiceRecordView()
} 