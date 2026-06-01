//
//  HomePageView.swift
//  DinoRun
//
//  Created by test on 2026/5/17.
//

import SwiftUI

struct HomePageView: View {
    @Environment(GameData.self) var gameData
    @Binding var currentGameState: GameState

    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack {
                HStack(alignment: .bottom) {
                    Image("dinoLeft")
                        .resizable()
                        .interpolation(.none)
                        .scaledToFit()
                        .frame(height: 500)
                        .opacity(0.8)
                    Spacer()
                    
                    Image("dinoRight")
                        .resizable()
                        .interpolation(.none)
                        .scaledToFit()
                        .frame(height: 400)
                        .opacity(0.8)
                        .rotationEffect(.degrees(230))
                    
                    Image("cactus3")
                        .resizable()
                        .interpolation(.none)
                        .scaledToFit()
                        .frame(height: 400)
                        .opacity(0.8)
                }
                .padding(.top, 170)
                .zIndex(1)
                Image("ground")
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .opacity(0.8)
                    .offset(y: -50)
            }
            
            VStack {
                HStack {
                    Spacer()
                    coinV(num: gameData.coins, 50)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.gray.opacity(0.5))
                    .cornerRadius(8)
                    .padding()
                }
                Spacer()
            }
            .padding(40)
            
            VStack(spacing: 30) {
                Text("Dino Run")
                    .font(.system(size: 80, weight: .heavy, design: .monospaced))
                    .foregroundColor(.black)

                Text("High Score: \(gameData.highScore)m")
                    .font(.system(size: 32, weight: .bold, design: .monospaced))
                    .foregroundColor(.black)
                    .padding(.bottom, 40)

                MenuButton(title: "START!", width: 320, height: 80) {
                    currentGameState = .playing
                    gameData.playingState = .playing
                }

                HStack(spacing: 24) {
                    MenuButton(title: "SHOP", width: 148, height: 70) {
                        currentGameState = .shop
                    }
                    
                    MenuButton(title: "ITEM", width: 148, height: 70) {
                        currentGameState = .equipment
                    }
                }

                MenuButton(title: "SETTINGS", width: 320, height: 70) {
                    currentGameState = .settings
                }
            }
        }
    }
}

struct MenuButton: View {
    var title: String
    var width: CGFloat
    var height: CGFloat
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 32, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
                .frame(width: width, height: height)
                .background(Color(white: 0.3))
                .cornerRadius(12)
                .shadow(radius: 5, y: 5)
        }
    }
}

#Preview(traits: .landscapeLeft) {
    HomePageView(currentGameState: .constant(.home))
        .environment(GameData())
}
