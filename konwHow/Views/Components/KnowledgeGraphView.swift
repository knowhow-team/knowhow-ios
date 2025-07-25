import SwiftUI
import Grape

struct KnowledgeGraphView: View {
    let myNodes = ["数据", "AI", "ML", "DL"]
    let myLinks = [("数据", "AI"), ("AI", "ML"), ("ML", "DL"), ("AI", "DL")]

    var body: some View {
        ForceDirectedGraph {
            Series(myNodes) { id in
                NodeMark(id: id)
                    .foregroundStyle(Color(red: 0.2, green: 0.8, blue: 0.4))
            }
            Series(myLinks) { from, to in
                LinkMark(from: from, to: to)
            }
        }
        .frame(height: 250)
        .background(Color.white)
        .cornerRadius(16)
        .padding(.horizontal, 20)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}
