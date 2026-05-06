import SwiftUI

extension Color {
    init(hex: UInt32, opacity: Double = 1.0) {
        let r = Double((hex >> 16) & 0xFF) / 255
        let g = Double((hex >> 8) & 0xFF) / 255
        let b = Double(hex & 0xFF) / 255
        self.init(.sRGB, red: r, green: g, blue: b, opacity: opacity)
    }

    static func adaptive(light: UInt32, dark: UInt32) -> Color {
        Color(NSColor(name: nil) { appearance in
            let isDark = appearance.bestMatch(from: [.darkAqua, .vibrantDark]) != nil
            let hex = isDark ? dark : light
            let r = CGFloat((hex >> 16) & 0xFF) / 255
            let g = CGFloat((hex >> 8) & 0xFF) / 255
            let b = CGFloat(hex & 0xFF) / 255
            return NSColor(srgbRed: r, green: g, blue: b, alpha: 1.0)
        })
    }
}

enum AppTheme {
    // Status colors: muted jewel tones, perceptually balanced
    static let statusTodo = Color.adaptive(light: 0x8E8B99, dark: 0xA6A1B4)
    static let statusDoing = Color.adaptive(light: 0x6B5BFF, dark: 0x8B7DFF)
    static let statusDone = Color.adaptive(light: 0x4FB286, dark: 0x6FCBA0)

    // Brand accent (matches Doing for cohesion)
    static let accent = Color.adaptive(light: 0x6B5BFF, dark: 0x8B7DFF)

    // Surfaces
    static let appBackground = Color.adaptive(light: 0xF7F5F1, dark: 0x15131A)
    static let cardTint = Color.adaptive(light: 0x6B5BFF, dark: 0x8B7DFF)
}

extension TodoStatus {
    var themeColor: Color {
        switch self {
        case .todo: return AppTheme.statusTodo
        case .doing: return AppTheme.statusDoing
        case .done: return AppTheme.statusDone
        }
    }
}

// MARK: - Genie swirl transition for icon morph

private struct GenieIconModifier: ViewModifier {
    let rotation: Double
    let scale: CGFloat
    let opacity: Double
    let blur: CGFloat

    func body(content: Content) -> some View {
        content
            .rotationEffect(.degrees(rotation))
            .scaleEffect(scale)
            .blur(radius: blur)
            .opacity(opacity)
    }
}

extension AnyTransition {
    static var genieSwirl: AnyTransition {
        .asymmetric(
            insertion: .modifier(
                active: GenieIconModifier(rotation: -180, scale: 0.1, opacity: 0, blur: 4),
                identity: GenieIconModifier(rotation: 0, scale: 1.0, opacity: 1, blur: 0)
            ),
            removal: .modifier(
                active: GenieIconModifier(rotation: 180, scale: 0.1, opacity: 0, blur: 4),
                identity: GenieIconModifier(rotation: 0, scale: 1.0, opacity: 1, blur: 0)
            )
        )
    }
}

struct ViewModeToggleButton: View {
    @Binding var viewMode: ViewMode

    private var symbolName: String {
        viewMode == .list ? "list.bullet" : "rectangle.split.3x1"
    }

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.72)) {
                viewMode = (viewMode == .list) ? .kanban : .list
            }
        } label: {
            ZStack {
                Image(systemName: symbolName)
                    .symbolRenderingMode(.hierarchical)
                    .id(symbolName)
                    .transition(.genieSwirl)
            }
        }
        .help(viewMode == .list ? "Switch to Kanban" : "Switch to List")
    }
}
