import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Project.createdAt, ascending: false)],
        animation: .default
    )
    private var projects: FetchedResults<Project>

    @State private var isShowingCreateProjectSheet = false

    @State private var editingProject: Project?

    @State private var isShowingDeleteProjectAlert = false
    @State private var projectPendingDeletion: Project?

    var body: some View {
        NavigationView {
            List {
                if projects.isEmpty {
                    Text("No hay proyectos todavía. Creá el primero con +")
                        .foregroundColor(.secondary)
                }

                ForEach(projects) { project in
                    NavigationLink(destination: ProjectDetailView(project: project)) {
                        ProjectRowView(
                            project: project,
                            onEditProject: {
                                editingProject = project
                            },
                            onDeleteProject: {
                                projectPendingDeletion = project
                                isShowingDeleteProjectAlert = true
                            }
                        )
                    }
                }
                .onDelete(perform: requestDeleteProject)
            }
            .navigationTitle("Proyectos")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isShowingCreateProjectSheet = true
                    } label: {
                        Label("Nuevo proyecto", systemImage: "plus")
                    }
                }
            }

            Text("Seleccioná un proyecto")
                .foregroundColor(.secondary)
        }
        .sheet(isPresented: $isShowingCreateProjectSheet) {
            CreateProjectView()
                .environment(\.managedObjectContext, viewContext)
        }
        .sheet(item: $editingProject) { project in
            EditProjectView(project: project)
                .environment(\.managedObjectContext, viewContext)
        }
        .alert("Eliminar proyecto", isPresented: $isShowingDeleteProjectAlert) {
            Button("Cancelar", role: .cancel) {
                projectPendingDeletion = nil
            }
            Button("Eliminar", role: .destructive) {
                deletePendingProject()
            }
        } message: {
            Text("Se eliminará el proyecto y todos sus checkpoints.")
        }
    }

    private func requestDeleteProject(offsets: IndexSet) {
        if let firstIndex = offsets.first {
            projectPendingDeletion = projects[firstIndex]
            isShowingDeleteProjectAlert = true
        }
    }

    private func deletePendingProject() {
        guard let project = projectPendingDeletion else { return }
        viewContext.delete(project)
        projectPendingDeletion = nil
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

private struct ProjectRowView: View {
    @ObservedObject var project: Project
    let onEditProject: () -> Void
    let onDeleteProject: () -> Void
    

    @FetchRequest private var checkpoints: FetchedResults<Checkpoint>

    init(project: Project, onEditProject: @escaping () -> Void, onDeleteProject: @escaping () -> Void) {
        self.project = project
        self.onEditProject = onEditProject
        self.onDeleteProject = onDeleteProject

        let predicate = NSPredicate(format: "project == %@", project)
        let sort = [NSSortDescriptor(keyPath: \Checkpoint.order, ascending: true)]

        _checkpoints = FetchRequest(
            sortDescriptors: sort,
            predicate: predicate,
            animation: .default
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text(project.name ?? "Sin nombre")
                    .font(.headline)
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                Spacer()
                
                Text("\(Int(realProgress * 100))%")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .monospacedDigit()
            }
            
            ProgressBar(progress: realProgress)
            
            HStack {
                Text("\(completedCount)/\(totalCount) completados")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                HStack(spacing: 10) {
                    Button(action: onEditProject) {
                        Image(systemName: "pencil")
                    }
                    .buttonStyle(.borderless)
                    .help("Editar nombre")
                    
                    Button(role: .destructive, action: onDeleteProject) {
                        Image(systemName: "trash")
                    }
                    .buttonStyle(.borderless)
                    .help("Eliminar proyecto")
                }
                .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(NSColor.windowBackgroundColor).opacity(0.7))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.secondary.opacity(0.15), lineWidth: 1)
        )
        .padding(.vertical, 8)
    }
        

    private var totalCount: Int { checkpoints.count }
    private var completedCount: Int { checkpoints.filter { $0.isDone }.count }

    private var realProgress: Double {
        guard totalCount > 0 else { return 0 }
        return Double(completedCount) / Double(totalCount)
    }
}

private struct CreateProjectView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @State private var projectName: String = ""

    var body: some View {
        VStack(spacing: 0) {
            Form {
                Section(header: Text("Proyecto")) {
                    TextField("Nombre del proyecto", text: $projectName)
                }
            }

            Divider()

            HStack {
                Button("Cancelar") { dismiss() }
                    .keyboardShortcut(.cancelAction)

                Spacer()

                Button("Crear") { createProject() }
                    .keyboardShortcut(.defaultAction)
                    .disabled(projectNameTrimmed.isEmpty)
            }
            .padding()
        }
        .frame(minWidth: 520, minHeight: 260)
    }

    private var projectNameTrimmed: String {
        projectName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func createProject() {
        let project = Project(context: viewContext)
        project.id = UUID()
        project.name = projectNameTrimmed
        project.createdAt = Date()

        do {
            try viewContext.save()
            dismiss()
        } catch {
            let nsError = error as NSError
            fatalError("Error creando Project: \(nsError), \(nsError.userInfo)")
        }
    }
}

private struct EditProjectView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    let project: Project

    @State private var projectName: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Editar proyecto")
                .font(.title2)
                .fontWeight(.semibold)

            VStack(alignment: .leading, spacing: 6) {
                Text("Nombre")
                    .font(.caption)
                    .foregroundColor(.secondary)

                TextField("Nombre del proyecto", text: $projectName)
                    .textFieldStyle(.roundedBorder)
            }

            Spacer()

            HStack {
                Button("Cancelar") { dismiss() }
                    .keyboardShortcut(.cancelAction)

                Spacer()

                Button("Guardar") { save() }
                    .keyboardShortcut(.defaultAction)
                    .disabled(projectNameTrimmed.isEmpty)
            }
        }
        .padding(18)
        .frame(minWidth: 520, minHeight: 220)
        .onAppear(perform: loadInitialValues)
    }

    private var projectNameTrimmed: String {
        projectName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func loadInitialValues() {
        projectName = project.name ?? ""
    }

    private func save() {
        project.name = projectNameTrimmed

        do {
            try viewContext.save()
            dismiss()
        } catch {
            let nsError = error as NSError
            fatalError("Error guardando Project: \(nsError), \(nsError.userInfo)")
        }
    }

}
