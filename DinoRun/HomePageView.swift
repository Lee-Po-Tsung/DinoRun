//
//  HomePageView.swift
//  DinoRun
//
//  Created by test on 2026/5/17.
//

import SwiftUI

struct HomePageView: View {
    @Environment(GameData.self) var gameData
    // 綁定狀態，按下按鈕時可以切換畫面
    @Binding var currentGameState: GameState
    
    // 暫時寫死的假資料，未來可替換成 UserDefaults 讀取的真實資料
    @State private var highScore: Int = 0
    @State private var coins: Int = 0
    
    var body: some View {
        ZStack {
            // 1. 最底層背景色
            Color.white.ignoresSafeArea()
            
            // (選做) 這裡未來可以放一張半透明的恐龍背景圖當裝飾
            /*
             Image("home_background")
                 .resizable()
                 .scaledToFit()
                 .opacity(0.3)
            */
            
            // 2. 右上角的金幣顯示
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
            
            // 3. 中央主要的 UI 佈局
            VStack(spacing: 30) {
                // 遊戲標題
                Text("Dino Run")
                    .font(.system(size: 80, weight: .heavy, design: .monospaced))
                    .foregroundColor(.black)
                
                // 最高分數
                Text("High Score: \(highScore)km")
                    .font(.system(size: 32, weight: .bold, design: .monospaced))
                    .foregroundColor(.black)
                    .padding(.bottom, 40)
                
                // START 按鈕 (主按鈕)
                MenuButton(title: "START!", width: 320, height: 80) {
                    currentGameState = .playing
                }
                
                // SHOP 與 ITEM 按鈕 (次要按鈕，並排)
                HStack(spacing: 24) {
                    MenuButton(title: "SHOP", width: 148, height: 70) {
                        currentGameState = .shop
                    }
                    
                    MenuButton(title: "ITEM", width: 148, height: 70) {
                        currentGameState = .equipment
                    }
                }
                
                // SETTINGS 按鈕
                MenuButton(title: "SETTINGS", width: 320, height: 70) {
                    currentGameState = .settings
                }
            }
        }
    }
}

// 建立一個可重複使用的按鈕元件，讓程式碼保持乾淨
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
                .background(Color(white: 0.3)) // 對應你 Figma 上的深灰色
                .cornerRadius(12)
                .shadow(radius: 5, y: 5) // 加一點陰影看起來更立體
        }
    }
}

// Preview 方便在 Xcode 裡面即時預覽 (橫向)
#Preview(traits: .landscapeLeft) {
    HomePageView(currentGameState: .constant(.home))
        .environment(GameData())
}
