//
//  SpeechRecognitionManager.swift
//  konwHow
//
//  Created by F1reC on 2025/7/25.
//

import Foundation
import Speech
import AVFoundation
import SwiftUI

class SpeechRecognitionManager: NSObject, ObservableObject {
    // ... (已有属性保持不变)
    @Published var transcribedText = ""
    @Published var isRecording = false
    @Published var isAuthorized = false
    @Published var errorMessage = ""
    @Published var currentLanguage = "zh-CN"
    
    // --- 新增：用于UI实时更新音频音量 ---
    @Published var audioLevel: Float = 0.0
    
    // ... (已有属性保持不变)
    private let supportedLanguages = [
        "zh-CN": "中文(简体)",
        "en-US": "English",
        "zh-TW": "中文(繁体)"
    ]
    private var speechRecognizers: [String: SFSpeechRecognizer] = [:]
    private var currentRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private var finalResults: [String] = []
    
    // --- 优化：在 init 中调用 setup ---
    override init() {
        super.init()
        setupSpeechRecognizers()
        requestSpeechAuthorization()
    }
    
    // 初始化多语言识别器
    private func setupSpeechRecognizers() {
        for (languageCode, _) in supportedLanguages {
            if let recognizer = SFSpeechRecognizer(locale: Locale(identifier: languageCode)) {
                speechRecognizers[languageCode] = recognizer
                recognizer.delegate = self
            }
        }
        
        // 设置默认识别器
        currentRecognizer = speechRecognizers[currentLanguage]
        print("支持的识别器: \(speechRecognizers.keys)")
    }
    
    // 切换识别语言
    func switchLanguage(to languageCode: String) {
        guard supportedLanguages.keys.contains(languageCode),
              let recognizer = speechRecognizers[languageCode] else {
            print("不支持的语言: \(languageCode)")
            return
        }
        
        currentLanguage = languageCode
        currentRecognizer = recognizer
        print("切换到语言: \(supportedLanguages[languageCode] ?? languageCode)")
        
        // 如果正在录音，重新开始以应用新语言
        if isRecording {
            stopRecording()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.startRecording()
            }
        }
    }
    
    // 获取支持的语言列表
    func getSupportedLanguages() -> [String: String] {
        return supportedLanguages
    }
    
    // 请求语音识别权限
    func requestSpeechAuthorization() {
        print("开始请求语音识别权限...")
        
        // 首先请求麦克风权限
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            DispatchQueue.main.async {
                if granted {
                    print("麦克风权限已授权")
                    // 然后请求语音识别权限
                    SFSpeechRecognizer.requestAuthorization { authStatus in
                        DispatchQueue.main.async {
                            switch authStatus {
                            case .authorized:
                                print("语音识别权限已授权")
                                self.isAuthorized = true
                                self.errorMessage = ""
                            case .denied:
                                print("语音识别权限被拒绝")
                                self.isAuthorized = false
                                self.errorMessage = "语音识别权限被拒绝，请在设置中开启"
                            case .restricted:
                                print("语音识别权限受限")
                                self.isAuthorized = false
                                self.errorMessage = "设备不支持语音识别或权限受限"
                            case .notDetermined:
                                print("语音识别权限未确定")
                                self.isAuthorized = false
                                self.errorMessage = "请授权语音识别权限"
                            @unknown default:
                                print("语音识别权限未知状态")
                                self.isAuthorized = false
                                self.errorMessage = "语音识别权限状态未知"
                            }
                        }
                    }
                } else {
                    print("麦克风权限被拒绝")
                    self.isAuthorized = false
                    self.errorMessage = "需要麦克风权限才能进行语音识别，请在设置中开启"
                }
            }
        }
    }
    
    // 开始录音和语音识别
    func startRecording() {
        print("开始录音，权限状态: \(isAuthorized), 当前语言: \(currentLanguage)")
        
        guard isAuthorized else {
            errorMessage = "请先授权语音识别和麦克风权限"
            return
        }
        
        guard let recognizer = currentRecognizer, recognizer.isAvailable else {
            errorMessage = "当前语言识别器不可用，请检查网络连接"
            return
        }
        
        // 重置状态
        if !isRecording {
            transcribedText = finalResults.joined(separator: " ") // 保留暂停前的文本
            errorMessage = ""
        }
        isRecording = true
        
        startSpeechRecognition()
    }
    
    func stopRecording() {
        print("停止录音...")
        if isRecording {
            DispatchQueue.main.async {
                self.isRecording = false
                self.audioLevel = 0.0 // --- 新增：重置音量 ---
            }
            stopSpeechRecognition()
        }
    }
    
    // --- 优化：将暂停前的结果加入 finalResults ---
    func pause() {
        if !transcribedText.isEmpty {
            finalResults.append(transcribedText)
            // 清空当前文本，避免重复
            transcribedText = ""
        }
        stopRecording()
    }
    
    func clearText() {
        transcribedText = ""
        finalResults = []
        errorMessage = ""
    }
    
    // MARK: - Private Speech Recognition Logic
    
    private func startSpeechRecognition() {
        print("开始语音识别，使用语言: \(currentLanguage)")
        
        stopSpeechRecognition() // 确保之前的任务已停止
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            handleError("音频会话配置失败: \(error.localizedDescription)")
            return
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            handleError("无法创建语音识别请求")
            return
        }
        
        // --- 核心优化：开启自动标点和设置任务类型 ---
        recognitionRequest.shouldReportPartialResults = true
        recognitionRequest.taskHint = .dictation // 优化长语音听写
        
        // iOS 16+ 提供更精确的标点控制
        if #available(iOS 16, *) {
            recognitionRequest.addsPunctuation = true
        }
        
        // 可选：提供上下文信息以提高特定词汇的识别准确率
         recognitionRequest.contextualStrings = ["Adventure X", "konwHow"]
        
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        // --- 核心优化：安装音频监听并计算实时音量 ---
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
            
            // --- 新增：计算音量 ---
            self?.updateAudioLevel(from: buffer)
        }
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            handleError("录音启动失败: \(error.localizedDescription)")
            return
        }
        
        recognitionTask = currentRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            
            if let result = result {
                // 使用 result.bestTranscription.formattedString 来获取带标点的文本
                let recognizedText = result.bestTranscription.formattedString
                let combinedText = (self.finalResults.joined(separator: " ") + " " + recognizedText).trimmingCharacters(in: .whitespaces)
                
                DispatchQueue.main.async {
                    self.transcribedText = combinedText
                    if result.isFinal {
                        // 将最终确认的完整句子存入 finalResults
                        self.finalResults.append(recognizedText)
                        // 重置 transcribedText，等待下一句
                        self.transcribedText = self.finalResults.joined(separator: " ")
                    }
                }
            }
            
            if let error = error {
                print("语音识别错误: \(error)")
                self.stopRecording()
                // 可以根据 error code 提供更友好的提示
            }
        }
    }
    
    private func stopSpeechRecognition() {
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        recognitionTask?.cancel()
        recognitionTask = nil
    }
    
    // --- 新增：实时音量计算和标准化 ---
    private func updateAudioLevel(from buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData else { return }
        
        let channelDataValue = channelData.pointee
        let channelDataValueArray = UnsafeBufferPointer(start: channelDataValue, count: Int(buffer.frameLength))
        
        let rms = sqrt(channelDataValueArray.map { $0 * $0 }.reduce(0, +) / Float(buffer.frameLength))
        let avgPower = 20 * log10(rms)
        
        // 将分贝值标准化到 0-1 的范围
        let minDb: Float = -80.0 // 静音时的分贝值
        let maxDb: Float = -10.0  // 较大音量时的分贝值
        
        var normalizedLevel = (avgPower - minDb) / (maxDb - minDb)
        normalizedLevel = max(0.0, min(1.0, normalizedLevel)) // 限制在 0-1 之间
        
        DispatchQueue.main.async {
            // 使用平滑过渡，避免UI跳动
            self.audioLevel = (self.audioLevel * 0.8) + (normalizedLevel * 0.2)
        }
    }
    
    private func handleError(_ message: String) {
        print(message)
        DispatchQueue.main.async {
            self.errorMessage = message
            self.isRecording = false
            self.audioLevel = 0.0
        }
    }
}

// MARK: - SFSpeechRecognizerDelegate
extension SpeechRecognitionManager: SFSpeechRecognizerDelegate {
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        DispatchQueue.main.async {
            if !available && self.isRecording {
                self.errorMessage = "语音识别服务暂时不可用"
                self.stopRecording()
            } else if available {
                self.errorMessage = ""
            }
            
            print("语音识别器可用性变化: \(available)")
        }
    }
}
