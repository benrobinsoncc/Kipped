import SwiftUI

struct AppIconSelectionContent: View {
    @Binding var selectedAppIcon: AppIconOption
    let onIconSelected: (AppIconOption) -> Void
    let accentColor: Color
    let tintedBackgrounds: Bool
    let currentColorScheme: ColorScheme?
    
    var body: some View {
        VStack(spacing: 20) {
            Text("App Icon")
                .font(.headline)
                .padding()
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 16) {
                ForEach(AppIconOption.allCases, id: \.self) { option in
                    Button(action: {
                        onIconSelected(option)
                    }) {
                        VStack {
                            Image(option.imagePreviewName)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 60, height: 60)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(selectedAppIcon == option ? accentColor : Color.clear, lineWidth: 3)
                                )
                            
                            Text(option.displayName)
                                .font(.caption)
                                .foregroundColor(.primary)
                        }
                    }
                }
            }
            .padding()
        }
    }
}