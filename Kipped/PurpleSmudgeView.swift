import SwiftUI

// MARK: - PurpleSmudgeView
struct PurpleSmudgeView: View {
    let accentColor: Color
    @State private var smudgeParticles: [SmudgeParticle] = []
    @State private var dragPosition: CGPoint?
    @State private var lastDragPosition: CGPoint?
    @State private var isDragging = false
    
    private let fadeOutDuration: Double = 1.5
    private let maxParticles: Int = 30
    private let trailSpacing: CGFloat = 12.0
    
    var body: some View {
        ZStack {
            // Test background - should be visible
            Color.blue.opacity(0.1)
                .ignoresSafeArea()
            
            // Test particle - always visible
            Circle()
                .fill(Color.red)
                .frame(width: 40, height: 40)
                .position(x: 100, y: 100)
            
            // Render smudge particles
            ForEach(smudgeParticles) { particle in
                SmudgeParticleView(particle: particle, accentColor: accentColor)
                    .position(particle.position)
            }
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    print("Gesture detected at: \(value.location)")
                    handleDragChanged(value)
                }
                .onEnded { _ in
                    print("Gesture ended")
                    handleDragEnded()
                }
        )
        .onAppear {
            print("PurpleSmudgeView appeared")
            startCleanupTimer()
        }
    }
    
    private func handleDragChanged(_ value: DragGesture.Value) {
        let currentPosition = value.location
        
        if !isDragging {
            // Start of drag - create initial smudge
            isDragging = true
            createSmudgeParticle(at: currentPosition)
        } else {
            // Continue drag - create trail
            if let lastPos = lastDragPosition {
                let distance = sqrt(pow(currentPosition.x - lastPos.x, 2) + pow(currentPosition.y - lastPos.y, 2))
                if distance > trailSpacing {
                    createSmudgeParticle(at: currentPosition)
                }
            }
        }
        
        lastDragPosition = currentPosition
        dragPosition = currentPosition
    }
    
    private func handleDragEnded() {
        isDragging = false
        dragPosition = nil
        lastDragPosition = nil
    }
    
    private func createSmudgeParticle(at position: CGPoint) {
        let newParticle = SmudgeParticle(position: position)
        smudgeParticles.append(newParticle)
        
        // Debug print
        print("Created smudge particle at position: \(position)")
        
        // Limit number of particles
        if smudgeParticles.count > maxParticles {
            smudgeParticles.removeFirst()
        }
        
        // Animate fade out
        withAnimation(.easeOut(duration: fadeOutDuration)) {
            if let index = smudgeParticles.firstIndex(where: { $0.id == newParticle.id }) {
                smudgeParticles[index].opacity = 0.0
                smudgeParticles[index].scale = 1.5
            }
        }
    }
    
    private func startCleanupTimer() {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            cleanupOldParticles()
        }
    }
    
    private func cleanupOldParticles() {
        let now = Date()
        smudgeParticles.removeAll { particle in
            now.timeIntervalSince(particle.creationTime) > fadeOutDuration + 0.5
        }
    }
}

// MARK: - SmudgeParticleView
struct SmudgeParticleView: View {
    let particle: SmudgeParticle
    let accentColor: Color
    
    var body: some View {
        // Simple solid circle for testing
        Circle()
            .fill(accentColor)
            .frame(width: 50, height: 50)
            .opacity(particle.opacity)
            .scaleEffect(particle.scale)
            .allowsHitTesting(false)
    }
}

// MARK: - Preview
struct PurpleSmudgeView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            PurpleSmudgeView(accentColor: .purple)
        }
    }
}