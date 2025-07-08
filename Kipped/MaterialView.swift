import SwiftUI

// MARK: - Global Material Rendering System
struct MaterialView<Content: View>: View {
    let content: Content
    let accentColor: Color
    
    @Environment(\.colorScheme) private var colorScheme
    
    init(accentColor: Color, @ViewBuilder content: () -> Content) {
        self.accentColor = accentColor
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            content
                .foregroundColor(accentColor)
                .overlay(materialTexture)
        }
    }
    
    // MARK: - Material Texture System
    @ViewBuilder
    private var materialTexture: some View {
        if let materialInfo = getCurrentMaterialInfo() {
            switch materialInfo.type {
            case .solid:
                EmptyView()
            case .metallic:
                metallicTexture
            case .stone:
                stoneTexture
            case .gemstone:
                gemstoneTexture
            case .brushedMetal:
                brushedMetalTexture
            case .patinaMetal:
                patinaMetalTexture
            case .carbonFiber:
                carbonFiberTexture
            case .anodized:
                anodizedTexture
            case .leather:
                leatherTexture
            case .fabric:
                fabricTexture
            case .velvet:
                velvetTexture
            case .canvas:
                canvasTexture
            case .prismatic:
                prismaticTexture
            case .opalescent:
                opalescentTexture
            case .holographic:
                holographicTexture
            case .iridescent:
                iridescentTexture
            }
        }
    }
    
    // MARK: - Helper Functions
    private func getCurrentMaterialInfo() -> MaterialColorInfo? {
        for category in MaterialColorCategory.allCategories {
            for colorInfo in category.colors {
                if areColorsEqual(colorInfo.color, accentColor) {
                    return colorInfo
                }
            }
        }
        return nil
    }
    
    private func areColorsEqual(_ color1: Color, _ color2: Color) -> Bool {
        let uiColor1 = UIColor(color1)
        let uiColor2 = UIColor(color2)
        
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        
        uiColor1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        uiColor2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        
        let tolerance: CGFloat = 0.01
        return abs(r1 - r2) < tolerance && abs(g1 - g2) < tolerance && abs(b1 - b2) < tolerance
    }
    
    // MARK: - Enhanced Texture Implementations
    
    @ViewBuilder
    private var metallicTexture: some View {
        LinearGradient(
            colors: [
                .white.opacity(0.3),
                .clear,
                .black.opacity(0.2)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .blendMode(.overlay)
    }
    
    @ViewBuilder
    private var stoneTexture: some View {
        ZStack {
            ForEach(0..<15, id: \.self) { i in
                Circle()
                    .fill(.white.opacity(0.1))
                    .frame(width: CGFloat(2 + i % 3), height: CGFloat(2 + i % 3))
                    .offset(
                        x: sin(Double(i) * 2.4) * 15,
                        y: cos(Double(i) * 1.8) * 12
                    )
            }
        }
        .blendMode(.overlay)
    }
    
    @ViewBuilder
    private var gemstoneTexture: some View {
        ZStack {
            ForEach(0..<6, id: \.self) { i in
                Triangle()
                    .fill(LinearGradient(
                        colors: [.white.opacity(0.4), .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    ))
                    .frame(width: 8, height: 12)
                    .rotationEffect(.degrees(Double(i) * 60))
                    .offset(x: sin(Double(i) * .pi / 3) * 6)
            }
        }
        .blendMode(.screen)
    }
    
    @ViewBuilder
    private var brushedMetalTexture: some View {
        ZStack {
            // Strong metallic base with dramatic shine
            LinearGradient(
                colors: [
                    .white.opacity(0.8),
                    .gray.opacity(0.4),
                    .black.opacity(0.6),
                    .white.opacity(0.3)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Dramatic brush lines - much more visible
            ForEach(0..<60, id: \.self) { i in
                Rectangle()
                    .fill(LinearGradient(
                        colors: [
                            .white.opacity(0.95),
                            .clear,
                            .black.opacity(0.8)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    ))
                    .frame(width: 1.5, height: 80)
                    .offset(x: CGFloat(i - 30) * 1.0)
                    .rotationEffect(.degrees(Double(i % 5) * 2 - 4)) // More variation
            }
            
            // Metallic highlight streaks
            ForEach(0..<8, id: \.self) { i in
                Rectangle()
                    .fill(.white.opacity(0.9))
                    .frame(width: 0.5, height: 60)
                    .offset(x: CGFloat(i - 4) * 8)
                    .blur(radius: 0.5)
            }
            
            // Deep scratches
            ForEach(0..<12, id: \.self) { i in
                Rectangle()
                    .fill(.black.opacity(0.6))
                    .frame(width: 0.3, height: 40)
                    .offset(x: CGFloat(i - 6) * 6)
                    .rotationEffect(.degrees(Double(i % 3) * 3))
            }
        }
        .blendMode(.multiply)
    }
    
    @ViewBuilder
    private var patinaMetalTexture: some View {
        ZStack {
            ForEach(0..<12, id: \.self) { i in
                Circle()
                    .fill(RadialGradient(
                        colors: [
                            .mint.opacity(0.6),
                            .cyan.opacity(0.3),
                            .clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 4
                    ))
                    .frame(width: CGFloat(3 + i % 4), height: CGFloat(3 + i % 4))
                    .offset(
                        x: sin(Double(i) * 2.1) * 18,
                        y: cos(Double(i) * 1.7) * 15
                    )
            }
        }
        .blendMode(.multiply)
    }
    
    @ViewBuilder
    private var carbonFiberTexture: some View {
        ZStack {
            // Dark carbon base
            Rectangle()
                .fill(.black.opacity(0.9))
            
            // Prominent horizontal weave - much thicker and more visible
            ForEach(0..<8, id: \.self) { i in
                Rectangle()
                    .fill(LinearGradient(
                        colors: [
                            .gray.opacity(0.8),
                            .black.opacity(0.9),
                            .gray.opacity(0.6)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
                    .frame(width: 80, height: 4)
                    .offset(y: CGFloat(i - 4) * 8)
            }
            
            // Prominent vertical weave - interlaced pattern
            ForEach(0..<8, id: \.self) { i in
                Rectangle()
                    .fill(LinearGradient(
                        colors: [
                            .white.opacity(0.4),
                            .gray.opacity(0.2),
                            .white.opacity(0.3)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    ))
                    .frame(width: 4, height: 80)
                    .offset(x: CGFloat(i - 4) * 8)
                    .opacity(Double(i % 2) * 0.5 + 0.5) // Alternating visibility for weave effect
            }
            
            // Twill pattern diagonals - very visible
            ForEach(0..<12, id: \.self) { i in
                Rectangle()
                    .fill(.gray.opacity(0.7))
                    .frame(width: 2, height: 100)
                    .offset(x: CGFloat(i - 6) * 6)
                    .rotationEffect(.degrees(45))
            }
            
            // Glossy resin coating shine
            LinearGradient(
                colors: [
                    .white.opacity(0.4),
                    .clear,
                    .clear,
                    .white.opacity(0.2)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        .blendMode(.multiply)
    }
    
    @ViewBuilder
    private var anodizedTexture: some View {
        ZStack {
            ForEach(0..<8, id: \.self) { i in
                Circle()
                    .stroke(.white.opacity(0.2), lineWidth: 0.5)
                    .frame(width: CGFloat(4 + i * 3), height: CGFloat(4 + i * 3))
            }
        }
        .blendMode(.overlay)
    }
    
    @ViewBuilder
    private var leatherTexture: some View {
        ZStack {
            // Rich leather base color
            Rectangle()
                .fill(RadialGradient(
                    colors: [
                        .brown.opacity(0.8),
                        .black.opacity(0.6)
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: 30
                ))
            
            // Dramatic leather grain - much more visible
            ForEach(0..<80, id: \.self) { i in
                Circle()
                    .fill(.black.opacity(0.8))
                    .frame(width: CGFloat(2 + i % 4), height: CGFloat(1 + i % 3))
                    .offset(
                        x: sin(Double(i) * 2.7) * 25,
                        y: cos(Double(i) * 3.1) * 20
                    )
            }
            
            // Deep weathering cracks - very prominent
            ForEach(0..<20, id: \.self) { i in
                Capsule()
                    .fill(.black.opacity(0.9))
                    .frame(width: CGFloat(20 + i % 15), height: 3)
                    .rotationEffect(.degrees(Double(i) * 18))
                    .offset(
                        x: sin(Double(i) * 1.8) * 20,
                        y: cos(Double(i) * 2.4) * 15
                    )
            }
            
            // Dramatic worn patches
            ForEach(0..<10, id: \.self) { i in
                Ellipse()
                    .fill(LinearGradient(
                        colors: [
                            .brown.opacity(0.3),
                            .clear
                        ],
                        startPoint: .center,
                        endPoint: .bottom
                    ))
                    .frame(width: CGFloat(15 + i % 8), height: CGFloat(10 + i % 6))
                    .rotationEffect(.degrees(Double(i) * 36))
                    .offset(
                        x: sin(Double(i) * 1.2) * 22,
                        y: cos(Double(i) * 1.7) * 18
                    )
            }
            
            // Stitching lines for realism
            ForEach(0..<6, id: \.self) { i in
                Rectangle()
                    .fill(.yellow.opacity(0.6))
                    .frame(width: 40, height: 0.8)
                    .offset(
                        x: sin(Double(i) * 1.0) * 15,
                        y: CGFloat(i - 3) * 12
                    )
                    .rotationEffect(.degrees(Double(i) * 15))
            }
        }
        .blendMode(.multiply)
    }
    
    @ViewBuilder
    private var fabricTexture: some View {
        ZStack {
            // Denim base color
            Rectangle()
                .fill(.blue.opacity(0.7))
            
            // Thick horizontal threads - like real denim
            ForEach(0..<10, id: \.self) { i in
                Rectangle()
                    .fill(LinearGradient(
                        colors: [
                            .indigo.opacity(0.9),
                            .blue.opacity(0.6),
                            .indigo.opacity(0.8)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
                    .frame(width: 60, height: 2.5)
                    .offset(y: CGFloat(i - 5) * 6)
            }
            
            // Thick vertical threads - interlaced weave
            ForEach(0..<10, id: \.self) { i in
                Rectangle()
                    .fill(LinearGradient(
                        colors: [
                            .white.opacity(0.4),
                            .blue.opacity(0.3),
                            .indigo.opacity(0.5)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    ))
                    .frame(width: 2.5, height: 60)
                    .offset(x: CGFloat(i - 5) * 6)
                    .opacity(Double(i % 2) * 0.7 + 0.3) // Weave pattern
            }
            
            // Worn areas and fading
            ForEach(0..<8, id: \.self) { i in
                Circle()
                    .fill(.white.opacity(0.2))
                    .frame(width: CGFloat(6 + i % 4), height: CGFloat(6 + i % 4))
                    .offset(
                        x: sin(Double(i) * 2.2) * 20,
                        y: cos(Double(i) * 1.8) * 15
                    )
            }
        }
        .blendMode(.multiply)
    }
    
    @ViewBuilder
    private var velvetTexture: some View {
        ZStack {
            ForEach(0..<30, id: \.self) { i in
                Rectangle()
                    .fill(LinearGradient(
                        colors: [
                            .white.opacity(0.1),
                            .clear,
                            .black.opacity(0.1)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    ))
                    .frame(width: 0.5, height: 20)
                    .offset(x: CGFloat(i - 15) * 1.2)
                    .rotationEffect(.degrees(Double(i % 5) * 2))
            }
        }
        .blendMode(.overlay)
    }
    
    @ViewBuilder
    private var canvasTexture: some View {
        ZStack {
            // Heavy weave pattern
            ForEach(0..<5, id: \.self) { i in
                Rectangle()
                    .fill(.brown.opacity(0.3))
                    .frame(width: 40, height: 2)
                    .offset(y: CGFloat(i - 2) * 8)
            }
            
            ForEach(0..<5, id: \.self) { i in
                Rectangle()
                    .fill(.brown.opacity(0.2))
                    .frame(width: 2, height: 40)
                    .offset(x: CGFloat(i - 2) * 8)
            }
        }
        .blendMode(.multiply)
    }
    
    @ViewBuilder
    private var prismaticTexture: some View {
        ZStack {
            // Rainbow base with strong saturation
            AngularGradient(
                colors: [
                    .red, .orange, .yellow, .green, .cyan, .blue, .purple, .pink, .red
                ],
                center: .center
            )
            .opacity(0.7)
            
            // Dramatic spectral beams - much wider and more colorful
            ForEach(0..<12, id: \.self) { i in
                Rectangle()
                    .fill(LinearGradient(
                        colors: [
                            Color.rainbow(at: Double(i) / 12.0),
                            Color.rainbow(at: Double(i + 2) / 12.0),
                            Color.rainbow(at: Double(i + 4) / 12.0)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 8, height: 60)
                    .rotationEffect(.degrees(Double(i) * 30))
                    .offset(x: sin(Double(i) * .pi / 6) * 8)
                    .opacity(0.9)
            }
            
            // Large prismatic facets with bright colors
            ForEach(0..<8, id: \.self) { i in
                Triangle()
                    .fill(LinearGradient(
                        colors: [
                            .white,
                            Color.rainbow(at: Double(i) / 8.0),
                            Color.rainbow(at: Double(i + 2) / 8.0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    ))
                    .frame(width: 15, height: 20)
                    .rotationEffect(.degrees(Double(i) * 45))
                    .offset(
                        x: sin(Double(i) * .pi / 4) * 15,
                        y: cos(Double(i) * .pi / 4) * 12
                    )
                    .opacity(0.8)
            }
            
            // Bright refraction bursts
            ForEach(0..<6, id: \.self) { i in
                Circle()
                    .fill(RadialGradient(
                        colors: [
                            .white,
                            Color.rainbow(at: Double(i) / 6.0),
                            .clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 8
                    ))
                    .frame(width: 12, height: 12)
                    .offset(
                        x: sin(Double(i) * .pi / 3) * 20,
                        y: cos(Double(i) * .pi / 3) * 15
                    )
            }
        }
        .blendMode(.screen)
    }
    
    @ViewBuilder
    private var opalescentTexture: some View {
        ZStack {
            // Opal base with shifting colors
            RadialGradient(
                colors: [
                    .white.opacity(0.8),
                    .cyan.opacity(0.6),
                    .purple.opacity(0.4),
                    .orange.opacity(0.3)
                ],
                center: .center,
                startRadius: 0,
                endRadius: 40
            )
            
            // Large opalescent spots with bright colors
            ForEach(0..<12, id: \.self) { i in
                Circle()
                    .fill(RadialGradient(
                        colors: [
                            Color.rainbow(at: Double(i) / 12.0),
                            Color.rainbow(at: Double(i + 3) / 12.0),
                            .clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 12
                    ))
                    .frame(width: CGFloat(8 + i % 6), height: CGFloat(8 + i % 6))
                    .offset(
                        x: sin(Double(i) * 2.0) * 18,
                        y: cos(Double(i) * 1.6) * 15
                    )
                    .opacity(0.8)
            }
            
            // Bright flash spots
            ForEach(0..<6, id: \.self) { i in
                Ellipse()
                    .fill(.white.opacity(0.9))
                    .frame(width: CGFloat(4 + i % 3), height: CGFloat(2 + i % 2))
                    .rotationEffect(.degrees(Double(i) * 60))
                    .offset(
                        x: sin(Double(i) * 1.2) * 20,
                        y: cos(Double(i) * 1.8) * 12
                    )
            }
        }
        .blendMode(.screen)
    }
    
    @ViewBuilder
    private var holographicTexture: some View {
        ZStack {
            holographicInterferencePatterns
            holographicDiffractionLines
            holographicSpectralHotSpots
        }
        .blendMode(.screen)
    }
    
    @ViewBuilder
    private var holographicInterferencePatterns: some View {
        ForEach(0..<15, id: \.self) { i in
            holographicEllipse(for: i)
        }
    }
    
    private func holographicEllipse(for index: Int) -> some View {
        Ellipse()
            .stroke(holographicAngularGradient(for: index), lineWidth: 0.8)
            .frame(width: CGFloat(4.0 + Double(index) * 1.5), height: CGFloat(3.0 + Double(index) * 0.8))
            .opacity(0.4)
            .rotationEffect(.degrees(Double(index) * 15))
    }
    
    @ViewBuilder
    private var holographicDiffractionLines: some View {
        ForEach(0..<20, id: \.self) { i in
            Rectangle()
                .fill(holographicLinearGradient(for: i))
                .frame(width: 1, height: 40)
                .offset(x: CGFloat(i - 10) * 2)
                .rotationEffect(.degrees(Double(i) * 9))
        }
    }
    
    @ViewBuilder
    private var holographicSpectralHotSpots: some View {
        ForEach(0..<8, id: \.self) { i in
            Circle()
                .fill(holographicRadialGradient(for: i))
                .frame(width: CGFloat(3 + i % 4), height: CGFloat(3 + i % 4))
                .offset(
                    x: sin(Double(i) * 2.4) * 16,
                    y: cos(Double(i) * 1.9) * 14
                )
        }
    }
    
    private func holographicAngularGradient(for index: Int) -> AngularGradient {
        AngularGradient(
            colors: [.red, .orange, .yellow, .green, .cyan, .blue, .purple, .pink, .red],
            center: .center,
            startAngle: .degrees(Double(index) * 24),
            endAngle: .degrees(Double(index) * 24 + 360)
        )
    }
    
    private func holographicLinearGradient(for index: Int) -> LinearGradient {
        LinearGradient(
            colors: [
                Color.rainbow(at: Double(index) / 20.0).opacity(0.3),
                .clear,
                Color.rainbow(at: Double(index + 5) / 20.0).opacity(0.2)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private func holographicRadialGradient(for index: Int) -> RadialGradient {
        RadialGradient(
            colors: [
                Color.rainbow(at: Double(index) / 8.0).opacity(0.6),
                Color.rainbow(at: Double(index + 2) / 8.0).opacity(0.2),
                .clear
            ],
            center: .center,
            startRadius: 0,
            endRadius: 4
        )
    }
    
    @ViewBuilder
    private var iridescentTexture: some View {
        ZStack {
            ForEach(0..<8, id: \.self) { i in
                Capsule()
                    .fill(LinearGradient(
                        colors: [
                            Color.rainbow(at: Double(i) / 8.0).opacity(0.6),
                            Color.rainbow(at: Double(i + 3) / 8.0).opacity(0.3),
                            .clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: CGFloat(12 + i % 4), height: 2)
                    .rotationEffect(.degrees(Double(i) * 45))
                    .offset(
                        x: sin(Double(i) * 1.8) * 8,
                        y: cos(Double(i) * 2.3) * 6
                    )
            }
        }
        .blendMode(.screen)
    }
}

// MARK: - Triangle Shape for Gemstone Effects
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Convenience Extension for Easy Usage
extension View {
    func materialStyle(accentColor: Color) -> some View {
        MaterialView(accentColor: accentColor) {
            self
        }
    }
}