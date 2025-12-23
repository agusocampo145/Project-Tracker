import SwiftUI

struct CheckpointRow: View {
    let title: String
    let details: String
    let isDone: Bool
    let onToggle: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Button(action: onToggle) {
                ZStack {
                    Circle()
                        .strokeBorder(Color.secondary.opacity(0.35), lineWidth: 2)
                        .frame(width: 22, height: 22)

                    if isDone {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 14, height: 14)
                    }
                }
                .padding(6)                 // agranda el área clickeable
                .contentShape(Rectangle())  // asegura hit area rectangular
            }
            .buttonStyle(.plain)


            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)

                let trimmedDetails = details.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmedDetails.isEmpty {
                    Text(trimmedDetails)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                }
            }
            .contentShape(Rectangle())
            Spacer()

            HStack(spacing: 10) {
                Button(action: onEdit) {
                    Image(systemName: "pencil")
                }
                .buttonStyle(.borderless)
                .help("Editar checkpoint")

                Button(role: .destructive, action: onDelete) {
                    Image(systemName: "trash")
                }
                .buttonStyle(.borderless)
                .help("Eliminar checkpoint")
            }
            .foregroundColor(.secondary)

        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(NSColor.windowBackgroundColor).opacity(0.7))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.secondary.opacity(0.15), lineWidth: 1)
        )
        .help(tooltipText)
    }

    private var tooltipText: String {
        let trimmedDetails = details.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedDetails.isEmpty { return title }
        return "\(title)\n\n\(trimmedDetails)"
    }
}
