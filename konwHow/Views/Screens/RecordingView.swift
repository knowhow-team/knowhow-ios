//
//  RecordingView.swift
//  konwHow
//
//  Created by F1reC on 2025/7/25.
//

import SwiftUI

struct RecordingView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var speechManager = SpeechRecognitionManager()
    @State private var recordingTime: TimeInterval = 0
    @State private var showSaveOptions = false
    @State private var timer: Timer?
    
    var body: some View {
        ZStack {
            // 背景色 - 白色，与主页面一致
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
                VStack(spacing: 40) {
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
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(red: 0.96, green: 0.98, blue: 0.96))
                        )
                        .padding(.horizontal, 20)
                    }
                    
                    // 语音转文字显示区域
                    VStack(spacing: 12) {
                        Text("实时转文字")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.black.opacity(0.7))
                        
                        ScrollView {
                            VStack(spacing: 8) {
                                Text(speechManager.transcribedText.isEmpty ? "正在聆听..." : speechManager.transcribedText)
                                    .font(.system(size: 16, weight: .regular))
                                    .foregroundColor(speechManager.transcribedText.isEmpty ? .gray : .black)
                                    .multilineTextAlignment(.leading)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color(red: 0.96, green: 0.98, blue: 0.96))
                                    )
                                    .padding(.horizontal, 20)
                                
                                // 错误信息显示
                                if !speechManager.errorMessage.isEmpty {
                                    Text(speechManager.errorMessage)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.red)
                                        .padding(.horizontal, 20)
                                }
                                
                                // 调试信息
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("权限状态: \(speechManager.isAuthorized ? "已授权" : "未授权")")
                                        .font(.system(size: 12))
                                        .foregroundColor(.gray)
                                    Text("录音状态: \(speechManager.isRecording ? "录音中" : "已停止")")
                                        .font(.system(size: 12))
                                        .foregroundColor(.gray)
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                        .frame(maxHeight: 120)
                    }
                    
                    // 底部控制区域
                    VStack(spacing: 30) {
                        // 录音时间显示
                        Text(timeString(from: recordingTime))
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.black)
                        
                        // 停止按钮
                        Button(action: {
                            print("停止按钮被点击")
                            stopRecording()
                        }) {
                            Circle()
                                .fill(Color(red: 0.2, green: 0.8, blue: 0.4))
                                .frame(width: 80, height: 80)
                                .overlay(
                                    Image(systemName: "stop.fill")
                                        .font(.system(size: 32))
                                        .foregroundColor(.white)
                                )
                                .shadow(color: Color(red: 0.2, green: 0.8, blue: 0.4).opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .disabled(!speechManager.isRecording)
                        
                        // 如果权限未授权，显示开始录音按钮
                        if !speechManager.isAuthorized {
                            Button(action: {
                                print("手动开始录音按钮被点击")
                                speechManager.requestSpeechAuthorization()
                            }) {
                                Text("开始录音")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 12)
                                    .background(Color(red: 0.2, green: 0.8, blue: 0.4))
                                    .cornerRadius(8)
                            }
                        }
                        
                        // 调试按钮 - 手动触发录音
                        Button(action: {
                            print("调试按钮被点击")
                            if speechManager.isAuthorized {
                                speechManager.startRecording()
                                // 开始计时器
                                timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                                    recordingTime += 0.1
                                }
                            } else {
                                print("权限未授权，无法开始录音")
                            }
                        }) {
                            Text("调试：手动开始录音")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.blue)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(6)
                        }
                        
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
                                            .shadow(color: Color.red.opacity(0.3), radius: 6, x: 0, y: 3)
                                        
                                        Text("丢弃")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.black)
                                    }
                                }
                                
                                // 保存按钮
                                Button(action: {
                                    saveRecording()
                                }) {
                                    VStack(spacing: 8) {
                                        Circle()
                                            .fill(Color(red: 0.2, green: 0.8, blue: 0.4))
                                            .frame(width: 50, height: 50)
                                            .overlay(
                                                Image(systemName: "checkmark")
                                                    .font(.system(size: 24, weight: .bold))
                                                    .foregroundColor(.white)
                                            )
                                            .shadow(color: Color(red: 0.2, green: 0.8, blue: 0.4).opacity(0.3), radius: 6, x: 0, y: 3)
                                        
                                        Text("保存")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.black)
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
        .onAppear {
            print("RecordingView appeared")
            // 确保权限已请求
            if !speechManager.isAuthorized {
                speechManager.requestSpeechAuthorization()
            }
            startRecording()
        }
        .onChange(of: speechManager.isAuthorized) { newValue in
            print("权限状态变化: \(newValue)")
            if newValue && !speechManager.isRecording {
                // 权限获取后，如果还没开始录音，则开始录音
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    speechManager.startRecording()
                    // 开始计时器
                    self.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                        self.recordingTime += 0.1
                    }
                }
            }
        }
        .onDisappear {
            print("RecordingView disappeared")
            stopRecording()
        }
    }
    
    // 根据录音时间和位置获取小球颜色
    private func getCircleColor(for index: Int) -> Color {
        let progress = recordingTime / 25.0 // 25秒完成所有小球
        let threshold = Double(index) / 25.0
        
        if progress >= threshold {
            return Color(red: 0.2, green: 0.8, blue: 0.4) // 绿色
        } else {
            return Color.gray.opacity(0.3) // 浅灰色，与主页面风格一致
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
        print("开始录音...")
        
        // 如果权限未授权，先请求权限
        if !speechManager.isAuthorized {
            speechManager.requestSpeechAuthorization()
            // 权限获取后会自动开始录音（通过onChange监听）
        } else {
            speechManager.startRecording()
            // 开始计时器
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                recordingTime += 0.1
            }
        }
    }
    
    // 停止录音
    private func stopRecording() {
        print("停止录音...")
        speechManager.stopRecording()
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
        // 这里可以添加保存录音和文字的逻辑
        print("保存的语音转文字内容: \(speechManager.getTranscribedText())")
        dismiss()
    }
}

#Preview {
    RecordingView()
} 