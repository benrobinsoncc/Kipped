import SwiftUI

struct AccentColorPickerContent: View {
    @Binding var accentColor: Color
    @Binding var tintedBackgrounds: Bool
    let colors: [(Color, String)]
    let onColorSelected: (Color) -> Void
    let currentColorScheme: ColorScheme?
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Accent Color")
                .font(.headline)
                .padding()
            
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
    }
    
    private func isColorSelected(_ color: Color) -> Bool {
        // Simple color comparison
        return color == accentColor
    }
}