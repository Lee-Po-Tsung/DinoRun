//
//  GameData.swift
//  DinoRun
//
//  Created by test on 2026/5/19.
//

import SwiftUI
import Observation

struct ShopItem: Identifiable {
    let id = UUID()
    let name: String
    var lv: Int
    let imgName: String
    let prices: [Int]
    let description: String
    let stats: [String]
    let maxLv: Int
}

@Observable
class GameData {
    var coins: Int = 150
    var highScore: Int = 300
    var currentScore: Int = 0
    var currentHP: Int = 3
    var maxHP: Int = 3
    
    var equippedItem: String = "None"
    
    var shopItems: [ShopItem] = [
        ShopItem(
            name: "Laser",
            lv: 1,
            imgName: "laser",
            prices: [50, 100, 300, 500, 700],
            description: "Fires a devastating horizontal energy beam that instantly destroys all obstacles (Cacti and Pterodactyls) ahead of you for a specific distance.",
            stats: ["Clear Range: 100m", "Cooldown: 40 Jumps"],
            maxLv: 5
        ),
        ShopItem(
            name: "Shield",
            lv: 0,
            imgName: "shield",
            prices: [75, 150, 350, 600, 750],
            description: "Grants absolute invulnerability. While active, the Dino ignores all collision damage from ground and aerial obstacles.",
            stats: ["Duration: 3s", "Cooldown: 30 Jumps"],
            maxLv: 5
        )
    ]
    
    func buyOrUpgradeItem(at index: Int) {
        guard index < shopItems.count else { return }
        let item = shopItems[index]
        guard item.lv < item.maxLv else { return }
        
        let priceIndex = item.lv
        guard priceIndex < item.prices.count else { return }
        let cost = item.prices[priceIndex]
        
        if coins >= cost {
            coins -= cost
            shopItems[index].lv += 1
        }
    }
    func upgradeMaxHP() {
        if coins >= 100 {
            coins -= 100
            maxHP += 1
        }
    }
}
