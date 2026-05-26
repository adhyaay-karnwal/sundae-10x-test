import SwiftUI

enum Theme {
    static let background = TenXAppDesignSystem.background
    static let surface    = TenXAppDesignSystem.surface
    static let surfaceHi  = Color(red: 0.145, green: 0.157, blue: 0.137)   // a touch lighter
    static let stroke     = Color.white.opacity(0.06)
    static let text       = Color(red: 0.961, green: 0.961, blue: 0.949)   // #F5F5F4
    static let textDim    = Color(red: 0.961, green: 0.961, blue: 0.949).opacity(0.55)
    static let textFaint  = Color(red: 0.961, green: 0.961, blue: 0.949).opacity(0.28)
    static let accent     = TenXAppDesignSystem.accent
    static let accentInk  = Color(red: 0.055, green: 0.059, blue: 0.051)

    // Macro semantic colors (kept within the palette: lime accent + neutral tints)
    static let kcalColor    = Color(red: 0.776, green: 0.957, blue: 0.196)
    static let proteinColor = Color(red: 0.776, green: 0.957, blue: 0.196)
    static let carbsColor   = Color(red: 0.85, green: 0.85, blue: 0.78)
    static let fatColor     = Color(red: 0.55, green: 0.57, blue: 0.50)

    static let warn = Color(red: 0.95, green: 0.55, blue: 0.20)
    static let good = Color(red: 0.776, green: 0.957, blue: 0.196)
}

// MARK: - Typography

extension Font {
    static func numeric(_ size: CGFloat, weight: Font.Weight = .semibold) -> Font {
        .system(size: size, weight: weight, design: .rounded).monospacedDigit()
    }
    static func mono(_ size: CGFloat, weight: Font.Weight = .medium) -> Font {
        .system(size: size, weight: weight, design: .monospaced)
    }
    static func display(_ size: CGFloat, weight: Font.Weight = .bold) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }
}

// MARK: - Reusable surfaces

struct SurfaceCard<Content: View>: View {
    var padding: CGFloat = 16
    var corner: CGFloat = 18
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: corner, style: .continuous)
                    .fill(Theme.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: corner, style: .continuous)
                    .strokeBorder(Theme.stroke, lineWidth: 1)
            )
    }
}

struct SectionLabel: View {
    let title: String
    var trailing: String? = nil
    var body: some View {
        HStack {
            Text(title.uppercased())
                .font(.mono(11, weight: .semibold))
                .tracking(1.4)
                .foregroundStyle(Theme.textDim)
            Spacer()
            if let trailing {
                Text(trailing.uppercased())
                    .font(.mono(11, weight: .medium))
                    .tracking(1.2)
                    .foregroundStyle(Theme.textFaint)
            }
        }
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold, design: .rounded))
            .foregroundStyle(Theme.accentInk)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Theme.accent)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.8), value: configuration.isPressed)
    }
}

struct GhostButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .medium, design: .rounded))
            .foregroundStyle(Theme.text)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Theme.surfaceHi)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(Theme.stroke, lineWidth: 1)
            )
            .opacity(configuration.isPressed ? 0.85 : 1)
    }
}
