import SwiftUI

struct TimelineProgressBar: View {
    let totalCount: Int
    let completedCount: Int
    let checkpointTitles: [String]

    private var realProgress: Double {
        guard totalCount > 0 else { return 0 }
        return Double(completedCount) / Double(totalCount)
    }

    // Para 1 checkpoint:
    // - tick 1 debe estar al final (x = width)
    // - completado 1/1 => fill completo
    private var fillProgress: Double {
        guard totalCount > 0 else { return 0 }
        if completedCount >= totalCount { return 1 }
        return Double(completedCount) / Double(totalCount)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            barAndLabels
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Progreso del proyecto")
        .accessibilityValue("\(Int(realProgress * 100))%")
    }

    private var barAndLabels: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let barHeight: CGFloat = 14
            let fillWidth = max(0, min(width, width * fillProgress))

            ZStack(alignment: .topLeading) {
                // Barra
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.secondary.opacity(0.22))
                        .frame(height: barHeight)

                    RoundedRectangle(cornerRadius: 8)
                        .fill(dynamicColor(realProgress))
                        .frame(width: fillWidth, height: barHeight)

                    // Ticks: i/(n) => el último tick cae en 1 (fin de barra)
                    if totalCount > 0 {
                        ForEach(1...totalCount, id: \.self) { tickIndex in
                            let x = width * CGFloat(Double(tickIndex) / Double(totalCount))
                            let isTickCompleted = tickIndex <= completedCount
                            let title = checkpointTitles[tickIndex - 1]


                            Rectangle()
                                .fill(isTickCompleted ? Color.primary.opacity(0.55) : Color.primary.opacity(0.25))
                                .frame(width: 1, height: barHeight + 6)
                                .offset(x: x == width ? x - 1 : x, y: -2) // evita que se “corte” el tick final
                                .help(title)

                        }
                    }
                }
                .frame(height: 20)

                // Labels alineados con sus ticks (mismo cálculo de x)
                if totalCount > 0 {
                    ForEach(Array(checkpointTitles.prefix(totalCount)).indices, id: \.self) { idx in
                        let tickIndex = idx + 1
                        let x = width * CGFloat(Double(tickIndex) / Double(totalCount))
                        let fullTitle = checkpointTitles[idx]
                        let labelMaxWidth = labelWidth(totalCount: totalCount, availableWidth: width)

                        Text(fullTitle)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                            .frame(width: labelMaxWidth, alignment: .center)
                            .help(fullTitle) // Tooltip con el título completo
                            .position(x: clampLabelX(x, width: width), y: 40)

                    }
                }
            }
        }
        .frame(height: 68)
    }

    // Evita que el texto se vaya afuera a izquierda o derecha.
    // Ajustá el padding si querés más margen.
    private func clampLabelX(_ x: CGFloat, width: CGFloat) -> CGFloat {
        let padding: CGFloat = 30
        return min(max(x, padding), width - padding)
    }
    
    private func labelWidth(totalCount: Int, availableWidth: CGFloat) -> CGFloat {
        // Ancho por "segmento" de timeline, con límites para que sea legible.
        // - Si hay pocos checkpoints, dejamos etiquetas un poco más anchas.
        // - Si hay muchos, reducimos para evitar choques.
        guard totalCount > 0 else { return 80 }

        let segmentWidth = availableWidth / CGFloat(totalCount)
        let ideal = segmentWidth * 0.9

        // Ajustá estos valores si querés más/menos compactación
        let minWidth: CGFloat = 60
        let maxWidth: CGFloat = 140

        return min(max(ideal, minWidth), maxWidth)
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
