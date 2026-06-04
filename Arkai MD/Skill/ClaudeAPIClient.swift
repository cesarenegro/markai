import Foundation

struct ClaudeAPIClient {
    let apiKey: String
    var model: String = "claude-sonnet-4-6"
    var maxTokens: Int = 4096

    func send(system: String, userMessage: String) async throws -> String {
        guard let url = URL(string: "https://api.anthropic.com/v1/messages") else {
            throw APIError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 60
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.setValue("application/json", forHTTPHeaderField: "content-type")

        let body: [String: Any] = [
            "model": model,
            "max_tokens": maxTokens,
            "system": system,
            "messages": [
                ["role": "user", "content": userMessage]
            ]
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        if http.statusCode >= 400 {
            let body = String(data: data, encoding: .utf8) ?? "(empty)"
            throw APIError.httpError(http.statusCode, body)
        }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let contentArray = json["content"] as? [[String: Any]] else {
            throw APIError.parseError("missing 'content' array")
        }

        let texts = contentArray.compactMap { item -> String? in
            guard let type = item["type"] as? String, type == "text" else { return nil }
            return item["text"] as? String
        }
        guard !texts.isEmpty else {
            throw APIError.parseError("no text blocks in response")
        }
        return texts.joined(separator: "\n")
    }

    enum APIError: LocalizedError {
        case invalidURL
        case invalidResponse
        case httpError(Int, String)
        case parseError(String)

        var errorDescription: String? {
            switch self {
            case .invalidURL: return "Invalid Anthropic API URL"
            case .invalidResponse: return "Invalid HTTP response"
            case .httpError(let code, let body):
                let snippet = body.prefix(400)
                return "Anthropic API error \(code): \(snippet)"
            case .parseError(let detail): return "Response parse error: \(detail)"
            }
        }
    }
}
