import SwiftUI

struct FontPickerContent: View {
    @Binding var selectedFont: FontOption
    let onFontSelected: (FontOption) -> Void
    let accentColor: Color
    let tintedBackgrounds: Bool
    let currentColorScheme: ColorScheme?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 12) {
                VStack(spacing: 12) {
                    ForEach(FontOption.allCases, id: \.self) { font in
                        Button(action: {
                            onFontSelected(font)
                        }) {
                            HStack {
                                Text(font.displayName)
                                    .font(font.font)
                                    .foregroundColor(.primary)
                                Spacer()
                                if selectedFont == font {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(accentColor)
                                }
                            }
                            .padding()
                            .background(selectedFont == font ? accentColor.opacity(0.1) : Color.clear)
                            .cornerRadius(8)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Font")
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
}