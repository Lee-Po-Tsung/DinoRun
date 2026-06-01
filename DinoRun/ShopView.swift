//
//  ShopView.swift
//  DinoRun
//
//  Created by test on 2026/5/17.
//

import SwiftUI

struct ShopView: View {
    @Binding var currentGameState: GameState
    @Environment(GameData.self) var gameData
    
    @State private var selectedIndex: Int = 0

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
                                } else {
                                    ShopCard(item: gameData.shopItems[i], isSelected: selectedIndex == i)
                                        .onTapGesture {
                                            selectedIndex = i
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
                    
                    if selectedIndex < gameData.shopItems.count {
                        let selectedItem = gameData.shopItems[selectedIndex]
                        
                        VStack {
                            Text(selectedItem.name)
                                .font(.system(size: 40, weight: .bold, design: .monospaced))
                                .padding(.top, 20)
                            
                            Image(selectedItem.imgName)
                                .resizable()
                                .interpolation(.none)
                                .scaledToFit()
                                .frame(height: 180)
                                .padding(.vertical, 10)
                            
                            Text(selectedItem.description)
                                .font(.system(size: 24, design: .monospaced))
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 30)
                                .frame(height: 120, alignment: .topLeading)
                            
                            VStack(alignment: .leading, spacing: 5) {
                                ForEach(selectedItem.stats, id: \.self) { stat in
                                    Text(stat)
                                        .font(.system(size: 20, weight: .bold, design: .monospaced))
                                        .foregroundColor(Color(white: 0.3))
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(30)
                            .frame(height: 60, alignment: .topLeading)
                            
                            Spacer()
                            
                            let isMaxLv = selectedItem.lv >= selectedItem.maxLv
                            let priceIndex = min(selectedItem.lv, selectedItem.prices.count - 1)
                            let cost = selectedItem.prices[priceIndex]
                            
                            Button(action: {
                                gameData.buyOrUpgradeItem(at: selectedIndex)
                                gameData.save()
                            }) {
                                if isMaxLv {
                                    Text("MAX")
                                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                                        .foregroundColor(.white)
                                        .frame(width: 220, height: 60)
                                        .background(Color(white: 0.3))
                                        .cornerRadius(5)
                                } else {
                                    coinV(num: cost, 28)
                                        .frame(width: 220, height: 60)
                                        .background(gameData.coins >= cost ? Color.blue : Color(white: 0.4))
                                        .cornerRadius(5)
                                }
                            }
                            .disabled(isMaxLv || gameData.coins < cost)
                            .padding(.bottom, 30)
                        }
                        .frame(width: 400)
                        .background(Color(white: 0.85))
                        .border(Color(white: 0.15), width: 8)
                    } else {
                        VStack {
                            Spacer()
                        }
                        .frame(width: 400)
                        .background(Color(white: 0.85))
                        .border(Color(white: 0.15), width: 8)
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 20)
            }
        }
    }
}

struct ShopCard: View {
    let item: ShopItem
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            Text("\(item.name) Lv.\(item.lv)")
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .padding(.top, 15)
            
            Spacer()
            
            Image(item.imgName)
                .resizable()
                .scaledToFit()
                .frame(height: 110)
            
            Spacer()
            
            let priceIndex = min(item.lv, item.prices.count - 1)
            coinV(num: item.lv >= item.maxLv ? 0 : item.prices[priceIndex], 16)
                .frame(maxWidth: .infinity)
                .frame(height: 35)
                .background(Color(white: 0.3))
        }
        .frame(height: 220)
        .background(Color.white)
        .border(isSelected ? Color.blue : Color(white: 0.8), width: isSelected ? 5 : 2)
    }
}

struct EmptyShopCard: View {
    var body: some View {
        VStack {
            Spacer()
            coinV(num: 0, 16)
                .frame(maxWidth: .infinity)
                .frame(height: 35)
                .background(Color(white: 0.3))
        }
        .frame(height: 220)
        .background(Color(white: 1))
        .border(Color(white: 0.8), width: 2)
    }
}

#Preview(traits: .landscapeLeft) {
    ShopView(currentGameState: .constant(.shop))
        .environment(GameData())
}
