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
                HStack(spacing: 0) {
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
                                        .onTapGesture {
                                            gameData.buyOrUpgradeItem(at: i)
                                        }
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
                    
                    Rectangle().fill(Color(white: 0.15)).frame(width: 20)
                    
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
                            Text("\(gameData.maxHP) ❤️")
                            Image(systemName: "arrow.right")
                            Text("\(gameData.maxHP + 1) ❤️")
                        }
                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                        .padding(.vertical, 20)
                        
                        Button(action: {
                            gameData.upgradeMaxHP()
                        }) {
                            coinV(num: 100, 30)
                            .frame(width: 200, height: 60)
                            .background(Color(white: 0.3))
                            .cornerRadius(5)
                        }
                        .disabled(gameData.coins < 100)
                        .padding(.bottom, 30)
                    }
                    .frame(width: 400)
                    .background(Color(white: 0.85))
                    .border(Color(white: 0.15), width: 8)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 20)
            }
        }
    }
}

struct ShopCard: View {
    let item: ShopItem
    
    var body: some View {
        VStack(spacing: 10) {
            Text("\(item.name) Lv.\(item.lv)")
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .padding(.top, 10)
            
            Image(item.imgName)
                .resizable()
                .scaledToFit()
                .frame(height: 170)
                .foregroundColor(.black)
            
            let priceIndex = min(item.lv, item.prices.count - 1)
            coinV(num: item.lv >= item.maxLv ? 0 : item.prices[priceIndex], 16)
                .frame(maxWidth: .infinity)
                .frame(height: 30)
                .background(Color(white: 0.3))
        }
        .background(Color.white)
        .border(Color(white: 0.8), width: 2)
    }
}

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
