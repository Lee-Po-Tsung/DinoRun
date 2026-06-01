//
//  GameData.swift
//  DinoRun
//
//  Created by test on 2026/5/19.
//

import SwiftUI
import Observation

enum ShopItemCategory: String, Codable {
    case equipment
    case passive
}

struct ShopItem: Identifiable {
    var id: String { name }
    let name: String
    var lv: Int
    let category: ShopItemCategory
    let imgName: String
    let prices: [Int]
    let description: String
    let statsBuilder: (Int) -> [String]
    
    var stats: [String] {
        statsBuilder(lv)
    }
    
    let maxLv: Int
}

struct GameSaveData: Codable {
    var coins: Int
    var highScore: Int
    var equippedItem: String
    var itemLevels: [String: Int]
}

@Observable
class GameData {
    var currentScore: Int = 0
    var currentHP: Int = 3
    var playingState: PlayingState = .nothing
    
    var coins: Int = 150
    var highScore: Int = 0
    var equippedItem: String = "None"
    
    var shopItems: [ShopItem] = [
        ShopItem(
            name: "Max HP",
            lv: 0,
            category: .passive,
            imgName: "heart",
            prices: [150, 300, 500],
            description: "Increases your maximum health, allowing the Dino to survive more collisions.",
            statsBuilder: { lv in
                return ["Max HP: \(3 + lv)"]
            },
            maxLv: 3
        ),
        ShopItem(
            name: "Laser",
            lv: 1,
            category: .equipment,
            imgName: "laser",
            prices: [50, 100, 300, 500, 700],
            description: "Fires a devastating horizontal energy beam that instantly destroys all obstacles ahead of you.",
            statsBuilder: { lv in
                let currentLv = max(1, lv)
                let cd = max(20, 45 - (currentLv * 5))
                let range = 80 + (currentLv * 70)
                return ["Clear Range: \(range)m", "Cooldown: \(cd) Jumps"]
            },
            maxLv: 5
        ),
        ShopItem(
            name: "Shield",
            lv: 0,
            category: .equipment,
            imgName: "shield",
            prices: [75, 150, 350, 600, 750],
            description: "Grants absolute invulnerability. While active, the Dino ignores all collision damage.",
            statsBuilder: { lv in
                let currentLv = max(1, lv)
                let duration = 2 + currentLv * currentLv
                let cd = max(15, 35 - (currentLv * 5))
                return ["Duration: \(duration)s", "Cooldown: \(cd) Jumps"]
            },
            maxLv: 5
        )
    ]
    
    var maxHP: Int {
        return 3 + getLevel(for: "Max HP")
    }
    
    let shoeDuration: TimeInterval = 10.0
    let splatDuration: TimeInterval = 5.0
    let stickMaxDistance: CGFloat = 6000.0
    
    var laserCDJumps: Int {
        let lv = getLevel(for: "Laser")
        return max(20, 45 - (max(1, lv) * 5))
    }
    
    var shieldDuration: TimeInterval {
        let lv = getLevel(for: "Shield")
        return Double(2 + max(1, lv) * 1)
    }
    
    var shieldCDJumps: Int {
        let lv = getLevel(for: "Shield")
        return max(15, 35 - (max(1, lv) * 5))
    }
    
    var laserMaxDistance: CGFloat {
        let lv = getLevel(for: "Laser")
        let currentLv = max(1, lv)
        let rangeMeters = 80 + (currentLv * 20)
        return CGFloat(rangeMeters * 80)
    }
    
    init() {
        load()
    }
    
    private func getLevel(for itemName: String) -> Int {
        return shopItems.first(where: { $0.name == itemName })?.lv ?? 0
    }
    
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
    
    func save() {
        var levelsDict: [String: Int] = [:]
        for item in shopItems {
            levelsDict[item.name] = item.lv
        }
        
        let saveData = GameSaveData(
            coins: coins,
            highScore: highScore,
            equippedItem: equippedItem,
            itemLevels: levelsDict
        )
        
        if let encoded = try? JSONEncoder().encode(saveData) {
            UserDefaults.standard.set(encoded, forKey: "DinoGameSaveData")
        }
    }
    
    func load() {
        if let savedData = UserDefaults.standard.data(forKey: "DinoGameSaveData"),
           let decoded = try? JSONDecoder().decode(GameSaveData.self, from: savedData) {
            
            self.coins = decoded.coins
            self.highScore = decoded.highScore
            self.equippedItem = decoded.equippedItem
            
            for (index, item) in shopItems.enumerated() {
                if let savedLv = decoded.itemLevels[item.name] {
                    shopItems[index].lv = savedLv
                }
            }
        }
    }
}
