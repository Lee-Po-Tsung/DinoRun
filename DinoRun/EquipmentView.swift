//
//  EquipmentView.swift
//  DinoRun
//
//  Created by test on 2026/5/17.
//

import SwiftUI

struct EquipmentView: View {
    @Environment(GameData.self) var gameData
    @Binding var currentGameState: GameState
    @State private var selectedItem: Int = 0
    
    let columns = Array(repeating: GridItem(.flexible(), spacing: 40), count: 3)
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack {
                HeaderView("ITEM", currentGameState: $currentGameState)
                    .padding(.horizontal, 40)
                    .padding(.top, 20)
                
                HStack(spacing: 30) {
                    VStack {
                        Text("ITEMS")
                            .font(.system(size: 36, weight: .bold, design: .monospaced))
                            .padding(.top, 20)
                        
                        LazyVGrid(columns: columns, spacing: 40) {
                            ForEach(0..<6, id: \.self) { i in
                                if i >= gameData.shopItems.count {
                                    EmptyItemCard()
                                } else {
                                    ItemCard(item: gameData.shopItems[i], equipped: gameData.equippedItem, selected: i == selectedItem)
                                        .onTapGesture {
                                            selectedItem = i
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
                    .cornerRadius(10)
                    .shadow(radius: 3)
                    
                    VStack(spacing: 15) {
                        if selectedItem < gameData.shopItems.count {
                            let itemDetails = gameData.shopItems[selectedItem]
                            Text("\(itemDetails.name) Lv.\(itemDetails.lv)")
                                .font(.system(size: 32, weight: .bold, design: .monospaced))
                            
                            Image(itemDetails.imgName)
                                .resizable()
                                .interpolation(.none)
                                .scaledToFit()
                                .frame(height: 80)
                            
                            Text(itemDetails.description)
                                .font(.system(size: 14, design: .monospaced))
                                .padding()
                            
                            ForEach(itemDetails.stats, id: \.self) { stat in
                                Text(stat)
                                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                            }
                            
                            Spacer()
                            
                            if itemDetails.lv == 0 {
                                Text("LOCKED")
                                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                                    .frame(width: 200, height: 60)
                                    .background(Color.gray)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            } else {
                                Button(action: {
                                    if gameData.equippedItem == itemDetails.name {
                                        gameData.equippedItem = "None"
                                    } else {
                                        gameData.equippedItem = itemDetails.name
                                    }
                                }) {
                                    Text(gameData.equippedItem == itemDetails.name ? "UNEQUIP" : "EQUIP")
                                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                                        .frame(width: 200, height: 60)
                                        .background(Color.black)
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                    .padding(.top, 30)
                    .frame(width: 350)
                    .background(Color(white: 0.85))
                    .cornerRadius(10)
                    .shadow(radius: 3)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 30)
            }
        }
    }
}

struct ItemCard: View {
    let item: ShopItem
    let equipped: String
    let selected: Bool
    
    var status: String {
        if item.lv == 0 {
            return "Locked"
        }
        return item.name == equipped ? "Equipped" : "Unequipped"
    }
    
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
                .padding(.bottom, 5)

            Text(status)
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 25)
                .background(status == "Equipped" ? Color(white: 0.3) : Color(white: 0.5))
        }
        .background(Color.white)
        .border(selected ? Color.black : Color.clear, width: 3)
        .shadow(radius: 2)
    }
}

struct EmptyItemCard: View {
    var body: some View {
        VStack {
            Spacer()
            Text("Empty")
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 25)
                .background(Color(white: 0.7))
        }
        .frame(height: 250)
        .background(Color(white: 0.9))
        .shadow(radius: 1)
    }
}

#Preview(traits: .landscapeLeft) {
    EquipmentView(currentGameState: .constant(.equipment))
        .environment(GameData())
}
