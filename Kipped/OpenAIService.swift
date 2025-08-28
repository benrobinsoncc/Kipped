//
//  OpenAIService.swift
//  Kipped
//
//  Created by Assistant on 14/07/2025.
//

import Foundation

class OpenAIService: ObservableObject {
    static let shared = OpenAIService()
    
    private var apiKey: String? {
        // First check UserDefaults (from settings)
        if let key = UserDefaults.standard.string(forKey: "openAIAPIKey"), !key.isEmpty {
            return key
        }
        // Fallback to environment variable for development
        return ProcessInfo.processInfo.environment["OPENAI_API_KEY"]
    }
    private let apiURL = "https://api.openai.com/v1/chat/completions"
    private let model = "gpt-4o-mini"
    
    struct MemorySummary: Codable {
        let title: String
        let summary: String
        let themes: [String]
        let mood: String
        let colorSuggestion: String?
    }
    
    private init() {}
    
    func generateMemorySummary(for notes: [PositiveNote], period: MemoriesView.MemoryPeriod, date: Date) async throws -> MemorySummary {
        guard let apiKey = apiKey, !apiKey.isEmpty else {
            // Return a nice fallback if no API key
            return generateFallbackSummary(for: notes, period: period)
        }
        
        // Check cache first
        if let cached = loadCachedSummary(for: notes, period: period, date: date) {
            return cached
        }
        
        // Prepare the prompt
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
        
        Please provide a JSON response with:
        1. "title": A poetic, meaningful title (max 5 words) that captures the spirit of this period
        2. "summary": A brief 1-2 sentence narrative summary of the key moments and feelings
        3. "themes": An array of 2-3 theme words (e.g., "gratitude", "growth", "connection")
        4. "mood": Overall emotional tone in one word (e.g., "joyful", "peaceful", "hopeful")
        5. "colorSuggestion": Optional hex color that represents the mood (or null)
        
        Focus on the positive patterns and growth. Be warm and encouraging.
        """
        
        // Create the API request
        var request = URLRequest(url: URL(string: apiURL)!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "model": model,
            "messages": [
                ["role": "system", "content": "You are a thoughtful assistant that helps people reflect on their positive moments."],
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.7,
            "response_format": ["type": "json_object"]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        // Make the API call
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            print("OpenAI API error: \(response)")
            return generateFallbackSummary(for: notes, period: period)
        }
        
        // Parse the response
        let jsonResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)
        guard let content = jsonResponse.choices.first?.message.content,
              let contentData = content.data(using: .utf8) else {
            return generateFallbackSummary(for: notes, period: period)
        }
        
        let summary = try JSONDecoder().decode(MemorySummary.self, from: contentData)
        
        // Cache the result
        saveSummaryToCache(summary, for: notes, period: period, date: date)
        
        return summary
    }
    
    func generateFallbackSummary(for notes: [PositiveNote], period: MemoriesView.MemoryPeriod) -> MemorySummary {
        let themes = ["Gratitude", "Joy", "Growth", "Peace", "Love", "Strength", "Hope", "Discovery", "Connection"]
        let moods = ["joyful", "peaceful", "grateful", "hopeful", "content", "inspired"]
        
        let title = switch period {
        case .weekly: "A Week of \(themes.randomElement()!)"
        case .monthly: "\(themes.randomElement()!) & Moments"
        case .yearly: "Year of \(themes.randomElement()!)"
        }
        
        let summary = notes.isEmpty ? 
            "A time for new beginnings and possibilities." :
            "A collection of \(notes.count) beautiful moments worth remembering."
        
        return MemorySummary(
            title: title,
            summary: summary,
            themes: Array(themes.shuffled().prefix(3)),
            mood: moods.randomElement()!,
            colorSuggestion: nil
        )
    }
    
    // MARK: - Cache Management
    
    private func cacheKey(for notes: [PositiveNote], period: MemoriesView.MemoryPeriod, date: Date) -> String {
        let noteIds = notes.map { $0.id.uuidString }.sorted().joined()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return "\(period.rawValue)-\(formatter.string(from: date))-\(noteIds.hashValue)"
    }
    
    private func loadCachedSummary(for notes: [PositiveNote], period: MemoriesView.MemoryPeriod, date: Date) -> MemorySummary? {
        let key = cacheKey(for: notes, period: period, date: date)
        let cacheURL = getCacheURL().appendingPathComponent("\(key).json")
        
        guard let data = try? Data(contentsOf: cacheURL) else { return nil }
        return try? JSONDecoder().decode(MemorySummary.self, from: data)
    }
    
    private func saveSummaryToCache(_ summary: MemorySummary, for notes: [PositiveNote], period: MemoriesView.MemoryPeriod, date: Date) {
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

// MARK: - OpenAI Response Models

private struct OpenAIResponse: Codable {
    let choices: [Choice]
    
    struct Choice: Codable {
        let message: Message
    }
    
    struct Message: Codable {
        let content: String
    }
}