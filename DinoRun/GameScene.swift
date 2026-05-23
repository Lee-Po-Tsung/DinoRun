//
//  GameScene.swift
//  DinoRun
//
//  Created by test on 2026/5/16.
//

import SpriteKit

class GameScene: SKScene {
    override func didMove(to view: SKView) {
        self.anchorPoint = CGPoint(x: 0, y: 0)

        // 測試：將背景或恐龍加進畫面中
        // let background = SKSpriteNode(imageNamed: "background")
        // background.position = CGPoint(x: 512, y: 384)
        // background.zPosition = -1
        // addChild(background)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
}
