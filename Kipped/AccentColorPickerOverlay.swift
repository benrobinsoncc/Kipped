import SwiftUI

struct AccentColorPickerContent: View {
    @Binding var accentColor: Color
    @Binding var tintedBackgrounds: Bool
    let colors: [(Color, String)]
    let onColorSelected: (Color) -> Void
    let currentColorScheme: ColorScheme?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 16) {
                    ForEach(MaterialColorCategory.allCategories.first?.colors ?? [], id: \.name) { colorInfo in
                        Button(action: {
                            onColorSelected(colorInfo.color)
                        }) {
                            Circle()
                                .fill(colorInfo.color)
                                .frame(width: 60, height: 60)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: isColorSelected(colorInfo.color) ? 3 : 0)
                                )
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Accent colour")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        ZStack {
                            Circle()
                                .fill(Color.secondary.opacity(0.15))
                                .frame(width: 28, height: 28)
                            Image(systemName: "xmark")
                                .foregroundColor(.secondary.opacity(0.7))
                                .font(.system(size: 11, weight: .bold))
                        }
                    }
                }
            }
        }
        .preferredColorScheme(currentColorScheme)
    }
    
    private func isColorSelected(_ color: Color) -> Bool {
        // Simple color comparison
        return color == accentColor
    }
}