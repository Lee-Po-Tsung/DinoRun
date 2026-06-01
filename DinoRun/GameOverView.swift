//
//  GameOverView.swift
//  DinoRun
//
//  Created by test on 2026/5/17.
//

import SwiftUI

struct GameOverView: View {
    @Binding var currentGameState: GameState
    var currentScore: Int = 150
    var coinsEarned: Int = 25
    var highScore: Int = 300
    var onAgain: () -> Void
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 30) {
                Text("GAME OVER")
                    .font(.system(size: 60, weight: .black, design: .monospaced))
                    .foregroundColor(.black)
                    .padding(.top, 40)
                
                Rectangle()
                    .fill(Color.black)
                    .frame(height: 4)
                    .padding(.horizontal, 60)
                
                HStack(spacing: 40) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Score: \(currentScore)km")
                            .font(.system(size: 28, weight: .bold, design: .monospaced))
                            .foregroundColor(.black)
                            .padding()
                        
                        Divider().background(Color.black)
                        
                        coinV(num: coinsEarned, 28)
                            .padding()
                        
                        Divider().background(Color.black)
                        
                        Text("High Score: \(highScore)km")
                            .font(.system(size: 28, weight: .bold, design: .monospaced))
                            .foregroundColor(.black)
                            .padding()
                    }
                    .frame(width: 350)
                    .background(Color(white: 0.85))
                    .cornerRadius(10)
                    
                    VStack(spacing: 30) {
                        Image("dinoDead")
                            .resizable()
                            .interpolation(.none)
                            .scaledToFit()
                            .frame(height: 150)
                            .foregroundColor(Color(white: 0.6))
                        
                        HStack(spacing: 15) {
                            Button(action: {
                                currentGameState = .home
                            }) {
                                Image(systemName: "house.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(.white)
                                    .frame(width: 80, height: 70)
                                    .background(Color(white: 0.15))
                                    .cornerRadius(8)
                            }
                            
                            Button(action: {
                                onAgain()
                            }) {
                                Text("AGAIN")
                                    .font(.system(size: 30, weight: .bold, design: .monospaced))
                                    .foregroundColor(.white)
                                    .frame(width: 200, height: 70)
                                    .background(Color(white: 0.15))
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
                .padding(.horizontal, 60)
                .padding(.bottom, 50)
            }
            .background(Color(white: 0.35))
            .cornerRadius(20)
            .padding(40)
        }
    }
}

#Preview(traits: .landscapeLeft) {
    GameOverView(currentGameState: .constant(.playing), onAgain: {})
}
