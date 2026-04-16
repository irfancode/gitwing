import SwiftUI

struct DiffView: View {
    @State private var diffContent = ""
    @State private var selectedFile = ""
    @State private var diffLines: [DiffLine] = []
    @State private var showingSettings = false

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Diff Viewer")
                    .font(.headline)
                Spacer()
                Button(action: { showingSettings = true }) {
                    Image(systemName: "gearshape")
                }
                .buttonStyle(.plain)
            }

            if selectedFile.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    Text("Select a file to view diff")
                        .foregroundColor(.secondary)
                    Button("View Working Changes") {
                        viewWorkingDiff()
                    }
                    .buttonStyle(.bordered)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Text(selectedFile)
                    .font(.caption)
                    .foregroundColor(.secondary)

                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 2) {
                        ForEach(diffLines) { line in
                            HStack(alignment: .top, spacing: 8) {
                                Text("\(line.lineNumber)")
                                    .font(.system(.caption, design: .monospaced))
                                    .foregroundColor(.secondary)
                                    .frame(width: 30, alignment: .trailing)

                                Text(line.content)
                                    .font(.system(.caption, design: .monospaced))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 4)
                                    .padding(.vertical, 2)
                                    .background(line.backgroundColor)
                                    .cornerRadius(2)
                            }
                        }
                    }
                }
                .background(Color(nsColor: .textBackgroundColor))
            }
        }
        .padding()
        .sheet(isPresented: $showingSettings) {
            DiffSettingsView()
        }
    }

    private func viewWorkingDiff() {
        guard let repoPath = UserDefaults.standard.stringArray(forKey: "repositories")?.first else { return }

        let process = Process()
        let pipe = Pipe()
        process.executableURL = URL(fileURLWithPath: "/opt/homebrew/bin/git")
        process.arguments = ["diff"]
        process.currentDirectoryURL = URL(fileURLWithPath: repoPath)
        process.standardOutput = pipe
        process.standardError = pipe

        do {
            try process.run()
            process.waitUntilExit()

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8) ?? ""
            parseDiff(output)
            selectedFile = "Working Changes"
        } catch {
            print("Error: \(error)")
        }
    }

    private func parseDiff(_ output: String) {
        var lines: [DiffLine] = []
        var currentLineNumber = 1

        let outputLines = output.split(separator: "\n", omittingEmptySubsequences: false)
        for line in outputLines {
            let text = String(line)
            var backgroundColor = Color.clear

            if text.hasPrefix("+") && !text.hasPrefix("+++") {
                backgroundColor = Color.green.opacity(0.15)
            } else if text.hasPrefix("-") && !text.hasPrefix("---") {
                backgroundColor = Color.red.opacity(0.15)
            } else if text.hasPrefix("@@") {
                backgroundColor = Color.blue.opacity(0.1)
            }

            lines.append(DiffLine(lineNumber: currentLineNumber, content: text, backgroundColor: backgroundColor))
            currentLineNumber += 1
        }

        diffLines = lines
    }
}

struct DiffLine: Identifiable {
    let id = UUID()
    let lineNumber: Int
    let content: String
    let backgroundColor: Color
}

struct DiffSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("diffTheme") private var diffTheme = "default"
    @AppStorage("wordWrap") private var wordWrap = true

    var body: some View {
        VStack(spacing: 16) {
            Text("Diff Settings")
                .font(.headline)

            Toggle("Word Wrap", isOn: $wordWrap)

            Picker("Theme", selection: $diffTheme) {
                Text("Default").tag("default")
                Text("Monokai").tag("monokai")
                Text("Solarized").tag("solarized")
            }

            HStack {
                Button("Cancel") { dismiss() }
                Button("Save") { dismiss() }
            }
        }
        .padding()
        .frame(width: 250, height: 200)
    }
}