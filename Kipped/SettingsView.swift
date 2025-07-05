import SwiftUI
import UIKit

enum AppIconOption: String, CaseIterable {
    case `default` = "AppIcon"
    case option1 = "AppIcon 1"
    case option2 = "AppIcon 2"
    case option3 = "AppIcon 3"
    case option4 = "AppIcon 4"
    case option5 = "AppIcon 5"
    case option6 = "AppIcon 6"
    case option7 = "AppIcon 7"
    case option8 = "AppIcon 8"
    
    var displayName: String {
        switch self {
        case .default: return "Default"
        case .option1: return "Style 1"
        case .option2: return "Style 2"
        case .option3: return "Style 3"
        case .option4: return "Style 4"
        case .option5: return "Style 5"
        case .option6: return "Style 6"
        case .option7: return "Style 7"
        case .option8: return "Style 8"
        }
    }
    
    var iconName: String {
        switch self {
        case .default: return "app"
        case .option1: return "app.fill"
        case .option2: return "app.badge"
        case .option3: return "app.badge.fill"
        case .option4: return "app.badge.checkmark"
        case .option5: return "app.badge.plus"
        case .option6: return "app.dashed"
        case .option7: return "app.gift"
        case .option8: return "app.connected.to.line.below"
        }
    }
    
    var color: Color {
        switch self {
        case .default: return .red
        case .option1: return .purple
        case .option2: return .orange
        case .option3: return .pink
        case .option4: return .green
        case .option5: return .red
        case .option6: return .blue
        case .option7: return .yellow
        case .option8: return .teal
        }
    }
    
    var imagePreviewName: String {
        switch self {
        case .default: return "AppIconPreview"
        case .option1: return "AppIconPreview1"
        case .option2: return "AppIconPreview2"
        case .option3: return "AppIconPreview3"
        case .option4: return "AppIconPreview4"
        case .option5: return "AppIconPreview5"
        case .option6: return "AppIconPreview6"
        case .option7: return "AppIconPreview7"
        case .option8: return "AppIconPreview8"
        }
    }
}

struct SettingsView: View {
    @Binding var appTheme: AppTheme
    @Binding var accentColor: Color
    @Binding var notificationsEnabled: Bool
    var colorScheme: ColorScheme?
    @ObservedObject var todoViewModel: TodoViewModel
    @State private var selectedArchivedTodo: Todo? = nil
    @Binding var selectedAppIcon: AppIconOption
    var onShowAccentSheet: (() -> Void)? = nil
    var onShowAppIconSheet: (() -> Void)? = nil
    var onShowThemeSheet: (() -> Void)? = nil
    
    let accentColors: [(Color, String)] = [
        (.blue, "Blue"),
        (.red, "Red"),
        (.green, "Green"),
        (.orange, "Orange"),
        (.purple, "Purple"),
        (.pink, "Pink"),
        (.teal, "Teal"),
        (.yellow, "Yellow")
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // CUSTOMIZE Section
            VStack(alignment: .leading, spacing: 0) {
                Text("CUSTOMIZE")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
                    .padding(.bottom, 8)
                
                VStack(spacing: 0) {
                    // Theme Row
                    Button(action: {
                        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                        onShowThemeSheet?()
                    }) {
                        HStack {
                            Image(systemName: "paintbrush")
                                .foregroundColor(.primary)
                            Text("Theme")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color(UIColor.secondarySystemBackground))
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Accent Color Row
                    Button(action: { 
                        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                        onShowAccentSheet?()
                    }) {
                        HStack {
                            Image(systemName: "paintpalette")
                                .foregroundColor(.primary)
                            Text("Accent Color")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color(UIColor.secondarySystemBackground))
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // App Icon Row
                    Button(action: { 
                        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                        onShowAppIconSheet?()
                    }) {
                        HStack {
                            Image(systemName: "app.badge")
                                .foregroundColor(.primary)
                            Text("App Icon")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color(UIColor.secondarySystemBackground))
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .cornerRadius(10)
            }
            
            // NOTIFICATIONS Section
            VStack(alignment: .leading, spacing: 0) {
                Text("NOTIFICATIONS")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
                    .padding(.bottom, 8)
                
                VStack(spacing: 0) {
                    HStack {
                        Text("Enable Notifications")
                            .foregroundColor(.primary)
                        Spacer()
                        Toggle("", isOn: $notificationsEnabled)
                            .tint(accentColor)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(UIColor.secondarySystemBackground))
                }
                .cornerRadius(10)
            }
            
            // ARCHIVED TODOS Section
            VStack(alignment: .leading, spacing: 0) {
                Text("ARCHIVED TODOS")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
                    .padding(.bottom, 8)
                
                VStack(spacing: 0) {
                    if todoViewModel.archivedTodos.isEmpty {
                        HStack {
                            Text("No archived todos yet")
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color(UIColor.secondarySystemBackground))
                    } else {
                        ForEach(todoViewModel.archivedTodos) { todo in
                            Button(action: { selectedArchivedTodo = todo }) {
                                HStack {
                                    Text(todo.title)
                                        .foregroundColor(.primary)
                                        .lineLimit(1)
                                    Spacer()
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color(UIColor.secondarySystemBackground))
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(PlainButtonStyle())
                            .contextMenu {
                                Button(action: {
                                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                                    UIPasteboard.general.string = todo.title
                                }) {
                                    Text("Copy")
                                }
                            }
                        }
                    }
                }
                .cornerRadius(10)
            }
        }
        .padding(.top, 20)
        .sheet(item: $selectedArchivedTodo) { todo in
            AddTodoView(todoViewModel: todoViewModel, todoToEdit: todo, colorScheme: .constant(colorScheme ?? .dark), accentColor: $accentColor, isArchivedMode: true) {
                todoViewModel.unarchiveTodo(todo)
                selectedArchivedTodo = nil
            }
        }
        .preferredColorScheme(colorScheme)
    }
}

// UIKit blur wrapper for strong overlay effect
struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: effect)
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = effect
    }
} 