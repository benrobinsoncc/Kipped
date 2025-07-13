//
//  ToastView.swift
//  Kipped
//
//  Created by Ben Robinson on 28/06/2025.
//

import SwiftUI

struct ToastView: View {
    @Binding var isShowing: Bool
    let message: String
    let icon: String
    let accentColor: Color
    let tintedBackgrounds: Bool
    
    @State private var offset: CGFloat = -100
    @State private var opacity: Double = 0
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(accentColor)
            
            Text(message)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(accentColor)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(
            ZStack {
                if tintedBackgrounds {
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .overlay(
                            Capsule()
                                .fill(accentColor.opacity(0.1))
                        )
                } else {
                    Capsule()
                        .fill(.regularMaterial)
                }
            }
            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
        .offset(y: offset)
        .opacity(opacity)
        .animation(.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0), value: offset)
        .animation(.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0), value: opacity)
        .onAppear {
            showToast()
        }
    }
    
    private func showToast() {
        withAnimation {
            offset = 0
            opacity = 1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation {
                offset = -100
                opacity = 0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isShowing = false
            }
        }
    }
}