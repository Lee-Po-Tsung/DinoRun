//
//  PauseView.swift
//  DinoRun
//
//  Created by test on 2026/5/17.
//

import SwiftUI

struct PauseView: View {
    @Binding var currentGameState: GameState
    @Binding var isPaused: Bool // 控制遊戲是否暫停
    
    var body: some View {
        ZStack {
            // 半透明遮罩
            Color.black.opacity(0.6).ignoresSafeArea()
            
            VStack(spacing: 40) {
                Text("PAUSED")
                    .font(.system(size: 60, weight: .heavy, design: .monospaced))
                    .foregroundColor(.white)
                    .shadow(radius: 5)
                
                HStack(spacing: 30) {
                    // 回首頁按鈕
                    IconButton(iconName: "house.fill") {
                        isPaused = false // 確保解除暫停狀態
                        currentGameState = .home
                    }
                    
                    // 重新開始按鈕
                    IconButton(iconName: "arrow.clockwise") {
                        // 這裡未來可以加入重置遊戲的邏輯
                        isPaused = false
                    }
                    
                    // 繼續遊戲按鈕
                    IconButton(iconName: "play.fill") {
                        isPaused = false
                    }
                }
            }
            .padding(40)
            .background(Color(white: 0.2))
            .cornerRadius(20)
            .shadow(radius: 10)
        }
    }
}

// 可重複使用的圖示按鈕元件
struct IconButton: View {
    var iconName: String
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: iconName)
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(.black)
                .frame(width: 80, height: 80)
                .background(Color.white)
                .clipShape(Circle())
                .shadow(radius: 5, y: 5)
        }
    }
}

// 預覽
#Preview(traits: .landscapeLeft) {
    PauseView(currentGameState: .constant(.playing), isPaused: .constant(true))
}
