import SwiftUI
import CoreData

struct ProjectDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var project: Project

    @State private var isShowingCheckpointEditorSheet = false
    @State private var editingCheckpoint: Checkpoint?

    @State private var isShowingDeleteCheckpointAlert = false
    @State private var checkpointPendingDeletion: Checkpoint?

    @FetchRequest private var checkpoints: FetchedResults<Checkpoint>

    init(project: Project) {
        self.project = project

        let predicate = NSPredicate(format: "project == %@", project)
        let sort = [NSSortDescriptor(keyPath: \Checkpoint.order, ascending: true)]

        _checkpoints = FetchRequest(
            sortDescriptors: sort,
            predicate: predicate,
            animation: .default
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header

            List {
                ForEach(checkpoints, id: \.objectID) { checkpoint in
                    CheckpointRow(
                        title: checkpoint.title ?? "Sin título",
                        details: checkpoint.details ?? "",
                        isDone: checkpoint.isDone,
                        onToggle: {
                            checkpoint.isDone.toggle()
                            saveContext()
                        },
                        onEdit: {
                            openEditor(for: checkpoint)
                        },
                        onDelete: {
                            checkpointPendingDeletion = checkpoint
                            isShowingDeleteCheckpointAlert = true
                        }
                    )
                }
                .onDelete(perform: deleteCheckpoints)
            }

            addCheckpointBar
        }
        .padding(16)
        .navigationTitle(project.name ?? "Proyecto")
        .sheet(isPresented: $isShowingCheckpointEditorSheet) {
            CheckpointEditorView(project: project, checkpointToEdit: editingCheckpoint)
                .environment(\.managedObjectContext, viewContext)
        }
        .alert("Eliminar checkpoint", isPresented: $isShowingDeleteCheckpointAlert) {
            Button("Cancelar", role: .cancel) { checkpointPendingDeletion = nil }
            Button("Eliminar", role: .destructive) {
                deletePendingCheckpoint()
            }
        } message: {
            Text("Se eliminará este checkpoint de forma permanente.")
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text(project.name ?? "Proyecto")
                    .font(.title2)
                    .fontWeight(.semibold)

                Spacer()

                Text("\(Int(progressFraction * 100))%")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .monospacedDigit()
            }

            TimelineProgressBar(
                totalCount: checkpoints.count,
                completedCount: checkpoints.filter { $0.isDone }.count,
                checkpointTitles: checkpoints.map { $0.title ?? "" }
            )
            .clipped()

            Text("\(completedCount)/\(totalCount) completados")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(NSColor.windowBackgroundColor).opacity(0.7))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.secondary.opacity(0.15), lineWidth: 1)
        )
    }

    private var addCheckpointBar: some View {
        HStack {
            Spacer()

            Button {
                openEditor(for: nil)
            } label: {
                Label("Nuevo checkpoint", systemImage: "plus")
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private var totalCount: Int { checkpoints.count }
    private var completedCount: Int { checkpoints.filter { $0.isDone }.count }

    private var progressFraction: Double {
        guard totalCount > 0 else { return 0 }
        return Double(completedCount) / Double(totalCount)
    }

    private func openEditor(for checkpoint: Checkpoint?) {
        editingCheckpoint = checkpoint
        isShowingCheckpointEditorSheet = true
    }

    private func deletePendingCheckpoint() {
        guard let checkpoint = checkpointPendingDeletion else { return }
        viewContext.delete(checkpoint)
        checkpointPendingDeletion = nil
        saveContext()
    }

    private func deleteCheckpoints(offsets: IndexSet) {
        offsets.map { checkpoints[$0] }.forEach(viewContext.delete)
        saveContext()
    }

    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Error guardando Core Data: \(nsError), \(nsError.userInfo)")
        }
    }
}
