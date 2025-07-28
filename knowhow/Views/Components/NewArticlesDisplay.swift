//
//  NewArticlesDisplay.swift
//  knowhow
//
//  Created by F1reC on 2025/7/26.
//

import SwiftUI

// MARK: - New Articles Display

struct NewArticlesDisplay: View {
    let articlesWithBadges: [ArticleWithBadge]
    let onDismiss: () -> Void
    let onArticleTap: (Int) -> Void // 文章点击回调
    @State private var showCards = false
    
    var totalCount: Int {
        articlesWithBadges.count
    }
    
    // 动态计算窗口高度
    private var dynamicHeight: CGFloat {
        let cardHeight: CGFloat = 180 // 单个卡片估算高度（增加）
        let cardSpacing: CGFloat = 12 // 卡片间距
        let baseHeight: CGFloat = 200 // 标题、提示文字等固定高度
        
        let contentHeight = CGFloat(totalCount) * cardHeight + CGFloat(max(0, totalCount - 1)) * cardSpacing
        let totalHeight = baseHeight + contentHeight
        
        // 设置最小和最大高度限制
        let minHeight: CGFloat = 500 // 增加最小高度
        let maxHeight: CGFloat = UIScreen.main.bounds.height * 0.7
        
        return min(max(totalHeight, minHeight), maxHeight)
    }
    
    var body: some View {
        ZStack {
            // 背景遮罩（全透明）
            Color.clear
                .ignoresSafeArea()
                .contentShape(Rectangle()) // 让透明区域响应点击
                .onTapGesture {
                    onDismiss()
                }
            
            // 内容区域
            VStack(spacing: 20) {
                // 标题
                VStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 32))
                        .foregroundColor(Color(red: 0.2, green: 0.8, blue: 0.4))
                        .scaleEffect(showCards ? 1.2 : 1.0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showCards)
                    
                    Text("处理完成！")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text("为您生成了 \(totalCount) 篇知识文章")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }
                .padding(.top, 20)
                
                // 文章卡片列表
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(Array(articlesWithBadges.enumerated()), id: \.element.article.id) { index, articleWithBadge in
                            ZStack(alignment: .bottomTrailing) {
                                CommunityCard(
                                    article: articleWithBadge.article, 
                                    showAuthor: false,
                                    onTap: {
                                        onArticleTap(articleWithBadge.article.id)
                                    }
                                )
                                
                                // Badge - 右下角
                                HStack(spacing: 4) {
                                    Image(systemName: articleWithBadge.badgeType.icon)
                                        .font(.system(size: 11, weight: .medium))
                                    Text(articleWithBadge.badgeType.title)
                                        .font(.system(size: 11, weight: .medium))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(articleWithBadge.badgeType.color)
                                .cornerRadius(10)
                                .offset(x: -12, y: -12)
                            }
                            .scaleEffect(showCards ? 1.0 : 0.8)
                            .opacity(showCards ? 1.0 : 0.0)
                            .animation(
                                .spring(response: 0.8, dampingFraction: 0.9)
                                .delay(Double(index) * 0.1),
                                value: showCards
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .frame(maxHeight: dynamicHeight - 200) // 减去固定区域高度
                
                // 提示文本
                Text("点击空白处关闭")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .opacity(showCards ? 1.0 : 0.0)
                    .animation(.easeInOut(duration: 0.5).delay(1.0), value: showCards)
                
                Spacer(minLength: 20)
            }
            .frame(height: dynamicHeight)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.1), radius: 15, x: 0, y: 8)
            .padding(.horizontal, 20)
        }
        .onAppear {
            // 延迟显示动画，让弹窗有时间消失
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation {
                    showCards = true
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NewArticlesDisplay(
        articlesWithBadges: [
        ArticleWithBadge(
            article: Article(
                id: 1,
                title: "北京交通大学高考分数线出炉，640分能否圆梦？",
                summary: "本文记录了关于北京交通大学2025年高考录取分数线的重要信息。今年的录取分数线为640分，对于众多考生来说，这个分数既是挑战也是机遇。",
                status: "published",
                createdAt: "2025-07-26T03:01:07",
                updatedAt: "2025-07-26T03:01:07",
                finishedAt: "2025-07-26T03:01:20",
                tags: [
                    ArticleTag(id: 1, name: "高考"),
                    ArticleTag(id: 2, name: "北京交通大学"),
                    ArticleTag(id: 3, name: "录取分数线")
                ],
                author: nil
            ),
            badgeType: .created
        ),
        ArticleWithBadge(
            article: Article(
                id: 2,
                title: "教育资讯：高等教育录取趋势分析",
                summary: "随着高等教育的不断发展，各大高校的录取标准和趋势也在发生变化。本文将从多个角度分析当前的教育形势。",
                status: "published",
                createdAt: "2025-07-26T03:01:07",
                updatedAt: "2025-07-26T03:01:07",
                finishedAt: "2025-07-26T03:01:25",
                tags: [
                    ArticleTag(id: 4, name: "教育"),
                    ArticleTag(id: 5, name: "高等教育"),
                    ArticleTag(id: 6, name: "趋势分析")
                ],
                author: nil
            ),
            badgeType: .updated
        )
    ],
        onDismiss: { },
        onArticleTap: { _ in }
    )
    .background(Color(red: 0.96, green: 0.98, blue: 0.96))
}
