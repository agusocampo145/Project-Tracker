import SwiftUI
import CoreData

struct CheckpointEditorView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    let project: Project
    let checkpointToEdit: Checkpoint?

    @State private var title: String = ""
    @State private var details: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(checkpointToEdit == nil ? "Nuevo checkpoint" : "Editar checkpoint")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.bottom, 4)

            VStack(alignment: .leading, spacing: 6) {
                Text("Título")
                    .font(.caption)
                    .foregroundColor(.secondary)

                TextField("Ej: Landing page con info", text: $title)
                    .textFieldStyle(.roundedBorder)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Descripción")
                    .font(.caption)
                    .foregroundColor(.secondary)

                ZStack(alignment: .topLeading) {
                    if details.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Text("Detalle opcional del checkpoint...")
                            .foregroundColor(.secondary)
                            .padding(.top, 8)
                            .padding(.leading, 6)
                    }

                    TextEditor(text: $details)
                        .frame(minHeight: 90, maxHeight: 160)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.secondary.opacity(0.25), lineWidth: 1)
                )
            }

            Spacer()

            HStack {
                Button("Cancelar") { dismiss() }
                    .keyboardShortcut(.cancelAction)

                Spacer()

                Button(checkpointToEdit == nil ? "Crear" : "Guardar") {
                    save()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(titleTrimmed.isEmpty)
            }
        }
        .padding(18)
        .frame(minWidth: 560, minHeight: 360)
        .onAppear(perform: loadInitialValues)
    }

    private var titleTrimmed: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var detailsTrimmed: String {
        details.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func loadInitialValues() {
        guard let checkpointToEdit else { return }
        title = checkpointToEdit.title ?? ""
        details = checkpointToEdit.details ?? ""
    }

    private func save() {
        let checkpoint: Checkpoint

        if let checkpointToEdit {
            checkpoint = checkpointToEdit
        } else {
            checkpoint = Checkpoint(context: viewContext)
            checkpoint.id = UUID()
            checkpoint.project = project
            checkpoint.isDone = false
            checkpoint.order = nextOrder()
        }

        checkpoint.title = titleTrimmed
        checkpoint.details = detailsTrimmed

        do {
            try viewContext.save()
            dismiss()
        } catch {
            let nsError = error as NSError
            fatalError("Error guardando Checkpoint: \(nsError), \(nsError.userInfo)")
        }
    }

    private func nextOrder() -> Int16 {
        let set = project.checkpoints as? Set<Checkpoint> ?? []
        let maxOrder = set.map { $0.order }.max() ?? -1
        return maxOrder + 1
    }
}
