import SwiftUI

struct ThemePickerContent: View {
    @Binding var appTheme: AppTheme
    let onThemeSelected: (AppTheme) -> Void
    let accentColor: Color
    let tintedBackgrounds: Bool
    let currentColorScheme: ColorScheme?
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Theme")
                .font(.headline)
                .padding()
            
            HStack(spacing: 20) {
                ForEach(AppTheme.allCases, id: \.self) { theme in
                    Button(action: {
                        onThemeSelected(theme)
                    }) {
                        Text(theme.displayName)
                            .padding()
                            .background(appTheme == theme ? accentColor : Color.gray.opacity(0.3))
                            .foregroundColor(appTheme == theme ? .white : .primary)
                            .cornerRadius(8)
                    }
                }
            }
            .padding()
        }
    }
}