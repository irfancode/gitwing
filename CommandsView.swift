import SwiftUI

struct CommandsView: View {
    @State private var searchText = ""
    @State private var commandOutput = ""
    @State private var isRunning = false

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Quick Commands")
                    .font(.headline)
                Spacer()
                Image(systemName: "command")
                    .foregroundColor(.secondary)
            }

            TextField("Search commands...", text: $searchText)
                .textFieldStyle(.roundedBorder)

            if filteredCommands.isEmpty {
                Text("Type to search commands")
                    .foregroundColor(.secondary)
                    .frame(maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(filteredCommands) { command in
                            CommandRow(command: command) {
                                runCommand(command)
                            }
                        }
                    }
                }
            }

            if !commandOutput.isEmpty {
                Divider()
                ScrollView {
                    Text(commandOutput)
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(height: 100)
                .background(Color(nsColor: .textBackgroundColor))
                .cornerRadius(8)
            }
        }
        .padding()
    }

    private var filteredCommands: [GitCommand] {
        if searchText.isEmpty {
            return commonCommands
        } else {
            return commonCommands.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    private var commonCommands: [GitCommand] {
        [
            GitCommand(name: "status", description: "Show working tree status", args: ["status"]),
            GitCommand(name: "log -10", description: "Show last 10 commits", args: ["log", "-10", "--oneline"]),
            GitCommand(name: "branch -a", description: "List all branches", args: ["branch", "-a"]),
            GitCommand(name: "stash list", description: "List all stashes", args: ["stash", "list"]),
            GitCommand(name: "fetch --all", description: "Fetch all remotes", args: ["fetch", "--all"]),
            GitCommand(name: "pull", description: "Pull current branch", args: ["pull"]),
            GitCommand(name: "push", description: "Push current branch", args: ["push"]),
            GitCommand(name: "diff --stat", description: "Show diff stats", args: ["diff", "--stat"]),
            GitCommand(name: "clean -fd", description: "Clean untracked files", args: ["clean", "-fd", "-n"]),
            GitCommand(name: "reset --soft HEAD~1", description: "Undo last commit", args: ["reset", "--soft", "HEAD~1"]),
            GitCommand(name: "reflog", description: "Show reference log", args: ["reflog", "-20"]),
            GitCommand(name: "tag", description: "List all tags", args: ["tag", "-l"]),
        ]
    }

    private func runCommand(_ command: GitCommand) {
        isRunning = true
        commandOutput = ""

        DispatchQueue.global(qos: .userInitiated).async {
            let output = runGitCommand(args: command.args)

            DispatchQueue.main.async {
                self.commandOutput = output
                self.isRunning = false
            }
        }
    }

    private func runGitCommand(args: [String]) -> String {
        guard let repoPath = UserDefaults.standard.stringArray(forKey: "repositories")?.first else {
            return "No repository selected. Add a repo in Worktrees tab."
        }

        let process = Process()
        let pipe = Pipe()
        let errorPipe = Pipe()

        process.executableURL = URL(fileURLWithPath: "/opt/homebrew/bin/git")
        process.arguments = args
        process.currentDirectoryURL = URL(fileURLWithPath: repoPath)
        process.standardOutput = pipe
        process.standardError = errorPipe

        do {
            try process.run()
            process.waitUntilExit()

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()

            var output = String(data: data, encoding: .utf8) ?? ""
            let errorOutput = String(data: errorData, encoding: .utf8) ?? ""

            if !errorOutput.isEmpty {
                output += "\nErrors: \(errorOutput)"
            }

            if output.isEmpty {
                output = "Command executed successfully."
            }

            return output
        } catch {
            return "Error: \(error.localizedDescription)"
        }
    }
}

struct GitCommand: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let args: [String]
}

struct CommandRow: View {
    let command: GitCommand
    let onRun: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(command.name)
                    .font(.system(.body, design: .monospaced))
                Text(command.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Button("Run") {
                onRun()
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
        .padding(8)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(8)
    }
}