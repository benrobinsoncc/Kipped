import SwiftUI

struct AppIconSelectionContent: View {
    @Binding var selectedAppIcon: AppIconOption
    let onIconSelected: (AppIconOption) -> Void
    let accentColor: Color
    let tintedBackgrounds: Bool
    let currentColorScheme: ColorScheme?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 12) {
                // Row spacing slightly increased, column spacing slightly reduced
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 3), spacing: 12) {
                    ForEach(AppIconOption.allCases, id: \.self) { option in
                        Button(action: {
                            onIconSelected(option)
                        }) {
                            Image(option.imagePreviewName)
                                .resizable()
                                .aspectRatio(1, contentMode: .fit)
                                .frame(width: 88, height: 88)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(selectedAppIcon == option ? accentColor : Color.clear, lineWidth: 3)
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 12)
            }
            .navigationTitle("App icon")
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