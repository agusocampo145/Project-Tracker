import SwiftUI

struct ProgressBar: View {
    let progress: Double

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.secondary.opacity(0.22))

                RoundedRectangle(cornerRadius: 8)
                    .fill(dynamicColor(progress))
                    .frame(width: max(0, min(geo.size.width, geo.size.width * progress)))
            }
        }
        .frame(height: 10)
        .accessibilityLabel("Progreso")
        .accessibilityValue("\(Int(progress * 100))%")
    }

    private func dynamicColor(_ progress: Double) -> Color {
        if progress < 0.5 {
            let t = progress / 0.5
            return lerpColor(from: (0.65, 0.22, 0.22), to: (0.78, 0.68, 0.20), t: t)
        } else {
            let t = (progress - 0.5) / 0.5
            return lerpColor(from: (0.78, 0.68, 0.20), to: (0.20, 0.65, 0.30), t: t)
        }
    }

    private func lerpColor(from: (Double, Double, Double), to: (Double, Double, Double), t: Double) -> Color {
        let clamped = max(0, min(1, t))
        let r = from.0 + (to.0 - from.0) * clamped
        let g = from.1 + (to.1 - from.1) * clamped
        let b = from.2 + (to.2 - from.2) * clamped
        return Color(red: r, green: g, blue: b)
    }
}
