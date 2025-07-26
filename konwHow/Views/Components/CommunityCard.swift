//
//  CommunityCard.swift
//  konwHow
//
//  Created by F1reC on 2025/7/26.
//

import SwiftUI

struct CommunityCard: View {
    let article: Article
    let showAuthor: Bool
    let onTap: (() -> Void)?
    
    init(article: Article, showAuthor: Bool = true, onTap: (() -> Void)? = nil) {
        self.article = article
        self.showAuthor = showAuthor
        self.onTap = onTap
    }
    
    var body: some View {
        Button(action: {
            onTap?()
        }) {
            VStack(alignment: .leading, spacing: 0) {
                // 卡片内容区域
                VStack(alignment: .leading, spacing: showAuthor ? 12 : 10) {
                    // 标题
                    Text(article.title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                    
                    // 描述
                    Text(article.summary)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.leading)
                        .lineLimit(3)
                    
                    Spacer(minLength: showAuthor ? 8 : 4)
                    
                    // 底部区域：Tags 和 作者信息
                    HStack(alignment: .center) {
                        // 左下角：Tags
                        if !article.tags.isEmpty {
                            TagsRow(tags: article.tags)
                        }
                        
                        Spacer()
                        
                        // 右下角：作者信息（可选显示）
                        if showAuthor, let author = article.author {
                            AuthorInfo(author: author)
                        }
                    }
                }
                .padding(showAuthor ? 16 : 14)
            }
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(onTap == nil)
    }
}

// MARK: - CommunityCard Extension for KnowledgeItem
extension CommunityCard {
    init(knowledgeItem: KnowledgeItem, showAuthor: Bool = false, onTap: (() -> Void)? = nil) {
        // 将KnowledgeItem转换为Article格式
        let tags = knowledgeItem.category.split(separator: ",").enumerated().map { index, tagName in
            ArticleTag(id: index, name: String(tagName.trimmingCharacters(in: .whitespaces)))
        }
        
        let article = Article(
            id: knowledgeItem.id.hashValue,
            title: knowledgeItem.title,
            summary: knowledgeItem.description,
            status: "published",
            createdAt: "",
            updatedAt: nil,
            finishedAt: nil,
            tags: tags,
            author: nil
        )
        
        self.article = article
        self.showAuthor = showAuthor
        self.onTap = onTap
    }
}

// MARK: - Tags Row Component
struct TagsRow: View {
    let tags: [ArticleTag]
    let maxDisplayTags = 3
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(Array(tags.prefix(maxDisplayTags)), id: \.id) { tag in
                CommunityTagView(tagName: tag.name)
            }
            
            // 如果标签数量超过最大显示数量，显示 "+N"
            if tags.count > maxDisplayTags {
                Text("+\(tags.count - maxDisplayTags)")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.gray)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(4)
            }
        }
    }
}

// MARK: - Community Tag View Component
struct CommunityTagView: View {
    let tagName: String
    
    var body: some View {
        HStack(spacing: 0) {
            Text("#")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Color(red: 0.2, green: 0.6, blue: 0.3)) // 深绿色
            
            Text(tagName)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.black)
                .lineLimit(1)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(Color.gray.opacity(0.08))
        .cornerRadius(4)
    }
}

// MARK: - Author Info Component
struct AuthorInfo: View {
    let author: ArticleAuthor
    
    var body: some View {
        HStack(spacing: 6) {
            // 头像
            AvatarView(
                avatarUrl: author.avatarUrl,
                username: author.username,
                size: 26
            )
            
            // 用户名
            Text(author.username)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.gray)
                .lineLimit(1)
        }
    }
}

// MARK: - Avatar View Component
struct AvatarView: View {
    let avatarUrl: String
    let username: String
    let size: CGFloat
    
    private var firstLetter: String {
        String(username.prefix(1)).uppercased()
    }
    
    private var hasValidAvatarUrl: Bool {
        !avatarUrl.isEmpty && avatarUrl != ""
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color(red: 0.2, green: 0.8, blue: 0.4))
                .frame(width: size, height: size)
            
            if hasValidAvatarUrl {
                // 如果有头像URL，尝试加载网络图片
                AsyncImage(url: URL(string: avatarUrl)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: size, height: size)
                        .clipShape(Circle())
                } placeholder: {
                    // 加载中显示首字母
                    Text(firstLetter)
                        .font(.system(size: size * 0.4, weight: .bold))
                        .foregroundColor(.white)
                }
            } else {
                // 没有头像URL，显示用户名首字母
                Text(firstLetter)
                    .font(.system(size: size * 0.4, weight: .bold))
                    .foregroundColor(.white)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 16) {
        // 社区卡片样式（显示作者信息）
        CommunityCard(article: Article(
            id: 1,
            title: "小米汽车SU7、雷军与北京：科技巨头的跨界之作",
            summary: "本文介绍了小米公司的首款电动汽车小米SU7及其创始人雷军。近期，小米SU7在北京引起了广泛关注，这款车型不仅是小米跨界造车的标志性产品，也与雷军的个人影响力紧密相连。",
            status: "published",
            createdAt: "2025-07-25T18:14:49",
            updatedAt: "2025-07-25T18:14:49",
            finishedAt: "2025-07-25T18:15:57",
            tags: [
                ArticleTag(id: 1, name: "智能汽车"),
                ArticleTag(id: 2, name: "跨界造车"),
                ArticleTag(id: 3, name: "雷军IP"),
                ArticleTag(id: 4, name: "北京科技")
            ],
            author: ArticleAuthor(
                id: 1,
                username: "熔熔",
                avatarUrl: ""
            )
        ), showAuthor: true)
        
        // 知识库卡片样式（不显示作者信息）
        CommunityCard(article: Article(
            id: 2,
            title: "北京交通大学学生生活：美食与运动",
            summary: "本文记录了一位北京交通大学学生的日常生活片段，提到了校园周边的特色美食如明湖烤鸭，以及篮球作为其重要的日常运动和精神寄托。",
            status: "published",
            createdAt: "2025-07-25T20:03:48",
            updatedAt: "2025-07-25T20:03:48",
            finishedAt: "2025-07-25T20:17:30",
            tags: [
                ArticleTag(id: 14, name: "校园生活"),
                ArticleTag(id: 15, name: "美食体验"),
                ArticleTag(id: 16, name: "运动文化")
            ],
            author: ArticleAuthor(
                id: 2,
                username: "张三",
                avatarUrl: "https://example.com/avatar.jpg"
            )
        ), showAuthor: false)
    }
    .padding(20)
    .background(Color(red: 0.96, green: 0.98, blue: 0.96))
}