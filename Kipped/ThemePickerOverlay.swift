import SwiftUI

struct ThemePickerContent: View {
    @Binding var appTheme: AppTheme
    let onThemeSelected: (AppTheme) -> Void
    let accentColor: Color
    let tintedBackgrounds: Bool
    let currentColorScheme: ColorScheme?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
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
            .navigationTitle("Theme")
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