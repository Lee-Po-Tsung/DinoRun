//
//  GameView.swift
//  DinoRun
//
//  Created by test on 2026/5/16.
//

import SwiftUI
import SpriteKit

struct GameView: View {
    @Binding var currentGameState: GameState
    @Environment(GameData.self) var gameData

    @State private var coinsEarned = 0
    @State private var sceneID = UUID()
    
    var scene: SKScene {
        let scene = GameScene(size: CGSize(width: 1024, height: 768))
        scene.scaleMode = .aspectFit
        scene.gameData = gameData
        return scene
    }
    
    func isGameOver() -> Bool {
        return gameData.playingState == .gameover
    }
    
    func isPaused() -> Bool {
        return gameData.playingState == .paused
    }

    var body: some View {
        ZStack {
            SpriteView(scene: scene, isPaused: isPaused() || isGameOver())
                .ignoresSafeArea()
                .id(sceneID)
            
            VStack {
                HStack(alignment: .center) {
                    HStack(spacing: 15) {
                        Button(action: {
                            gameData.playingState = .paused
                        }) {
                            Image(systemName: "pause.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                                .padding(12)
                                .background(Color(white: 0.3))
                                .cornerRadius(8)
                        }
                        
                        HStack(spacing: 6) {
                            ForEach(0..<gameData.maxHP, id: \.self) { i in
                                Text(i < gameData.currentHP ? "❤️" : "🖤")
                                    .font(.system(size: 24))
                            }
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(Color(white: 0.85))
                        .cornerRadius(8)
                    }
                    
                    Spacer()
                    
                    MyText("\(gameData.currentScore) m", size: 40)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 20)
                        .background(Color(white: 0.85))
                        .cornerRadius(8)
                }
                .padding(.top, 20)
                .padding(.horizontal, 20)
                
                Spacer()
            }
            
            if isPaused() {
                PauseView(currentGameState: $currentGameState) {
                    resetGame()
                }.environment(gameData)
            }
            
            if isGameOver() {
                GameOverView(
                    currentGameState: $currentGameState,
                    currentScore: gameData.currentScore,
                    coinsEarned: coinsEarned,
                    highScore: gameData.highScore
                ) {
                    gameData.save()
                    restartGame()
                }
            }
        }
        .onChange(of: gameData.currentHP) { _, newValue in
            if newValue <= 0 && !isGameOver() {
                if gameData.currentScore > gameData.highScore {
                    gameData.highScore = gameData.currentScore
                }
                gameData.playingState = .gameover
            }
        }
        .onChange(of: gameData.coins) { old, new in
            coinsEarned += new - old
        }
        .onAppear {
            gameData.currentScore = 0
            gameData.currentHP = gameData.maxHP
        }
    }
    
    private func resetGame() {
        gameData.coins -= coinsEarned
        restartGame()
    }
    
    private func restartGame() {
        coinsEarned = 0
        gameData.currentScore = 0
        gameData.currentHP = gameData.maxHP
        gameData.playingState = .playing
        sceneID = UUID()
    }
}

struct MyText: View {
    let text: String
    let size: CGFloat
    
    init(_ text: String, size: CGFloat) {
        self.text = text
        self.size = size
    }
    
    var body: some View {
        Text(text).font(.custom("Jersey25-Regular", size: size))
    }
}

struct ContentView: View {
    @State private var currentGameState: GameState = .home
    @State private var gameData = GameData()
    
    var body: some View {
        ZStack {
            switch currentGameState {
            case .home:
                HomePageView(currentGameState: $currentGameState)
            case .playing:
                GameView(currentGameState: $currentGameState)
            case .shop:
                ShopView(currentGameState: $currentGameState)
            case .equipment:
                EquipmentView(currentGameState: $currentGameState)
            case .settings:
                SettingsView(currentGameState: $currentGameState)
            }
        }
        .animation(.easeInOut, value: currentGameState)
        .environment(gameData)
        .onAppear {
            gameData.startBGM()
        }
    }
}

#Preview(traits: .landscapeLeft)  {
    ContentView()
//    GameView(currentGameState: .constant(.playing))
//        .environment(GameData())
}
