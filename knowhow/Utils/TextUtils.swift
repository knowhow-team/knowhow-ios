//
//  TextUtils.swift
//  knowhow
//
//  Created by F1reC on 2025/7/26.
//

import Foundation

// MARK: - Text Processing Utilities

extension String {
    /// 处理文本中的引用标识符 [[cite:{id}]]，将其转换为上标数字格式
    /// 例如：[[cite:123]] -> ¹, [[cite:456]] -> ², 等等
    func processCitationReferences() -> String {
        // 上标数字字符映射
        let superscriptNumbers = ["¹", "²", "³", "⁴", "⁵", "⁶", "⁷", "⁸", "⁹", "¹⁰", "¹¹", "¹²", "¹³", "¹⁴", "¹⁵", "¹⁶", "¹⁷", "¹⁸", "¹⁹", "²⁰"]
        
        // 正则表达式匹配 [[cite:{id}]] 模式
        let pattern = #"\[\[cite:(\d+)\]\]"#
        
        var processedText = self
        var citationIndex = 1
        
        // 创建正则表达式对象
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            print("⚠️ 无法创建引用标识符正则表达式")
            return self
        }
        
        // 找到所有匹配项
        let range = NSRange(location: 0, length: self.utf16.count)
        let matches = regex.matches(in: self, options: [], range: range)
        
        // 从后往前替换，避免索引变化的问题
        for match in matches.reversed() {
            let matchRange = match.range
            
            // 检查引用索引是否在范围内
            if citationIndex <= superscriptNumbers.count {
                let superscriptNumber = superscriptNumbers[citationIndex - 1]
                
                // 替换匹配的文本
                if let range = Range(matchRange, in: self) {
                    processedText = processedText.replacingCharacters(in: range, with: superscriptNumber)
                }
                
                citationIndex += 1
            } else {
                // 如果超过了上标数字的范围，使用普通数字格式
                let fallbackNumber = "(\(citationIndex))"
                if let range = Range(matchRange, in: self) {
                    processedText = processedText.replacingCharacters(in: range, with: fallbackNumber)
                }
                citationIndex += 1
            }
        }
        
        return processedText
    }
    
    /// 简化版本的引用处理，只处理常见的引用模式
    func processSimpleCitations() -> String {
        let superscriptNumbers = ["¹", "²", "³", "⁴", "⁵", "⁶", "⁷", "⁸", "⁹", "¹⁰"]
        
        let pattern = #"\[\[cite:\d+\]\]"#
        
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return self
        }
        
        var result = self
        var citationCount = 0
        
        // 按顺序替换每个引用
        while let match = regex.firstMatch(in: result, options: [], range: NSRange(location: 0, length: result.utf16.count)) {
            let matchRange = match.range
            
            if citationCount < superscriptNumbers.count {
                let superscript = superscriptNumbers[citationCount]
                
                if let range = Range(matchRange, in: result) {
                    result = result.replacingCharacters(in: range, with: superscript)
                }
                
                citationCount += 1
            } else {
                // 超过10个引用时使用普通括号格式
                let fallback = "(\(citationCount + 1))"
                if let range = Range(matchRange, in: result) {
                    result = result.replacingCharacters(in: range, with: fallback)
                }
                citationCount += 1
            }
        }
        
        return result
    }
}

// MARK: - Text Utilities Class

class TextUtils {
    /// 处理长文本中的引用标识符
    static func processCitationsInText(_ text: String) -> String {
        return text.processCitationReferences()
    }
    
    /// 获取上标数字字符
    static func getSuperscriptNumber(for index: Int) -> String {
        let superscriptNumbers = ["¹", "²", "³", "⁴", "⁵", "⁶", "⁷", "⁸", "⁹", "¹⁰", "¹¹", "¹²", "¹³", "¹⁴", "¹⁵", "¹⁶", "¹⁷", "¹⁸", "¹⁹", "²⁰"]
        
        if index > 0 && index <= superscriptNumbers.count {
            return superscriptNumbers[index - 1]
        } else {
            return "(\(index))"
        }
    }
    
    /// 统计文本中的引用数量
    static func countCitations(in text: String) -> Int {
        let pattern = #"\[\[cite:\d+\]\]"#
        
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return 0
        }
        
        let range = NSRange(location: 0, length: text.utf16.count)
        let matches = regex.matches(in: text, options: [], range: range)
        
        return matches.count
    }
    
    /// 提取文本中所有的引用ID
    static func extractCitationIds(from text: String) -> [String] {
        let pattern = #"\[\[cite:(\d+)\]\]"#
        
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return []
        }
        
        let range = NSRange(location: 0, length: text.utf16.count)
        let matches = regex.matches(in: text, options: [], range: range)
        
        var citationIds: [String] = []
        
        for match in matches {
            if match.numberOfRanges > 1 {
                let idRange = match.range(at: 1)
                if let range = Range(idRange, in: text) {
                    let citationId = String(text[range])
                    citationIds.append(citationId)
                }
            }
        }
        
        return citationIds
    }
}
