import SwiftUI

struct SkeuomorphicSaveButton: View {
    let accentColor: Color
    let isEnabled: Bool
    let action: () -> Void
    @State private var isPressed = false
    
    private var buttonSize: CGFloat { 64 }
    
    private var brightColor: Color {
        let uiColor = UIColor(accentColor)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        return Color(
            red: min(1.0, r + 0.3),
            green: min(1.0, g + 0.3),
            blue: min(1.0, b + 0.3)
        )
    }
    
    private var darkColor: Color {
        let uiColor = UIColor(accentColor)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        return Color(
            red: max(0.0, r - 0.4),
            green: max(0.0, g - 0.4),
            blue: max(0.0, b - 0.4)
        )
    }
    
    private var mainGradient: RadialGradient {
        RadialGradient(
            gradient: Gradient(stops: [
                .init(color: brightColor.opacity(0.95), location: 0.0),
                .init(color: accentColor, location: 0.4),
                .init(color: darkColor.opacity(0.8), location: 0.8),
                .init(color: darkColor.opacity(0.9), location: 1.0)
            ]),
            center: UnitPoint(x: 0.3, y: 0.3),
            startRadius: 0,
            endRadius: buttonSize * 0.8
        )
    }
    
    var body: some View {
        Button(action: {
            if isEnabled {
                HapticsManager.shared.impact(.soft)
                action()
            }
        }) {
            ZStack {
                // Shadow
                Circle()
                    .fill(Color.black.opacity(0.1))
                    .frame(width: buttonSize + 4, height: buttonSize + 4)
                    .blur(radius: 2)
                    .offset(x: 0, y: 2)
                
                // Main button with material texture
                Circle()
                    .fill(mainGradient)
                    .frame(width: buttonSize, height: buttonSize)
                    .materialStyle(accentColor: accentColor)
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(stops: [
                                        .init(color: Color.white.opacity(0.4), location: 0.0),
                                        .init(color: Color.clear, location: 0.15),
                                        .init(color: Color.clear, location: 0.85),
                                        .init(color: Color.black.opacity(0.4), location: 1.0)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 3
                            )
                    )
                    .overlay(
                        // Inner rim
                        Circle()
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(stops: [
                                        .init(color: Color.white.opacity(0.9), location: 0.0),
                                        .init(color: Color.white.opacity(0.3), location: 0.3),
                                        .init(color: Color.clear, location: 0.7),
                                        .init(color: Color.black.opacity(0.5), location: 1.0)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                            .frame(width: buttonSize - 4, height: buttonSize - 4)
                    )
                    .overlay(
                        // Gloss overlay
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(stops: [
                                        .init(color: Color.white.opacity(0.6), location: 0.0),
                                        .init(color: Color.white.opacity(0.2), location: 0.3),
                                        .init(color: Color.clear, location: 0.7),
                                        .init(color: Color.clear, location: 1.0)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: buttonSize * 0.7, height: buttonSize * 0.7)
                            .offset(x: -buttonSize * 0.1, y: -buttonSize * 0.1)
                    )
                    .shadow(color: .black.opacity(0.3), radius: 12, x: 0, y: 6)
                    .shadow(color: accentColor.opacity(0.3), radius: 8, x: 0, y: 4)
                    .scaleEffect(isPressed ? 0.92 : 1.0)
                
                // Up arrow icon
                Image(systemName: "arrow.up")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .scaleEffect(isPressed ? 0.85 : 1.0)
            }
            .opacity(isEnabled ? 1.0 : 0.5)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!isEnabled)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            if isEnabled {
                withAnimation(.easeInOut(duration: 0.12)) {
                    isPressed = pressing
                }
            }
        }, perform: {})
    }
}