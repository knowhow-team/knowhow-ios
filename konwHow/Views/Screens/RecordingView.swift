//
//  RecordingView.swift
//  konwHow
//
//  Created by F1reC on 2025/7/25.
//
//  --- 优化版本 ---
//

import SwiftUI

// MARK: - SiriWaveView (音频可视化核心)

/// 绘制单条正弦波的 Shape
struct SineWave: Shape {
    var phase: CGFloat
    var power: CGFloat // 音量 (0.0 - 1.0)
    var waveIndex: Int

    // 使 phase 和 power 属性支持动画
    var animatableData: AnimatablePair<CGFloat, CGFloat> {
        get { AnimatablePair(phase, power) }
        set {
            self.phase = newValue.first
            self.power = newValue.second
        }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.width
        let height = rect.height
        let midHeight = height / 2
        
        // 根据波形索引调整频率和振幅，制造层次感
        let frequencyMultiplier = (waveIndex == 1) ? 1.5 : 1.0
        let amplitudeMultiplier = (waveIndex == 0) ? 1.2 : 0.8
        
        // 振幅由音量 power 控制，基础振幅保证在静音时也有微弱波动
        let amplitude = (max(0.05, power) * midHeight * 0.7) * amplitudeMultiplier
        
        path.move(to: CGPoint(x: 0, y: midHeight))
        
        for x in stride(from: 0, to: width, by: 1) {
            let relativeX = x / width
            // 使用 phase 产生流动效果，使用 waveIndex 错开不同波形
            let sine = sin(relativeX * .pi * 2 * frequencyMultiplier + phase + CGFloat(waveIndex * 2))
            let y = midHeight + sine * amplitude
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        return path
    }
}

/// Siri 风格的波形视图
struct SiriWaveView: View {
    // 接收来自 SpeechManager 的实时音量 (0.0 - 1.0)
    var power: CGFloat
    
    @State private var phase: CGFloat = 0.0
    
    var body: some View {
        ZStack {
            // 绘制三条不同颜色和形态的正弦波，形成层次感
            ForEach(0..<3) { index in
                SineWave(phase: self.phase, power: self.power, waveIndex: index)
                    .stroke(waveColor(for: index), lineWidth: 2.5)
            }
        }
        .onAppear(perform: startAnimation)
    }
    
    private func waveColor(for index: Int) -> LinearGradient {
        switch index {
        case 0:
            return LinearGradient(colors: [.blue.opacity(0.9), .purple.opacity(0.7)], startPoint: .leading, endPoint: .trailing)
        case 1:
            return LinearGradient(colors: [.cyan.opacity(0.8), .blue.opacity(0.6)], startPoint: .leading, endPoint: .trailing)
        default:
            return LinearGradient(colors: [.purple.opacity(0.6), .pink.opacity(0.5)], startPoint: .leading, endPoint: .trailing)
        }
    }
    
    private func startAnimation() {
        // 使用 Timer 平滑地改变相位，产生流动的效果
        Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { _ in
            withAnimation(.linear(duration: 0.02)) {
                self.phase -= 0.05 // 调整此值可改变流动速度
            }
        }
    }
}


// MARK: - RecordingView (主视图)

struct RecordingView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var speechManager = SpeechRecognitionManager()
    
    @State private var recordingTime: TimeInterval = 0
    @State private var showSaveOptions = false
    @State private var timer: Timer?
    @State private var showLanguageSelector = false
    @State private var isPaused = false
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 20) {
                headerView
                
                visualizationArea
                
                transcriptionArea
                
                controlsArea
                
                Spacer()
            }
            .padding(.bottom, 20)
            
            backButton
        }
        .onAppear(perform: setupView)
        .onDisappear(perform: cleanupView)
        .onChange(of: speechManager.isAuthorized, perform: handleAuthChange)
    }
    
    // MARK: - Subviews
    
    private var headerView: some View {
        HStack {
            Text("Cody")
                .font(.system(size: 42, weight: .black)).italic()
                .foregroundColor(.black)
            
            Spacer()
            
            Button(action: { showLanguageSelector.toggle() }) {
                HStack(spacing: 4) {
                    Image(systemName: "globe")
                    Text(getLanguageDisplayText())
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.blue)
                .padding(.horizontal, 12).padding(.vertical, 6)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
            }
            .actionSheet(isPresented: $showLanguageSelector) {
                ActionSheet(title: Text("选择识别语言"), buttons: createLanguageButtons())
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
    
    private var visualizationArea: some View {
        ZStack {
            // 背景
            RoundedRectangle(cornerRadius: 20)
                .fill(LinearGradient(colors: [Color(red: 0.98, green: 0.99, blue: 1.0), Color(red: 0.95, green: 0.97, blue: 0.99)], startPoint: .top, endPoint: .bottom))
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.blue.opacity(0.1), lineWidth: 1))

            // 实时音频可视化
            SiriWaveView(power: CGFloat(speechManager.audioLevel))
                .padding(.horizontal, 20)
            
            // 中心麦克风图标
            Image(systemName: speechManager.isRecording ? "waveform" : "mic.fill")
                .font(.system(size: 32, weight: .medium))
                .foregroundColor(.white)
                .frame(width: 80, height: 80)
                .background(
                    Circle().fill(
                        LinearGradient(
                            colors: speechManager.isRecording ? [.blue, .purple] : [.gray.opacity(0.6), .gray.opacity(0.4)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
                )
                // 动画与录音状态和音量挂钩
                .scaleEffect(speechManager.isRecording ? 1.1 + CGFloat(speechManager.audioLevel) * 0.2 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: speechManager.isRecording)
                .animation(.spring(response: 0.2, dampingFraction: 0.5), value: speechManager.audioLevel)
        }
        .frame(height: 180)
        .padding(.horizontal, 20)
    }
    
    private var transcriptionArea: some View {
        VStack(spacing: 12) {
            HStack {
                Text("实时转文字")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black.opacity(0.7))
                Spacer()
                if !speechManager.transcribedText.isEmpty {
                    Button(action: speechManager.clearText) {
                        Image(systemName: "trash").foregroundColor(.gray)
                    }
                }
            }
            .padding(.horizontal, 20)
            
            ScrollView {
                Text(getDisplayText())
                    .font(.system(size: 16))
                    .foregroundColor(speechManager.transcribedText.isEmpty ? .gray : .black)
                    .frame(maxWidth: .infinity, minHeight: 100, alignment: .topLeading)
                    .padding(20)
                    .background(Color(red: 0.96, green: 0.98, blue: 0.96).cornerRadius(12))
                    .padding(.horizontal, 20)
            }
            .frame(maxHeight: .infinity)
            
            if !speechManager.errorMessage.isEmpty {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                    Text(speechManager.errorMessage)
                }
                .font(.footnote).foregroundColor(.red)
                .padding(8).background(Color.red.opacity(0.1)).cornerRadius(8)
                .padding(.horizontal, 20)
            }
        }
    }
    
    private var controlsArea: some View {
        VStack(spacing: 25) {
            HStack {
                if speechManager.isRecording {
                    Circle().fill(Color.red).frame(width: 12, height: 12)
                        .scaleEffect(1.0 + CGFloat(speechManager.audioLevel) * 0.5)
                        .animation(.spring(), value: speechManager.audioLevel)
                } else if isPaused {
                    Image(systemName: "pause.fill").foregroundColor(.orange)
                }
                Text(timeString(from: recordingTime))
                    .font(.system(size: 24, weight: .medium)).monospacedDigit()
            }
            
            if showSaveOptions {
                saveDiscardButtons
            } else {
                recordingControlButtons
            }
        }
    }
    
    @ViewBuilder
    private var recordingControlButtons: some View {
        if !speechManager.isAuthorized {
            Button(action: speechManager.requestSpeechAuthorization) {
                Text("获取语音权限").fontWeight(.bold).foregroundColor(.white)
                    .padding().background(Color.blue).cornerRadius(12)
            }
        } else {
            HStack(spacing: 40) {
                if speechManager.isRecording {
                    // 暂停按钮
                    controlButton(icon: "pause.fill", color: .orange, action: pauseRecording)
                    // 停止按钮
                    controlButton(icon: "stop.fill", color: .green, action: stopAndFinalize)
                } else if isPaused {
                    // 继续按钮
                    controlButton(icon: "play.fill", color: .blue, action: resumeRecording)
                    // 停止按钮
                    controlButton(icon: "stop.fill", color: .green, action: stopAndFinalize)
                } else {
                    // 开始按钮
                    controlButton(icon: "mic.fill", color: .blue, size: 80, action: startRecording)
                }
            }
        }
    }
    
    private var saveDiscardButtons: some View {
        HStack(spacing: 60) {
            // 丢弃按钮
            optionButton(icon: "xmark", text: "丢弃", color: .red, action: discardRecording)
            // 保存按钮
            optionButton(icon: "checkmark", text: "保存", color: .green, action: saveRecording)
                .disabled(speechManager.transcribedText.isEmpty)
        }
        .transition(.opacity.combined(with: .scale))
    }
    
    private var backButton: some View {
        VStack {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.black)
                        .frame(width: 44, height: 44)
                        .background(Color.white.opacity(0.8).cornerRadius(8))
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                }
                Spacer()
            }
            Spacer()
        }
        .padding(.leading, 20).padding(.top, 20)
    }
    
    // MARK: - Helper Views
    
    private func controlButton(icon: String, color: Color, size: CGFloat = 60, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: size * 0.4, weight: .bold))
                .foregroundColor(.white)
                .frame(width: size, height: size)
                .background(LinearGradient(colors: [color, color.opacity(0.7)], startPoint: .top, endPoint: .bottom))
                .clipShape(Circle())
                .shadow(color: color.opacity(0.4), radius: 8, y: 4)
        }
    }
    
    private func optionButton(icon: String, text: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                controlButton(icon: icon, color: color, size: 50, action: {})
                    .disabled(true) // 让父按钮接管事件
                Text(text).font(.system(size: 14, weight: .medium)).foregroundColor(.black)
            }
        }
    }
    
    // MARK: - Logic & Helper Functions
    
    private func setupView() {
        if !speechManager.isAuthorized {
            speechManager.requestSpeechAuthorization()
        }
    }
    
    private func cleanupView() {
        speechManager.stopRecording()
        stopTimer()
    }
    
    private func handleAuthChange(isAuthorized: Bool) {
        if isAuthorized && !speechManager.isRecording && !isPaused && !showSaveOptions {
            // 授权后自动开始录音
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                startRecording()
            }
        }
    }
    
    private func startRecording() {
        isPaused = false
        showSaveOptions = false
        speechManager.clearText()
        recordingTime = 0
        speechManager.startRecording()
        startTimer()
    }
    
    private func pauseRecording() {
        speechManager.pause() // 使用 manager 的 pause 方法
        stopTimer()
        isPaused = true
    }
    
    private func resumeRecording() {
        isPaused = false
        speechManager.startRecording() // 直接调用 start 即可，manager 内部会处理
        startTimer()
    }
    
    private func stopAndFinalize() {
        speechManager.stopRecording()
        stopTimer()
        isPaused = false
        withAnimation {
            showSaveOptions = true
        }
    }
    
    private func discardRecording() {
        speechManager.clearText()
        dismiss()
    }
    
    private func saveRecording() {
        print("保存的文本: \(speechManager.transcribedText)")
        dismiss()
    }
    
    private func startTimer() {
        stopTimer() // 确保没有重复的计时器
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            recordingTime += 0.1
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func getDisplayText() -> String {
        if !speechManager.transcribedText.isEmpty {
            return speechManager.transcribedText
        }
        if speechManager.isRecording {
            return "正在聆听..."
        }
        if isPaused {
            return "录音已暂停，点击 ▶️ 继续"
        }
        if !speechManager.isAuthorized {
            return "请授予麦克风和语音识别权限"
        }
        return "点击 🎤 开始录音"
    }
    
    private func getLanguageDisplayText() -> String {
        speechManager.getSupportedLanguages()[speechManager.currentLanguage] ?? "未知"
    }
    
    private func createLanguageButtons() -> [ActionSheet.Button] {
        var buttons: [ActionSheet.Button] = speechManager.getSupportedLanguages()
            .sorted(by: { $0.value < $1.value })
            .map { code, name in
                .default(Text(name)) { speechManager.switchLanguage(to: code) }
            }
        buttons.append(.cancel())
        return buttons
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - Preview
#Preview {
    RecordingView()
}
