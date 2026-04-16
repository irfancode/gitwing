import SwiftUI
import AppKit

@main
struct GitWingApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popover: NSPopover?

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupMenuBarApp()
    }

    private func setupMenuBarApp() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "arrow.triangle.branch", accessibilityDescription: "GitWing")
            button.action = togglePopover
            button.target = self
        }

        popover = NSPopover()
        popover?.contentSize = NSSize(width: 400, height: 500)
        popover?.behavior = .transient
        popover?.contentViewController = NSHostingController(rootView: GitWingMainView())
    }

    @objc private func togglePopover() {
        guard let popover = popover else { return }

        if popover.isShown {
            popover.performClose(nil)
        } else if let button = statusItem?.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }
}

struct GitWingMainView: View {
    @State private var selectedTab = 0

    var body: some View {
        VStack(spacing: 0) {
            Picker("", selection: $selectedTab) {
                Text("Worktrees").tag(0)
                Text("Commits").tag(1)
                Text("Diffs").tag(2)
                Text("Commands").tag(3)
            }
            .pickerStyle(.segmented)
            .padding()

            TabView(selection: $selectedTab) {
                WorktreeView()
                    .tag(0)

                CommitView()
                    .tag(1)

                DiffView()
                    .tag(2)

                CommandsView()
                    .tag(3)
            }
        }
        .frame(width: 400, height: 500)
    }
}