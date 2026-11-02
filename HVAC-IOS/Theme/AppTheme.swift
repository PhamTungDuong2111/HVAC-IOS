import SwiftUI

// MARK: - App Color Palette & Theme
enum AppTheme {
    static let bgDark = Color(hex: "0B1120")
    static let bgCard = Color(hex: "131E35")
    static let bgCardElevated = Color(hex: "1A2744")
    static let borderSubtle = Color(hex: "1E293B")
    static let borderMedium = Color(hex: "334155")
    
    static let primaryBlue = Color(hex: "0284C7")
    static let accentSky = Color(hex: "38BDF8")
    static let accentTeal = Color(hex: "14B8A6")
    
    static let statusGreen = Color(hex: "10B981")
    static let statusAmber = Color(hex: "F59E0B")
    static let statusRed = Color(hex: "EF4444")
    
    static let textPrimary = Color(hex: "F8FAFC")
    static let textSecondary = Color(hex: "94A3B8")
    static let textMuted = Color(hex: "64748B")
    
    static let joistWood = Color(hex: "D97706")
    static let ductMetal = Color(hex: "60A5FA")
    static let wrapInsulation = Color(hex: "F59E0B")
    static let acousticLiner = Color(hex: "6B7280")
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255.0,
            green: Double(g) / 255.0,
            blue: Double(b) / 255.0,
            opacity: Double(a) / 255.0
        )
    }
}

