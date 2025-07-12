import SwiftUI

struct FontPickerContent: View {
    @Binding var selectedFont: FontOption
    let onFontSelected: (FontOption) -> Void
    let accentColor: Color
    let tintedBackgrounds: Bool
    let currentColorScheme: ColorScheme?
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Font")
                .font(.headline)
                .padding()
            
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
    }
}