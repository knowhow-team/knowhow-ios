//
//  RecordingView.swift
//  konwHow
//
//  Created by F1reC on 2025/7/25.
//

import SwiftUI

struct RecordingView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var recordingTime: TimeInterval = 0
    @State private var isRecording = true
    @State private var showSaveOptions = false
    @State private var timer: Timer?
    
    var body: some View {
        ZStack {
            // 背景色 - 深紫红色
            Color(red: 0.4, green: 0.2, blue: 0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 录音网格区域
                VStack(spacing: 20) {
                    // 5x5网格小球
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 5), spacing: 12) {
                        ForEach(0..<25) { index in
                            Circle()
                                .fill(getCircleColor(for: index))
                                .frame(width: 40, height: 40)
                        }
                    }
                    .padding(.horizontal, 40)
                    .padding(.vertical, 40)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(red: 0.4, green: 0.2, blue: 0.4))
                    )
                    .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    // 底部控制区域
                    VStack(spacing: 30) {
                        // 录音时间显示
                        Text(timeString(from: recordingTime))
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.white)
                        
                        // 停止按钮
                        Button(action: {
                            stopRecording()
                        }) {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 80, height: 80)
                                .overlay(
                                    Image(systemName: "stop.fill")
                                        .font(.system(size: 32))
                                        .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.4))
                                )
                        }
                        .disabled(!isRecording)
                        
                        // 保存/丢弃选项
                        if showSaveOptions {
                            HStack(spacing: 60) {
                                // 丢弃按钮
                                Button(action: {
                                    discardRecording()
                                }) {
                                    VStack(spacing: 8) {
                                        Circle()
                                            .fill(Color.red)
                                            .frame(width: 50, height: 50)
                                            .overlay(
                                                Image(systemName: "xmark")
                                                    .font(.system(size: 24, weight: .bold))
                                                    .foregroundColor(.white)
                                            )
                                        
                                        Text("丢弃")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.white)
                                    }
                                }
                                
                                // 保存按钮
                                Button(action: {
                                    saveRecording()
                                }) {
                                    VStack(spacing: 8) {
                                        Circle()
                                            .fill(Color.green)
                                            .frame(width: 50, height: 50)
                                            .overlay(
                                                Image(systemName: "checkmark")
                                                    .font(.system(size: 24, weight: .bold))
                                                    .foregroundColor(.white)
                                            )
                                        
                                        Text("保存")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                            .transition(.opacity.combined(with: .scale))
                        }
                    }
                    .padding(.bottom, 60)
                }
            }
            
            // 返回按钮 - 左上角
            VStack {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(8)
                    }
                    .padding(.leading, 20)
                    .padding(.top, 60)
                    
                    Spacer()
                }
                Spacer()
            }
        }
        .onAppear {
            startRecording()
        }
        .onDisappear {
            stopTimer()
        }
    }
    
    // 根据录音时间和位置获取小球颜色
    private func getCircleColor(for index: Int) -> Color {
        let progress = recordingTime / 25.0 // 25秒完成所有小球
        let threshold = Double(index) / 25.0
        
        if progress >= threshold {
            return Color(red: 0.2, green: 0.8, blue: 0.4) // 绿色
        } else {
            return Color.white // 白色
        }
    }
    
    // 格式化时间显示
    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // 开始录音
    private func startRecording() {
        isRecording = true
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            recordingTime += 0.1
        }
    }
    
    // 停止录音
    private func stopRecording() {
        isRecording = false
        stopTimer()
        
        withAnimation(.easeInOut(duration: 0.3)) {
            showSaveOptions = true
        }
    }
    
    // 停止计时器
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // 丢弃录音
    private func discardRecording() {
        dismiss()
    }
    
    // 保存录音
    private func saveRecording() {
        // 这里可以添加保存录音的逻辑
        dismiss()
    }
}

#Preview {
    RecordingView()
} 