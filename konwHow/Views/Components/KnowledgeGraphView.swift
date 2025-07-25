//
//  KnowledgeGraphView.swift
//  konwHow
//
//  Created by F1reC on 2025/7/25.
//

import SwiftUI
// import Grape  // 暂时屏蔽Grape

// 知识图谱节点模型
struct GraphNode: Identifiable {
    let id = UUID()
    let title: String
    let category: String
    let position: CGPoint
}

// 知识图谱连接模型
struct GraphEdge: Identifiable {
    let id = UUID()
    let from: UUID
    let to: UUID
}

// 最简单的Grape测试 - 暂时屏蔽
/*
struct SimpleGrapeTest: View {
    var body: some View {
        VStack {
            Text("Grape测试")
                .font(.headline)
            
            // 最简单的Graph测试
            Graph {
                NodeMark(id: "test") {
                    Circle()
                        .fill(.green)
                        .frame(width: 50, height: 50)
                    
                    Text("AI")
                        .font(.caption)
                        .foregroundColor(.white)
                }
            }
            .frame(height: 200)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
        .padding()
    }
}
*/

// Canvas知识图谱组件
struct CanvasKnowledgeGraphView: View {
    @State private var nodes: [GraphNode] = []
    @State private var edges: [GraphEdge] = []
    
    var body: some View {
        ZStack {
            // 背景 - 白色
            Color.white
                .ignoresSafeArea()
            
            // 使用Canvas绘制知识图谱
            Canvas { context, size in
                // 绘制连接线
                for edge in edges {
                    if let fromNode = nodes.first(where: { $0.id == edge.from }),
                       let toNode = nodes.first(where: { $0.id == edge.to }) {
                        
                        let path = Path { p in
                            p.move(to: fromNode.position)
                            p.addLine(to: toNode.position)
                        }
                        
                        context.stroke(path, with: .color(.green.opacity(0.4)), lineWidth: 2)
                    }
                }
                
                // 绘制节点
                for node in nodes {
                    let rect = CGRect(
                        x: node.position.x - 40,
                        y: node.position.y - 25,
                        width: 80,
                        height: 50
                    )
                    
                    // 节点背景
                    let nodePath = Path(roundedRect: rect, cornerRadius: 12)
                    context.fill(nodePath, with: .color(.white))
                    context.stroke(nodePath, with: .color(.green.opacity(0.3)), lineWidth: 2)
                    
                    // 节点文字
                    let text = Text(node.title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.black)
                    
                    context.draw(text, at: CGPoint(x: node.position.x, y: node.position.y))
                }
            }
            .frame(height: 250)
            .background(Color.white)
            .cornerRadius(16)
            .padding(.horizontal, 20)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        }
        .onAppear {
            setupGraphData()
        }
    }
    
    private func setupGraphData() {
        // 创建示例节点 - 使用固定位置
        nodes = [
            GraphNode(title: "AI", category: "tech", position: CGPoint(x: 120, y: 100)),
            GraphNode(title: "ML", category: "tech", position: CGPoint(x: 220, y: 80)),
            GraphNode(title: "DL", category: "tech", position: CGPoint(x: 320, y: 100)),
            GraphNode(title: "NLP", category: "tech", position: CGPoint(x: 170, y: 160)),
            GraphNode(title: "CV", category: "tech", position: CGPoint(x: 270, y: 160)),
            GraphNode(title: "RL", category: "tech", position: CGPoint(x: 200, y: 200)),
            GraphNode(title: "Data", category: "tech", position: CGPoint(x: 80, y: 180))
        ]
        
        // 创建连接关系
        edges = [
            GraphEdge(from: nodes[0].id, to: nodes[1].id), // AI -> ML
            GraphEdge(from: nodes[1].id, to: nodes[2].id), // ML -> DL
            GraphEdge(from: nodes[0].id, to: nodes[3].id), // AI -> NLP
            GraphEdge(from: nodes[0].id, to: nodes[4].id), // AI -> CV
            GraphEdge(from: nodes[2].id, to: nodes[5].id), // DL -> RL
            GraphEdge(from: nodes[3].id, to: nodes[5].id), // NLP -> RL
            GraphEdge(from: nodes[4].id, to: nodes[5].id), // CV -> RL
            GraphEdge(from: nodes[6].id, to: nodes[0].id), // Data -> AI
            GraphEdge(from: nodes[6].id, to: nodes[1].id)  // Data -> ML
        ]
    }
}

#Preview {
    CanvasKnowledgeGraphView()
} 