import SwiftUI

struct SmudgeParticle: Identifiable {
    let id = UUID()
    let position: CGPoint
    let creationTime: Date
    var opacity: Double = 1.0
    var scale: Double = 1.0
    
    init(position: CGPoint) {
        self.position = position
        self.creationTime = Date()
    }
}

struct SmudgeEffectView: View {
    @Binding var particles: [SmudgeParticle]
    let accentColor: Color
    let colorScheme: ColorScheme?
    
    var body: some View {
        ForEach(particles) { particle in
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            accentColor.opacity(colorScheme == .dark ? 0.18 : 0.12),
                            accentColor.opacity(colorScheme == .dark ? 0.14 : 0.09),
                            accentColor.opacity(colorScheme == .dark ? 0.10 : 0.06),
                            accentColor.opacity(colorScheme == .dark ? 0.06 : 0.04),
                            accentColor.opacity(colorScheme == .dark ? 0.04 : 0.025),
                            accentColor.opacity(colorScheme == .dark ? 0.025 : 0.015),
                            accentColor.opacity(colorScheme == .dark ? 0.015 : 0.008),
                            accentColor.opacity(colorScheme == .dark ? 0.008 : 0.004),
                            Color.clear
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 90
                    )
                )
                .frame(width: 160, height: 160)
                .position(particle.position)
                .opacity(particle.opacity)
                .blendMode(colorScheme == .dark ? .screen : .multiply)
                .zIndex(999)
        }
    }
}

// MARK: - Smudge Effect Helper Functions
extension View {
    func smudgeEffect(
        particles: Binding<[SmudgeParticle]>,
        accentColor: Color,
        colorScheme: ColorScheme?
    ) -> some View {
        self.overlay(
            SmudgeEffectView(
                particles: particles,
                accentColor: accentColor,
                colorScheme: colorScheme
            )
        )
    }
}

class SmudgeEffectManager: ObservableObject {
    @Published var particles: [SmudgeParticle] = []
    
    func createParticle(at position: CGPoint) {
        let newParticle = SmudgeParticle(position: position)
        particles.append(newParticle)
        
        if particles.count > 35 {
            particles.removeFirst()
        }
        
        let particleIndex = particles.count - 1
        let fadeStartDelay = 0.05 + (Double(particleIndex) * 0.008)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + fadeStartDelay) {
            withAnimation(.easeOut(duration: 0.25)) {
                if let index = self.particles.firstIndex(where: { $0.id == newParticle.id }) {
                    self.particles[index].opacity = 0.0
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.particles.removeAll { $0.id == newParticle.id }
            }
        }
    }
    
    func clearParticles() {
        particles.removeAll()
    }
}