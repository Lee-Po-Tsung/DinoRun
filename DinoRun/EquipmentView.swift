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
    
    var equipmentItems: [ShopItem] {
        gameData.shopItems.filter { $0.category == .equipment }
    }
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 0) {
                HeaderView("ITEM", currentGameState: $currentGameState, coin: false)
                    .padding(.horizontal, 40)
                    .padding(.top, 20)
                    .padding(.bottom, 20)
                
                HStack(spacing: 0) {
                    VStack {
                        Text("ITEMS")
                            .font(.system(size: 36, weight: .bold, design: .monospaced))
                            .padding(.top, 20)
                        
                        LazyVGrid(columns: columns, spacing: 40) {
                            ForEach(0..<6, id: \.self) { i in
                                if i >= equipmentItems.count {
                                    EmptyItemCard()
                                } else {
                                    ItemCard(
                                        item: equipmentItems[i],
                                        equipped: gameData.equippedItem,
                                        selected: i == selectedItem
                                    )
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
                    .border(Color(white: 0.15), width: 8)
                    
                    Rectangle().fill(Color(white: 0.15)).frame(width: 20)
                    
                    if selectedItem < equipmentItems.count {
                        let itemDetails = equipmentItems[selectedItem]
                        
                        VStack {
                            Text("\(itemDetails.name) Lv.\(itemDetails.lv)")
                                .font(.system(size: 40, weight: .bold, design: .monospaced))
                                .padding(.top, 20)
                            
                            Image(itemDetails.imgName)
                                .resizable()
                                .interpolation(.none)
                                .scaledToFit()
                                .frame(height: 180)
                                .padding(.vertical, 10)
                            

                            Text(itemDetails.description)
                                .font(.system(size: 24, design: .monospaced))
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 30)
                                .frame(height: 120, alignment: .topLeading)
                            
                            VStack(alignment: .leading, spacing: 5) {
                                ForEach(itemDetails.stats, id: \.self) { stat in
                                    Text(stat)
                                        .font(.system(size: 20, weight: .bold, design: .monospaced))
                                        .foregroundColor(Color(white: 0.3))
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(30)
                            .frame(height: 60, alignment: .topLeading)
                            
                            Spacer()
                            
                            if itemDetails.lv == 0 {
                                Text("LOCKED")
                                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                                    .frame(width: 220, height: 60)
                                    .background(Color.gray)
                                    .foregroundColor(.white)
                                    .cornerRadius(5)
                            } else {
                                let isEquipped = gameData.equippedItem == itemDetails.name
                                Button(action: {
                                    if gameData.equippedItem == itemDetails.name {
                                        gameData.equippedItem = "None"
                                    } else {
                                        gameData.equippedItem = itemDetails.name
                                    }
                                    gameData.save()
                                }) {
                                    Text(isEquipped ? "UNEQUIP" : "EQUIP")
                                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                                        .frame(width: 220, height: 60)
                                        .background(isEquipped ? Color.black : Color.green)
                                        .foregroundColor(.white)
                                        .cornerRadius(5)
                                }
                            }
                            Spacer().frame(height: 30)
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
        VStack(spacing: 0) {
            Text("\(item.name) Lv.\(item.lv)")
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .padding(.top, 15)
            
            Spacer()
            
            Image(item.imgName)
                .resizable()
                .scaledToFit()
                .frame(height: 110)
                .padding(.bottom, 5)
            
            Spacer()

            Text(status)
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 35)
                .background(status == "Equipped" ? Color(white: 0.3) : Color(white: 0.5))
        }
        .frame(height: 220)
        .background(Color.white)
        .border(selected ? Color.green : Color(white: 0.8), width: selected ? 5 : 2)
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
                .frame(height: 35)
                .background(Color(white: 0.7))
        }
        .frame(height: 220)
        .background(Color(white: 0.9))
        .border(Color(white: 0.8), width: 2)
    }
}

#Preview(traits: .landscapeLeft) {
    EquipmentView(currentGameState: .constant(.equipment))
        .environment(GameData())
}
