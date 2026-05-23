import SwiftUI

// MARK: - Macro Ring

struct MacroRing: View {
    let value: Double
    let target: Double
    let label: String
    let unit: String
    var color: Color = Theme.accent
    var size: CGFloat = 120
    var lineWidth: CGFloat = 10

    private var progress: Double { target > 0 ? min(1.5, value / target) : 0 }
    private var overshoot: Bool { value > target * 1.05 }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Theme.surfaceHi, lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: min(1.0, progress))
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.6, dampingFraction: 0.85), value: progress)
            if overshoot {
                Circle()
                    .trim(from: 0, to: min(1.0, progress - 1.0))
                    .stroke(Theme.warn, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                    .rotationEffect(.degrees(-90))
            }
            VStack(spacing: 2) {
                Text("\(Int(value.rounded()))")
                    .font(.numeric(size * 0.27, weight: .bold))
                    .foregroundStyle(Theme.text)
                Text("/ \(Int(target)) \(unit)")
                    .font(.mono(size * 0.085, weight: .medium))
                    .foregroundStyle(Theme.textDim)
                Text(label.uppercased())
                    .font(.mono(size * 0.085, weight: .semibold))
                    .tracking(1.0)
                    .foregroundStyle(Theme.textFaint)
            }
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Macro Bar (compact)

struct MacroBar: View {
    let value: Double
    let target: Double
    let label: String
    let color: Color

    private var progress: Double { target > 0 ? min(1.2, value / target) : 0 }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(Int(value.rounded()))")
                    .font(.numeric(18, weight: .semibold))
                    .foregroundStyle(Theme.text)
                Text("/ \(Int(target))g")
                    .font(.mono(11, weight: .medium))
                    .foregroundStyle(Theme.textFaint)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Theme.surfaceHi).frame(height: 4)
                    Capsule().fill(color)
                        .frame(width: geo.size.width * min(1.0, progress), height: 4)
                }
            }
            .frame(height: 4)
            Text(label.uppercased())
                .font(.mono(10, weight: .semibold))
                .tracking(1.2)
                .foregroundStyle(Theme.textDim)
        }
    }
}

// MARK: - Recipe Poster (graphic stand-in for an image)

struct RecipePoster: View {
    let recipe: Recipe
    var size: CGFloat = 64
    var corner: CGFloat = 14

    var body: some View {
        ZStack {
            // Layered gradient using palette + slight hue derivation
            RoundedRectangle(cornerRadius: corner, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hue: recipe.accentHue, saturation: 0.35, brightness: 0.30),
                            Color(hue: recipe.accentHue, saturation: 0.22, brightness: 0.16)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            // Subtle ring lines for "data-y" feel
            RoundedRectangle(cornerRadius: corner, style: .continuous)
                .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
            // Diagonal sheen
            Rectangle()
                .fill(
                    LinearGradient(colors: [.white.opacity(0.06), .clear],
                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .mask(RoundedRectangle(cornerRadius: corner, style: .continuous))

            Image(systemName: recipe.glyph)
                .font(.system(size: size * 0.42, weight: .semibold))
                .foregroundStyle(Theme.text.opacity(0.85))
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Chip

struct Chip: View {
    let text: String
    var selected: Bool = false
    var symbol: String? = nil

    var body: some View {
        HStack(spacing: 6) {
            if let symbol {
                Image(systemName: symbol).font(.system(size: 11, weight: .semibold))
            }
            Text(text)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
        }
        .padding(.horizontal, 10).padding(.vertical, 6)
        .foregroundStyle(selected ? Theme.accentInk : Theme.text)
        .background(
            Capsule().fill(selected ? Theme.accent : Theme.surfaceHi)
        )
        .overlay(
            Capsule().strokeBorder(Theme.stroke, lineWidth: selected ? 0 : 1)
        )
    }
}

// MARK: - Big Number readout

struct StatReadout: View {
    let value: String
    let label: String
    var color: Color = Theme.text
    var alignment: HorizontalAlignment = .leading

    var body: some View {
        VStack(alignment: alignment, spacing: 4) {
            Text(value)
                .font(.numeric(28, weight: .bold))
                .foregroundStyle(color)
            Text(label.uppercased())
                .font(.mono(10, weight: .semibold))
                .tracking(1.3)
                .foregroundStyle(Theme.textDim)
        }
    }
}

// MARK: - Slot Pill (small inline status)

struct SlotMealLabel: View {
    let meal: MealType
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: meal.symbol)
                .font(.system(size: 10, weight: .semibold))
            Text(meal.label.uppercased())
                .font(.mono(10, weight: .semibold))
                .tracking(1.2)
        }
        .foregroundStyle(Theme.textDim)
    }
}
