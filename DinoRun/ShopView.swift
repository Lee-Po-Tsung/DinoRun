//
//  ShopView.swift
//  DinoRun
//
//  Created by test on 2026/5/17.
//

import SwiftUI

struct ShopView: View {
    @Binding var currentGameState: GameState
    @State private var coins: Int = 150
    
    @Environment(GameData.self) var gameData

    // 固定的網格排版 (兩列)
    let columns = Array(repeating: GridItem(.flexible(), spacing: 40), count: 3)
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 0) {
                ZStack {
                    Image("shopRoof")
                        .resizable()
                        .scaledToFit()
                        .overlay(
                            HeaderView("SHOP", currentGameState: $currentGameState)
                                .padding(.horizontal, 40)
                                .offset(y: -15)
                        )
                        .zIndex(1)
                    
                }
                // --- 下方主內容區 (左右分欄) ---
                HStack(spacing: 0) {
                    // 【左欄：商品列表】
                    VStack {
                        Text("ITEMS")
                            .font(.system(size: 36, weight: .bold, design: .monospaced))
                            .padding(.top, 20)
                        
                        LazyVGrid(columns: columns, spacing: 40) {
                            ForEach(0..<6, id: \.self) { i in
                                if i >= gameData.shopItems.count {
                                    EmptyShopCard()
                                }
                                else {
                                    ShopCard(item: gameData.shopItems[i])
                                }
                            }
                        }
                        .padding(.horizontal, 60)
                        .padding(.vertical, 20)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color(white: 0.85))
                    .border(Color(white: 0.15), width: 8)
                    
                    // 中間的分隔黑線
                    Rectangle().fill(Color(white: 0.15)).frame(width: 20)
                    
                    // 【右欄：升級區】
                    VStack {
                        Text("Upgrade")
                            .font(.system(size: 40, weight: .bold, design: .monospaced))
                            .padding(.top, 20)
                        
                        Spacer()

                        Image("dinoLeft")
                            .resizable()
                            .interpolation(.none)
                            .scaledToFit()
                            .frame(height: 320)
                            .foregroundColor(Color(white: 0.6))
                        
                        HStack {
                            Text("3 ❤️")
                            Image(systemName: "arrow.right")
                            Text("4 ❤️")
                        }
                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                        .padding(.vertical, 20)
                        
                        // 升級購買按鈕
                        Button(action: { /* 升級邏輯 */ }) {
                            HStack {
                                Text("🪙 x100")
                                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                                    .foregroundColor(.yellow)
                                    .shadow(color: .black, radius: 1, x: 1, y: 1)
                            }
                            .frame(width: 200, height: 60)
                            .background(Color(white: 0.3))
                            .cornerRadius(5)
                        }
                        .padding(.bottom, 30)
                    }
                    .frame(width: 400) // 固定右欄寬度
                    .background(Color(white: 0.85))
                    .border(Color(white: 0.15), width: 8)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 20)
            }
        }
    }
}

// 商店商品卡片元件
struct ShopCard: View {
    let item: ShopItem
    
    var body: some View {
        VStack(spacing: 10) {
            Text("\(item.name) Lv.\(item.lv + 1)")
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .padding(.top, 10)
            
            Image(item.imgName)
                .resizable()
                .scaledToFit()
                .frame(height: 170)
                .foregroundColor(.black)
            
            coinV(num: item.prices[item.lv], 16)
            .frame(maxWidth: .infinity)
            .frame(height: 30)
            .background(Color(white: 0.3))
        }
        .background(Color.white)
        .border(Color(white: 0.8), width: 2) // 淺灰色內框
    }
}

// 空白的佔位卡片
struct EmptyShopCard: View {
    var body: some View {
        VStack {
            Spacer()
            coinV(num: 0, 16)
            .frame(maxWidth: .infinity)
            .frame(height: 30)
            .background(Color(white: 0.3))
        }
        .frame(height: 250)
        .background(Color(white: 1))
        .border(Color(white: 0.8), width: 2)
    }
}

#Preview(traits: .landscapeLeft) {
    ShopView(currentGameState: .constant(.shop))
        .environment(GameData())
}
