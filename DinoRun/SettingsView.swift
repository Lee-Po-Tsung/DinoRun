//
//  SettingsView.swift
//  DinoRun
//
//  Created by test on 2026/5/17.
//

import SwiftUI

struct SettingsView: View {
    @Binding var currentGameState: GameState
    
    // 音量狀態 (數值範圍 0.0 到 1.0)
    @State private var sfxVolume: Double = 1.0
    @State private var bgmVolume: Double = 1.0
    
    var body: some View {
        ZStack {
            // 1. 白色背景
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 60) {
                
                HeaderView("SETTINGS", currentGameState: $currentGameState, returnBtn: false)
                
                // --- 滑桿控制區 ---
                VStack(spacing: 50) {
                    // Sound effects 滑桿
                    VolumeSliderRow(title: "Sound effects", value: $sfxVolume)
                    
                    // BGM 滑桿
                    VolumeSliderRow(title: "BGM", value: $bgmVolume)
                }
                .padding(.horizontal, 80) // 讓滑桿不要貼齊螢幕邊緣
                
                Spacer()
                
                // --- 返回按鈕 ---
                Button(action: {
                    currentGameState = .home // 返回首頁
                }) {
                    Text("RETURN")
                        .font(.system(size: 36, weight: .bold, design: .monospaced))
                        .foregroundColor(.black)
                        .frame(width: 250, height: 80)
                        .background(Color(white: 0.85)) // 淺灰色按鈕
                        .cornerRadius(10)
                        // 復古陰影效果
                        .shadow(color: Color(white: 0.7), radius: 0, x: 5, y: 5)
                }
                .padding(.bottom, 60)
            }
        }
    }
}

// 獨立出來的「滑桿列」元件，讓程式碼更乾淨
struct VolumeSliderRow: View {
    var title: String
    @Binding var value: Double
    
    var body: some View {
        HStack(spacing: 30) {
            // 左側文字 (靠右對齊，讓 Sound effects 跟 BGM 的尾端切齊)
            Text(title)
                .font(.system(size: 40, weight: .bold, design: .monospaced))
                .foregroundColor(.black)
                .frame(width: 380, alignment: .trailing)
            
            // 系統原生滑桿 (將顏色設為黑色以符合像素風格)
            Slider(value: $value, in: 0...1)
                .accentColor(.black)
            
            // 右側百分比顯示 (將小數轉換成 0~100 的整數)
            Text("\(Int(value * 100))%")
                .font(.system(size: 36, weight: .bold, design: .monospaced))
                .foregroundColor(.black)
                .frame(width: 120, alignment: .leading)
        }
    }
}

#Preview(traits: .landscapeLeft) {
    SettingsView(currentGameState: .constant(.settings))
}
