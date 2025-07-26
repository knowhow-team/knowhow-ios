//
//  DotMatrixVisualizer.swift
//  konwHow
//
//  Created by F1reC on 2025/7/26.
//

import SwiftUI
import Foundation

// MARK: - Dot Matrix Visualizer

struct DotMatrixVisualizer: View {
    // 接收来自 SpeechManager 的实时音量 (0.0 - 1.0)
    var power: CGFloat
    // 录音状态
    var isRecording: Bool
    // 暂停状态
    var isPaused: Bool
    
    // 网格配置
    private let gridSize = 15 // 15x15 = 225个点
    private let dotSize: CGFloat = 10 // 调整为10pt
    private let dotSpacing: CGFloat = 6
    
    // 状态管理
    @State private var activeDots: Set<Int> = []
    @State private var updateTimer: Timer?
    
    // 颜色定义
    private let activeColor = Color(red: 0.2, green: 0.8, blue: 0.4) // 录音按钮同色
    private let pausedColor = Color.gray.opacity(0.6) // 暂停状态灰色
    private let inactiveColor = Color.black.opacity(0.1) // 进一步降低透明度
    
    var body: some View {
        // 点阵可视化 - 居中显示
        VStack(spacing: dotSpacing) {
            ForEach(0..<gridSize, id: \.self) { row in
                HStack(spacing: dotSpacing) {
                    ForEach(0..<gridSize, id: \.self) { col in
                        let dotIndex = row * gridSize + col
                        
                        // 根据状态显示不同颜色的圆点
                        if isPaused && activeDots.contains(dotIndex) {
                            // 暂停状态：显示灰色圆点
                            Circle()
                                .fill(pausedColor)
                                .frame(width: dotSize, height: dotSize)
                                .animation(.easeInOut(duration: 0.15), value: activeDots.contains(dotIndex))
                        } else if isRecording && activeDots.contains(dotIndex) {
                            // 录音状态：显示绿色圆点
                            Circle()
                                .fill(activeColor)
                                .frame(width: dotSize, height: dotSize)
                                .animation(.easeInOut(duration: 0.15), value: activeDots.contains(dotIndex))
                        } else {
                            // 占位空间，但不显示任何内容
                            Spacer()
                                .frame(width: dotSize, height: dotSize)
                        }
                    }
                }
            }
        }
        .onAppear {
            startVolumeMonitoring()
        }
        .onDisappear {
            stopVolumeMonitoring()
        }
        .onChange(of: power) { _ in
            // 立即响应音量变化，不等待定时器
            updateActiveDots()
        }
    }
    
    // MARK: - Private Methods
    
    private func startVolumeMonitoring() {
        // 每0.2秒更新一次点阵
        updateTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { _ in
            updateActiveDots()
        }
        
        // 立即执行一次
        updateActiveDots()
    }
    
    private func stopVolumeMonitoring() {
        updateTimer?.invalidate()
        updateTimer = nil
    }
    
    private func updateActiveDots() {
        // 如果暂停状态，显示固定大圆
        if isPaused {
            let centerRow = CGFloat(gridSize / 2)
            let centerCol = CGFloat(gridSize / 2)
            let pausedRadius: CGFloat = 4.0 // 固定的大圆半径
            
            var pausedDots = Set<Int>()
            for row in 0..<gridSize {
                for col in 0..<gridSize {
                    let distance = sqrt(pow(CGFloat(row) - centerRow, 2) + pow(CGFloat(col) - centerCol, 2))
                    if distance <= pausedRadius {
                        let dotIndex = row * gridSize + col
                        pausedDots.insert(dotIndex)
                    }
                }
            }
            
            withAnimation(.easeInOut(duration: 0.15)) {
                activeDots = pausedDots
            }
            return
        }
        
        // 如果不在录音且不暂停，清空所有亮点
        guard isRecording else {
            withAnimation(.easeInOut(duration: 0.15)) {
                activeDots = []
            }
            return
        }
        
        // 根据音量计算圆的半径 - 新阈值映射
        let minVolumeThreshold: CGFloat = 0.4  // 音量阈值：0.4对应最小圆
        let maxVolumeThreshold: CGFloat = 0.8  // 音量阈值：0.8对应全屏
        
        let minRadius: CGFloat = 0.8  // 最小圆半径
        let maxRadius: CGFloat = 10.0 // 全屏半径（确保覆盖整个15x15网格）
        
        // 将power映射到新的阈值范围
        let clampedPower = max(0.0, min(1.0, (power - minVolumeThreshold) / (maxVolumeThreshold - minVolumeThreshold)))
        let currentRadius = minRadius + clampedPower * (maxRadius - minRadius)
        
        // 中心点坐标（网格中心）
        let centerRow = CGFloat(gridSize / 2)  // 7.0
        let centerCol = CGFloat(gridSize / 2)  // 7.0
        
        // 计算哪些点应该亮起（形成同心圆）
        var newActiveDots = Set<Int>()
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                // 计算当前点到中心的欧几里得距离
                let distance = sqrt(pow(CGFloat(row) - centerRow, 2) + pow(CGFloat(col) - centerCol, 2))
                
                // 如果距离小于等于当前半径，则该点亮起
                if distance <= currentRadius {
                    let dotIndex = row * gridSize + col
                    newActiveDots.insert(dotIndex)
                }
            }
        }
        
        withAnimation(.easeInOut(duration: 0.15)) {
            activeDots = newActiveDots
        }
    }
    
}

// MARK: - Preview

#Preview {
    VStack(spacing: 40) {
        Text("未录音状态")
        DotMatrixVisualizer(power: 0.5, isRecording: false, isPaused: false)
        
        Text("录音中 - 中等音量 (power: 0.5)")
        DotMatrixVisualizer(power: 0.5, isRecording: true, isPaused: false)
        
        Text("暂停状态 - 灰色大圆")
        DotMatrixVisualizer(power: 0.5, isRecording: false, isPaused: true)
    }
    .padding()
    .background(Color.white)
}