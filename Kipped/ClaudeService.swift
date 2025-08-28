//
//  ClaudeService.swift
//  Kipped
//
//  Created by Assistant on 14/07/2025.
//

import Foundation

class ClaudeService: ObservableObject {
    static let shared = ClaudeService()
    private init() {}
    
    private var apiKey: String? {
        if let key = UserDefaults.standard.string(forKey: "anthropicAPIKey"), !key.isEmpty {
            return key
        }
        return ProcessInfo.processInfo.environment["ANTHROPIC_API_KEY"]
    }
    
    private let apiURL = "https://api.anthropic.com/v1/messages"
    private let model = "claude-3-5-sonnet-latest"
    
    func generateMemorySummary(for notes: [PositiveNote], period: MemoriesView.MemoryPeriod, date: Date) async throws -> OpenAIService.MemorySummary {
        guard let apiKey = apiKey, !apiKey.isEmpty else {
            // Reuse OpenAI fallback for consistent UX
            return OpenAIService.shared.generateFallbackSummary(for: notes, period: period)
        }
        
        // Cache key compatible with OpenAIService to share cache across providers
        if let cached = loadCachedSummary(for: notes, period: period, date: date) {
            return cached
        }
        
        let notesText = notes.map { note in
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return "\(formatter.string(from: note.date)): \(note.content)"
        }.joined(separator: "\n")
        
        let periodContext = switch period {
        case .weekly: "week"
        case .monthly: "month"
        case .yearly: "year"
        }
        
        let prompt = """
        You are analyzing positive notes from someone's \(periodContext). Generate a thoughtful summary that captures the essence of this time period.
        
        Notes:
        \(notesText)
        
        Please provide a JSON response with the following fields:
        - title: A poetic, meaningful title (max 5 words)
        - summary: A brief 1-2 sentence narrative summary
        - themes: An array of 2-3 theme words (e.g., "gratitude", "growth", "connection")
        - mood: Overall emotional tone in one word (e.g., "joyful", "peaceful", "hopeful")
        - colorSuggestion: Optional hex color string like "#AABBCC" (or null)
        
        Respond with ONLY valid JSON.
        """
        
        var request = URLRequest(url: URL(string: apiURL)!)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "model": model,
            "max_tokens": 1000,
            "temperature": 0.7,
            "messages": [
                [
                    "role": "user",
                    "content": prompt
                ]
            ]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            print("Anthropic API error: \(response)")
            return OpenAIService.shared.generateFallbackSummary(for: notes, period: period)
        }
        
        // Parse Anthropic messages response
        let decoded = try JSONDecoder().decode(AnthropicResponse.self, from: data)
        guard let first = decoded.content.first, first.type == "text" else {
            return OpenAIService.shared.generateFallbackSummary(for: notes, period: period)
        }
        
        guard let contentData = first.text.data(using: .utf8) else {
            return OpenAIService.shared.generateFallbackSummary(for: notes, period: period)
        }
        
        let summary = try JSONDecoder().decode(OpenAIService.MemorySummary.self, from: contentData)
        saveSummaryToCache(summary, for: notes, period: period, date: date)
        return summary
    }
    
    // MARK: - Cache reuse (mirror OpenAIService)
    private func cacheKey(for notes: [PositiveNote], period: MemoriesView.MemoryPeriod, date: Date) -> String {
        let noteIds = notes.map { $0.id.uuidString }.sorted().joined()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return "\(period.rawValue)-\(formatter.string(from: date))-\(noteIds.hashValue)"
    }
    
    private func loadCachedSummary(for notes: [PositiveNote], period: MemoriesView.MemoryPeriod, date: Date) -> OpenAIService.MemorySummary? {
        let key = cacheKey(for: notes, period: period, date: date)
        let cacheURL = getCacheURL().appendingPathComponent("\(key).json")
        guard let data = try? Data(contentsOf: cacheURL) else { return nil }
        return try? JSONDecoder().decode(OpenAIService.MemorySummary.self, from: data)
    }
    
    private func saveSummaryToCache(_ summary: OpenAIService.MemorySummary, for notes: [PositiveNote], period: MemoriesView.MemoryPeriod, date: Date) {
        let key = cacheKey(for: notes, period: period, date: date)
        let cacheURL = getCacheURL().appendingPathComponent("\(key).json")
        if let data = try? JSONEncoder().encode(summary) {
            try? data.write(to: cacheURL)
        }
    }
    
    private func getCacheURL() -> URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let cacheURL = documentsPath.appendingPathComponent("MemorySummaries")
        if !FileManager.default.fileExists(atPath: cacheURL.path) {
            try? FileManager.default.createDirectory(at: cacheURL, withIntermediateDirectories: true)
        }
        return cacheURL
    }
}

// MARK: - Anthropic Models
private struct AnthropicResponse: Codable {
    let content: [Content]
    struct Content: Codable {
        let type: String
        let text: String
    }
}


