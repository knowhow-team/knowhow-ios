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

class SpeechRecognitionManager: ObservableObject {
    @Published var transcribedText = ""
    @Published var isRecording = false
    @Published var isAuthorized = false
    @Published var errorMessage = ""
    
    // Speech Recognition
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "zh-CN"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    init() {
        requestSpeechAuthorization()
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
                            case .denied:
                                print("语音识别权限被拒绝")
                                self.isAuthorized = false
                                self.errorMessage = "语音识别权限被拒绝"
                            case .restricted:
                                print("语音识别权限受限")
                                self.isAuthorized = false
                                self.errorMessage = "语音识别权限受限"
                            case .notDetermined:
                                print("语音识别权限未确定")
                                self.isAuthorized = false
                                self.errorMessage = "语音识别权限未确定"
                            @unknown default:
                                print("语音识别权限未知状态")
                                self.isAuthorized = false
                                self.errorMessage = "语音识别权限未知状态"
                            }
                        }
                    }
                } else {
                    print("麦克风权限被拒绝")
                    self.isAuthorized = false
                    self.errorMessage = "麦克风权限被拒绝，请在设置中开启"
                }
            }
        }
    }
    
    // 开始录音和语音识别
    func startRecording() {
        print("开始录音，权限状态: \(isAuthorized)")
        guard isAuthorized else { 
            print("权限未授权，无法开始录音")
            errorMessage = "请先授权语音识别权限"
            return 
        }
        
        isRecording = true
        transcribedText = ""
        errorMessage = ""
        startSpeechRecognition()
    }
    
    // 开始语音识别
    private func startSpeechRecognition() {
        print("开始语音识别...")
        
        // 确保之前的任务已停止
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        // 配置音频会话
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            print("音频会话配置成功")
        } catch {
            print("音频会话配置失败: \(error)")
            errorMessage = "音频会话配置失败: \(error.localizedDescription)"
            return
        }
        
        // 创建识别请求
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { 
            print("无法创建识别请求")
            errorMessage = "无法创建识别请求"
            return 
        }
        recognitionRequest.shouldReportPartialResults = true
        
        // 开始音频引擎
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
            print("音频引擎启动成功")
        } catch {
            print("音频引擎启动失败: \(error)")
            errorMessage = "音频引擎启动失败: \(error.localizedDescription)"
            return
        }
        
        // 开始识别任务
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
            if let result = result {
                DispatchQueue.main.async {
                    self.transcribedText = result.bestTranscription.formattedString
                    print("识别结果: \(self.transcribedText)")
                }
            }
            
            if let error = error {
                print("语音识别错误: \(error)")
                DispatchQueue.main.async {
                    self.errorMessage = "语音识别错误: \(error.localizedDescription)"
                }
                self.stopSpeechRecognition()
            }
        }
    }
    
    // 停止语音识别
    private func stopSpeechRecognition() {
        print("停止语音识别...")
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        recognitionTask?.cancel()
        recognitionTask = nil
    }
    
    // 停止录音
    func stopRecording() {
        print("停止录音...")
        isRecording = false
        stopSpeechRecognition()
    }
    
    // 获取转文字结果
    func getTranscribedText() -> String {
        return transcribedText
    }
} 