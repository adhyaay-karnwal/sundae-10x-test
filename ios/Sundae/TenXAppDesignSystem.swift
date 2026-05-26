import SwiftUI

enum TenXAppDesignSystem {
    static let styleName = "AI Coach"
    static let primary = Color(tenXHex: "#111827")
    static let accent = Color(tenXHex: "#E5E100")
    static let background = Color(tenXHex: "#F8FAFC")
    static let surface = Color.white.opacity(0.82)
    static let textPrimary = primary
    static let textSecondary = primary.opacity(0.68)
}

private struct TenXAppDesignSystemModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .tint(TenXAppDesignSystem.accent)
            .accentColor(TenXAppDesignSystem.accent)
            .background(TenXAppDesignSystem.background.ignoresSafeArea())
    }
}

extension View {
    func tenXAppDesignSystem() -> some View {
        modifier(TenXAppDesignSystemModifier())
    }
}

extension Color {
    init(tenXHex hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var value: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&value)
        let red = Double((value >> 16) & 0xFF) / 255.0
        let green = Double((value >> 8) & 0xFF) / 255.0
        let blue = Double(value & 0xFF) / 255.0
        self.init(red: red, green: green, blue: blue)
    }
}