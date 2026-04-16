import SwiftUI

struct WorktreeView: View {
    @State private var repositories: [Repository] = []
    @State private var showingAddRepo = false
    @State private var newRepoPath = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Worktrees")
                    .font(.headline)
                Spacer()
                Button(action: { showingAddRepo = true }) {
                    Image(systemName: "plus.circle")
                }
                .buttonStyle(.plain)
            }

            if repositories.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "folder.badge.plus")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    Text("No repositories added")
                        .foregroundColor(.secondary)
                    Button("Add Repository") {
                        showingAddRepo = true
                    }
                    .buttonStyle(.bordered)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(repositories) { repo in
                            RepositoryRow(repo: repo, onSelect: { selectWorktree(repo) })
                        }
                    }
                }
            }
        }
        .padding()
        .onAppear { loadRepositories() }
        .sheet(isPresented: $showingAddRepo) {
            AddRepositoryView(path: $newRepoPath, onAdd: {
                addRepository()
                showingAddRepo = false
            })
        }
    }

    private func loadRepositories() {
        let savedPaths = UserDefaults.standard.stringArray(forKey: "repositories") ?? []
        repositories = savedPaths.compactMap { path in
            guard FileManager.default.fileExists(atPath: path) else { return nil }
            return Repository(id: UUID(), path: path, name: URL(fileURLWithPath: path).lastPathComponent)
        }
    }

    private func addRepository() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true

        if panel.runModal() == .OK, let url = panel.url {
            var savedPaths = UserDefaults.standard.stringArray(forKey: "repositories") ?? []
            savedPaths.append(url.path)
            UserDefaults.standard.set(savedPaths, forKey: "repositories")
            loadRepositories()
        }
    }

    private func selectWorktree(_ repo: Repository) {
        runShellCommand("open", args: ["-a", "Cursor", repo.path])
    }
}

struct Repository: Identifiable {
    let id: UUID
    let path: String
    let name: String
}

struct RepositoryRow: View {
    let repo: Repository
    let onSelect: () -> Void

    var body: some View {
        HStack {
            Image(systemName: "folder")
                .foregroundColor(.blue)
            VStack(alignment: .leading) {
                Text(repo.name)
                    .font(.system(.body, design: .default))
                Text(repo.path)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            Spacer()
            Button("Open") {
                onSelect()
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
        .padding(8)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(8)
    }
}

struct AddRepositoryView: View {
    @Binding var path: String
    let onAdd: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 16) {
            Text("Add Repository")
                .font(.headline)
            Button("Choose Folder") {
                let panel = NSOpenPanel()
                panel.canChooseFiles = false
                panel.canChooseDirectories = true

                if panel.runModal() == .OK, let url = panel.url {
                    path = url.path
                }
            }
            .buttonStyle(.bordered)

            if !path.isEmpty {
                Text(path)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            HStack {
                Button("Cancel") { dismiss() }
                    .keyboardShortcut(.cancelAction)
                Button("Add") { onAdd() }
                    .keyboardShortcut(.defaultAction)
                    .disabled(path.isEmpty)
            }
        }
        .padding()
        .frame(width: 300, height: 150)
    }
}

func runShellCommand(_ command: String, args: [String] = []) {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
    process.arguments = [command] + args

    do {
        try process.run()
    } catch {
        print("Error running command: \(error)")
    }
}