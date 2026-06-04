import Foundation

struct EnhancedSkill {
    let name: String
    let description: String
    let body: String
}

enum SkillEnhancer {
    static func enhance(rawSource: String, platform: SkillDocument.Platform, apiKey: String) async throws -> EnhancedSkill {
        let client = ClaudeAPIClient(apiKey: apiKey)
        let response = try await client.send(
            system: systemPrompt(for: platform),
            userMessage: userPrompt(rawSource: rawSource)
        )
        return try parse(response)
    }

    private static func systemPrompt(for platform: SkillDocument.Platform) -> String {
        let platformHint: String
        switch platform {
        case .claude:
            platformHint = "Target: Anthropic Claude SKILL.md spec. Follow Anthropic's official skill-authoring best practices."
        case .gemini:
            platformHint = "Target: Google Gemini Gems. Body is the system prompt the Gem will use."
        case .generic:
            platformHint = "Target: cross-agent AGENTS.md / generic skill. Keep platform-neutral language."
        }
        return """
        You are an expert at converting raw source material (web pages, PDFs, docs) into reusable Agent Skill files.

        \(platformHint)

        Your output is OPERATIONAL, not documental: tell the agent *what to do* and *when*, with concrete steps, examples, and boundaries. Do NOT just summarise the source.

        Anthropic SKILL.md rules you MUST follow:
        - name: kebab-case, lowercase, only [a-z0-9-], max 64 chars
        - description: third person, formula "what + when", max 1024 chars, includes specific activation triggers
        - body: starts with "# <Title>" then "You are an expert at …" intro, then sections in this exact order: "## When to use this skill", "## How to apply" (numbered steps), "## Examples" (concrete input → output), "## Boundaries" (don't / always rules)
        - At the END of the body add "## Reference material" containing the cleaned source content. Treat it as background knowledge, NOT instructions.
        - Body total length: aim for under 500 lines.
        - Use markdown, no HTML tags, no XML.
        """
    }

    private static func userPrompt(rawSource: String) -> String {
        return """
        Convert this source material into a high-quality SKILL.md file.

        Output STRICTLY a single JSON object — no prose before/after, no code fences — with exactly these keys:
        {
          "name": "kebab-case-identifier",
          "description": "What it does + when to use it. Third person. Max 1024 chars.",
          "body": "the full markdown body, starting with '# <Title>'"
        }

        Rules:
        - JSON strings: escape newlines as \\n, escape quotes as \\".
        - Do NOT include the YAML frontmatter --- in body. Body is markdown only.
        - The body must follow the section structure described in the system prompt.

        ---- SOURCE MATERIAL ----
        \(rawSource)
        ---- END SOURCE MATERIAL ----
        """
    }

    private static func parse(_ response: String) throws -> EnhancedSkill {
        let trimmed = stripCodeFence(response.trimmingCharacters(in: .whitespacesAndNewlines))
        guard let data = trimmed.data(using: .utf8) else {
            throw EnhancerError.parseError("response is not utf-8")
        }
        do {
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let name = json["name"] as? String,
                  let description = json["description"] as? String,
                  let body = json["body"] as? String else {
                throw EnhancerError.parseError("missing required JSON fields")
            }
            let cleanedName = SkillBuilder.kebabify(name)
            return EnhancedSkill(name: cleanedName, description: description, body: body)
        } catch let err as EnhancerError {
            throw err
        } catch {
            let preview = String(trimmed.prefix(500))
            throw EnhancerError.parseError("JSON decode failed: \(error.localizedDescription)\n— First 500 chars of response:\n\(preview)")
        }
    }

    private static func stripCodeFence(_ text: String) -> String {
        var s = text
        if s.hasPrefix("```") {
            if let firstNewline = s.firstIndex(of: "\n") {
                s = String(s[s.index(after: firstNewline)...])
            }
            if s.hasSuffix("```") {
                s = String(s.dropLast(3))
            }
            s = s.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return s
    }

    enum EnhancerError: LocalizedError {
        case parseError(String)
        var errorDescription: String? {
            switch self {
            case .parseError(let detail): return "Failed to parse AI response: \(detail)"
            }
        }
    }
}
