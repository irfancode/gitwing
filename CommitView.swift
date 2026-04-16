import SwiftUI

struct CommitView: View {
    @State private var stagedFiles: [String] = []
    @State private var unstagedFiles: [String] = []
    @State private var commitMessage = ""
    @State private var isAILoading = false
    @State private var selectedRepoPath = ""

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Staged")
                    .font(.headline)
                Spacer()
                Button(action: generateAIMessage) {
                    if isAILoading {
                        ProgressView()
                            .scaleEffect(0.7)
                    } else {
                        Image(systemName: "wand.and.stars")
                    }
                }
                .buttonStyle(.bordered)
                .disabled(isAILoading || stagedFiles.isEmpty)
            }

            if stagedFiles.isEmpty {
                Text("No staged files")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 4) {
                        ForEach(stagedFiles, id: \.self) { file in
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.green)
                                Text(file)
                                    .font(.system(.caption, design: .monospaced))
                                Spacer()
                            }
                            .padding(4)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(4)
                        }
                    }
                }
                .frame(height: 80)
            }

            Divider()

            HStack {
                Text("Unstaged")
                    .font(.headline)
                Spacer()
            }

            if unstagedFiles.isEmpty {
                Text("No unstaged changes")
                    .foregroundColor(.secondary)
            } else {
                ScrollView {
                    LazyVStack(spacing: 4) {
                        ForEach(unstagedFiles, id: \.self) { file in
                            HStack {
                                Image(systemName: "pencil.circle")
                                    .foregroundColor(.orange)
                                Text(file)
                                    .font(.system(.caption, design: .monospaced))
                                Spacer()
                            }
                            .padding(4)
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(4)
                        }
                    }
                }
                .frame(height: 80)
            }

            Divider()

            TextField("Commit message...", text: $commitMessage)
                .textFieldStyle(.roundedBorder)

            HStack {
                Button("Stage All") { stageAll() }
                Button("Commit") { makeCommit() }
                    .buttonStyle(.borderedProminent)
                    .disabled(commitMessage.isEmpty || stagedFiles.isEmpty)
            }
        }
        .padding()
        .onAppear { refreshStatus() }
    }

    private func refreshStatus() {
        guard let repoPath = UserDefaults.standard.stringArray(forKey: "repositories")?.first else { return }
        selectedRepoPath = repoPath

        stagedFiles = getGitOutput(repoPath, args: ["diff", "--cached", "--name-only"]).split(separator: "\n").map(String.init)
        unstagedFiles = getGitOutput(repoPath, args: ["diff", "--name-only"]).split(separator: "\n").map(String.init)
    }

    private func stageAll() {
        guard !selectedRepoPath.isEmpty else { return }
        _ = getGitOutput(selectedRepoPath, args: ["add", "-A"])
        refreshStatus()
    }

    private func makeCommit() {
        guard !selectedRepoPath.isEmpty && !commitMessage.isEmpty else { return }
        _ = getGitOutput(selectedRepoPath, args: ["commit", "-m", commitMessage])
        commitMessage = ""
        refreshStatus()
    }

    private func generateAIMessage() {
        guard !stagedFiles.isEmpty else { return }
        isAILoading = true

        DispatchQueue.global(qos: .userInitiated).async {
            let diff = getGitOutput(selectedRepoPath, args: ["diff", "--cached"])
            let suggestedMessage = generateCommitSuggestion(from: diff)

            DispatchQueue.main.async {
                self.commitMessage = suggestedMessage
                self.isAILoading = false
            }
        }
    }

    private func getGitOutput(_ directory: String, args: [String]) -> String {
        let process = Process()
        let pipe = Pipe()

        process.executableURL = URL(fileURLWithPath: "/opt/homebrew/bin/git")
        process.arguments = args
        process.currentDirectoryURL = URL(fileURLWithPath: directory)
        process.standardOutput = pipe
        process.standardError = pipe

        do {
            try process.run()
            process.waitUntilExit()

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            return String(data: data, encoding: .utf8) ?? ""
        } catch {
            return ""
        }
    }

    private func generateCommitSuggestion(from diff: String) -> String {
        if diff.contains("add") || diff.contains("new") {
            return "Add new features and functionality"
        } else if diff.contains("fix") || diff.contains("bug") {
            return "Fix bugs and improve stability"
        } else if diff.contains("update") || diff.contains("change") {
            return "Update and improve existing code"
        } else if diff.contains("refactor") {
            return "Refactor code for better maintainability"
        } else if diff.contains("test") {
            return "Add and update tests"
        } else if diff.contains("doc") {
            return "Update documentation"
        }
        return "Make improvements and fixes"
    }
}