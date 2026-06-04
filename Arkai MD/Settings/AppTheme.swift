import AppKit
import SwiftUI

struct AppTheme: Identifiable, Hashable {
    let id: String
    let displayName: String
    let primaryHex: String
    let backgroundHex: String?
    let foregroundHex: String?
    let accentHex: String?
    let barBackgroundHex: String?
    let isDark: Bool

    var isSystem: Bool { backgroundHex == nil }

    var primaryColor: Color { Color(hex: primaryHex) }
    var backgroundColor: Color? { backgroundHex.map(Color.init(hex:)) }
    var foregroundColor: Color? { foregroundHex.map(Color.init(hex:)) }
    var accentColor: Color? { accentHex.map(Color.init(hex:)) }
    var barBackgroundColor: Color? { barBackgroundHex.map(Color.init(hex:)) }

    var backgroundNSColor: NSColor? { backgroundHex.map(NSColor.init(hex:)) }
    var foregroundNSColor: NSColor? { foregroundHex.map(NSColor.init(hex:)) }
    var accentNSColor: NSColor? { accentHex.map(NSColor.init(hex:)) }

    static let system = AppTheme(
        id: "system",
        displayName: "System",
        primaryHex: "#8E8E93",
        backgroundHex: nil,
        foregroundHex: nil,
        accentHex: nil,
        barBackgroundHex: nil,
        isDark: false
    )

    static let pinky = AppTheme(
        id: "pinky",
        displayName: "Pinky",
        primaryHex: "#EC849A",
        backgroundHex: "#EC849A",
        foregroundHex: "#2A1F22",
        accentHex: "#FFFFFF",
        barBackgroundHex: "#C46B7D",
        isDark: false
    )

    static let navy = AppTheme(
        id: "navy",
        displayName: "Navy",
        primaryHex: "#384166",
        backgroundHex: "#384166",
        foregroundHex: "#F1EDEA",
        accentHex: "#EC849A",
        barBackgroundHex: "#252B45",
        isDark: true
    )

    static let desert = AppTheme(
        id: "desert",
        displayName: "Desert",
        primaryHex: "#A1D8B5",
        backgroundHex: "#A1D8B5",
        foregroundHex: "#283F23",
        accentHex: "#283F23",
        barBackgroundHex: "#7CB893",
        isDark: false
    )

    static let blackForest = AppTheme(
        id: "black-forest",
        displayName: "Black Forest",
        primaryHex: "#283F23",
        backgroundHex: "#283F23",
        foregroundHex: "#A1D8B5",
        accentHex: "#DDEBE2",
        barBackgroundHex: "#1A2C18",
        isDark: true
    )

    static let qatar = AppTheme(
        id: "qatar",
        displayName: "Qatar",
        primaryHex: "#F1EDEA",
        backgroundHex: "#F1EDEA",
        foregroundHex: "#3D3833",
        accentHex: "#384166",
        barBackgroundHex: "#D9D2C9",
        isDark: false
    )

    static let relax = AppTheme(
        id: "relax",
        displayName: "Relax",
        primaryHex: "#3EBCB3",
        backgroundHex: "#3EBCB3",
        foregroundHex: "#0F2E2C",
        accentHex: "#FFFFFF",
        barBackgroundHex: "#2D8C85",
        isDark: false
    )

    static let typhoon = AppTheme(
        id: "typhoon",
        displayName: "Typhoon",
        primaryHex: "#070836",
        backgroundHex: "#070836",
        foregroundHex: "#DDE6F2",
        accentHex: "#5AC8FA",
        barBackgroundHex: "#11154D",
        isDark: true
    )

    static let all: [AppTheme] = [
        .system, .pinky, .navy, .desert, .blackForest, .qatar, .relax, .typhoon
    ]

    static func lookup(_ id: String) -> AppTheme {
        all.first { $0.id == id } ?? .system
    }
}

extension Color {
    init(hex: String) {
        let cleaned = hex
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")
        var value: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&value)
        let r = Double((value >> 16) & 0xFF) / 255.0
        let g = Double((value >> 8) & 0xFF) / 255.0
        let b = Double(value & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}

extension NSColor {
    convenience init(hex: String) {
        let cleaned = hex
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")
        var value: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&value)
        let r = CGFloat((value >> 16) & 0xFF) / 255.0
        let g = CGFloat((value >> 8) & 0xFF) / 255.0
        let b = CGFloat(value & 0xFF) / 255.0
        self.init(srgbRed: r, green: g, blue: b, alpha: 1.0)
    }
}
