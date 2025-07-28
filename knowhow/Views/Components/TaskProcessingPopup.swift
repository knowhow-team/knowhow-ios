//
//  TaskProcessingPopup.swift
//  knowhow
//
//  Created by F1reC on 2025/7/26.
//

import SwiftUI

// MARK: - Shimmer Animation Manager

class ShimmerManager: ObservableObject {
    @Published private var phase: CGFloat = 0
    private var timer: Timer?
    
    var currentPhase: CGFloat {
        phase
    }
    
    func startShimmer() {
        guard timer == nil else { return }
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { _ in
            self.phase += 4 // 控制速度
            if self.phase > 300 {
                self.phase = -300 // 重置循环
            }
        }
    }
    
    func stopShimmer() {
        timer?.invalidate()
        timer = nil
    }
    
    deinit {
        stopShimmer()
    }
}

// MARK: - Shimmer Effect

struct ShimmerEffect: ViewModifier {
    @StateObject private var shimmerManager = ShimmerManager()
    
    func body(content: Content) -> some View {
        content
            .mask(
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.clear,
                                Color.white.opacity(0.3),
                                Color.white,
                                Color.white.opacity(0.3),
                                Color.clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .scaleEffect(x: 3, y: 1, anchor: .center)
                    .offset(x: shimmerManager.currentPhase)
            )
            .onAppear {
                shimmerManager.startShimmer()
            }
            .onDisappear {
                shimmerManager.stopShimmer()
            }
    }
}

extension View {
    func scalShimmer() -> some View {
        self.modifier(ShimmerEffect())
    }
}

// MARK: - Task Processing Popup

struct TaskProcessingPopup: View {
    let title: String
    let status: TaskStatus
    @Binding var isPresented: Bool
    
    // 添加关闭回调
    var onDismiss: (() -> Void)? = nil
    
    var body: some View {
        if isPresented {
            ZStack {
                // 背景遮罩
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        isPresented = false
                        onDismiss?()
                    }
                
                // 弹窗内容
                VStack(spacing: 20) {
                    // 状态图标
                    statusIcon
                    
                    // 标题
                    VStack(spacing: 8) {
                        Text("正在处理您的记录")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.gray)
                        
                        Text(title)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                            .scalShimmer()
                    }
                    
                    // 状态描述
                    Text(status.description)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                .padding(24)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.1), radius: 12, x: 0, y: 6)
                .padding(.horizontal, 40)
                .transition(.scale.combined(with: .opacity))
            }
        }
    }
    
    @ViewBuilder
    private var statusIcon: some View {
        switch status {
        case .waiting:
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 60, height: 60)
                
                Image(systemName: "clock.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.blue)
            }
            
        case .processing:
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.1))
                    .frame(width: 60, height: 60)
                
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 24))
                    .foregroundColor(.orange)
            }
            
        case .completed:
            ZStack {
                Circle()
                    .fill(Color.green)
                    .frame(width: 60, height: 60)
                
                Image(systemName: "checkmark")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        TaskProcessingPopup(
            title: "北京交通大学高考分数线出炉，640分能否圆梦？",
            status: .waiting,
            isPresented: .constant(true)
        )
        
        TaskProcessingPopup(
            title: "北京交通大学高考分数线出炉，640分能否圆梦？", 
            status: .processing,
            isPresented: .constant(true)
        )
        
        TaskProcessingPopup(
            title: "北京交通大学高考分数线出炉，640分能否圆梦？",
            status: .completed,
            isPresented: .constant(true)
        )
    }
    .background(Color(red: 0.96, green: 0.98, blue: 0.96))
}
