//
//  GameView.swift
//  DinoRun
//
//  Created by test on 2026/5/16.
//

import SwiftUI
import SpriteKit

struct GameView: View {
    var scene: SKScene {
        let scene = GameScene(size: CGSize(width: 1024, height: 768))
        scene.scaleMode = .aspectFit
        return scene
    }

    var body: some View {
        SpriteView(scene: scene)
            .ignoresSafeArea()
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
                // 未來你會在這裡將 GameView 與 PauseView、GameOverView 結合
                GameView()
            case .shop:
                ShopView(currentGameState: $currentGameState) // 替換成真正的商店畫面
            case .equipment:
                EquipmentView(currentGameState: $currentGameState)
            case .settings:
                SettingsView(currentGameState: $currentGameState)
            }
        }
        .animation(.easeInOut, value: currentGameState)
        .environment(gameData)
    }
}

#Preview(traits: .landscapeLeft)  {
    ContentView()
}
