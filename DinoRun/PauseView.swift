//
//  PauseView.swift
//  DinoRun
//
//  Created by test on 2026/5/17.
//

import SwiftUI

struct PauseView: View {
    @Binding var currentGameState: GameState
    @Environment(GameData.self) var gameData
    var onRestart: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.6).ignoresSafeArea()
            
            VStack(spacing: 40) {
                Text("PAUSED")
                    .font(.system(size: 60, weight: .heavy, design: .monospaced))
                    .foregroundColor(.white)
                    .shadow(radius: 5)
                
                HStack(spacing: 30) {
                    IconButton(iconName: "house.fill") {
                        gameData.playingState = .nothing
                        currentGameState = .home
                        gameData.save()
                    }
                    
                    IconButton(iconName: "arrow.clockwise") {
                        onRestart()
                    }
                    
                    IconButton(iconName: "play.fill") {
                        gameData.playingState = .starting
                    }
                }
            }
            .padding(40)
            .background(Color(white: 0.2))
            .cornerRadius(20)
            .shadow(radius: 10)
        }
    }
}

struct IconButton: View {
    var iconName: String
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: iconName)
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(.black)
                .frame(width: 80, height: 80)
                .background(Color.white)
                .clipShape(Circle())
                .shadow(radius: 5, y: 5)
        }
    }
}

//#Preview(traits: .landscapeLeft) {
//    PauseView(currentGameState: .constant(.playing), isPaused: .constant(true))
//}
