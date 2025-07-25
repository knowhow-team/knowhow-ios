import SwiftUI
import Grape
import ForceSimulation

struct KnowledgeGraphView: View {
    let myNodes = ["数据", "AI", "ML", "DL", "NLP", "CV"]
    let myLinks = [("数据", "AI"), ("AI", "ML"), ("ML", "DL"), ("AI", "NLP"), ("AI", "CV"), ("ML", "DL")]
    
    @State var graphStates = ForceDirectedGraphState(
        ticksOnAppear: .untilStable
    )
    
    @State var draggingNodeID: String? = nil
    
    static let strokeStyle = StrokeStyle(lineWidth: 2.0, lineCap: .round, lineJoin: .round)
    
    var body: some View {
        ForceDirectedGraph(states: graphStates) {
            Series(myNodes) { id in
                NodeMark(id: id)
                    .symbolSize(radius: 25.0)
                    .foregroundStyle(Color(red: 0.2, green: 0.8, blue: 0.4))
                    .stroke(id == draggingNodeID ? .secondary : .clear, Self.strokeStyle)
            }
            Series(myLinks) { from, to in
                LinkMark(from: from, to: to)
            }
            .stroke(Color(red: 0.2, green: 0.8, blue: 0.4).opacity(0.6), Self.strokeStyle)
            
        } force: {
            .manyBody(strength: -80)
            .link(
                originalLength: 60.0,
                stiffness: .weightedByDegree { _, _ in 1.0 }
            )
            .center()
            .collide(radius: .constant(30))
        }
        .graphOverlay { proxy in
            Rectangle().fill(.clear).contentShape(Rectangle())
                .withGraphDragGesture(proxy, of: String.self, action: handleDragState)
                .withGraphMagnifyGesture(proxy)
        }
        .frame(height: 250)
        .background(Color.white)
        .cornerRadius(16)
        .padding(.horizontal, 20)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    func handleDragState(_ state: GraphDragState<String>?) {
        switch state {
        case .node(let id):
            if draggingNodeID != id {
                draggingNodeID = id
                print("正在拖动节点: \(id)")
            }
        case .background(let start):
            draggingNodeID = nil
            print("拖动背景: \(start)")
        case nil:
            draggingNodeID = nil
            print("拖动结束")
        }
    }
}
