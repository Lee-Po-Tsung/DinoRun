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
    
    var body: some View {
        ZStack {
            // 1. 最外層的白色背景 (模擬 iPad 邊框)
            Color.white.ignoresSafeArea()
            
            // 2. 深灰色主容器
            VStack(spacing: 30) {
                
                // --- 標題區 ---
                Text("GAME OVER")
                    // 註：未來在 Xcode 需匯入像素字體，這裡先用系統等寬粗體模擬
                    .font(.system(size: 60, weight: .black, design: .monospaced))
                    .foregroundColor(.black)
                    .padding(.top, 40)
                
                // 標題下方的黑色底線
                Rectangle()
                    .fill(Color.black)
                    .frame(height: 4)
                    .padding(.horizontal, 60)
                
                // --- 內容區 (左右分欄) ---
                HStack(spacing: 40) {
                    
                    // 左側：淺灰色分數資訊卡
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Score: \(currentScore)km")
                            .font(.system(size: 28, weight: .bold, design: .monospaced))
                            .foregroundColor(.black)
                            .padding()
                        
                        Divider().background(Color.black)
                        
                        HStack {
                            // 這裡未來替換成你的金幣圖片 Image("coin_icon")
                            Text("🪙")
                                .font(.system(size: 28))
                            Text("x\(coinsEarned)")
                                .font(.system(size: 28, weight: .bold, design: .monospaced))
                                .foregroundColor(.yellow)
                                // 加上黑色描邊模擬你的黃字黑邊效果
                                .shadow(color: .black, radius: 1, x: 1, y: 1)
                        }
                        .padding()
                        
                        Divider().background(Color.black)
                        
                        Text("High Score: \(highScore)km")
                            .font(.system(size: 28, weight: .bold, design: .monospaced))
                            .foregroundColor(.black)
                            .padding()
                    }
                    .frame(width: 350)
                    .background(Color(white: 0.85)) // 淺灰色
                    .cornerRadius(10)
                    
                    // 右側：死掉的小恐龍與按鈕
                    VStack(spacing: 30) {
                        // 這裡未來替換成你的恐龍圖片 Image("dino_dead")
                        Image(systemName: "tortoise.fill") // 暫時用烏龜佔位
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                            .foregroundColor(Color(white: 0.6)) // 灰階色
                        
                        HStack(spacing: 15) {
                            // Home 按鈕
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
                            
                            // AGAIN 按鈕
                            Button(action: {
                                // 重新開始遊戲邏輯
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
            .background(Color(white: 0.35)) // 深灰色背景
            .cornerRadius(20)
            .padding(40) // 讓深灰色容器跟螢幕邊緣保持距離
        }
    }
}

#Preview(traits: .landscapeLeft) {
    GameOverView(currentGameState: .constant(.playing))
}
