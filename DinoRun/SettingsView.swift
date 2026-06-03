//
//  SettingsView.swift
//  DinoRun
//
//  Created by test on 2026/5/17.
//

import SwiftUI

struct SettingsView: View {
    @Environment(GameData.self) var gameData
    @Binding var currentGameState: GameState
    
    var body: some View {
        @Bindable var bindableGameData = gameData
        
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 60) {
                
                HeaderView("SETTINGS", currentGameState: $currentGameState, returnBtn: false)
                
                VStack(spacing: 50) {
                    VolumeSliderRow(
                        title: "Sound effects",
                        value: $bindableGameData.sfxVolume,
                        onDragEnd: {
                            gameData.save()
                        }
                    )
                    
                    VolumeSliderRow(
                        title: "BGM",
                        value: $bindableGameData.bgmVolume,
                        onDragEnd: {
                            gameData.save()
                        }
                    )
                    .onChange(of: gameData.bgmVolume) { oldValue, newValue in
                        gameData.bgmPlayer?.volume = Float(newValue)
                    }
                }
                .padding(.horizontal, 80)
                
                Spacer()
                
                Button(action: {
                    currentGameState = .home
                }) {
                    Text("RETURN")
                        .font(.system(size: 36, weight: .bold, design: .monospaced))
                        .foregroundColor(.black)
                        .frame(width: 250, height: 80)
                        .background(Color(white: 0.85))
                        .cornerRadius(10)
                        .shadow(color: Color(white: 0.7), radius: 0, x: 5, y: 5)
                }
                .padding(.bottom, 60)
            }
        }
    }
}

struct VolumeSliderRow: View {
    var title: String
    @Binding var value: Double
    var onDragEnd: () -> Void
    
    var body: some View {
        HStack(spacing: 30) {
            Text(title)
                .font(.system(size: 40, weight: .bold, design: .monospaced))
                .foregroundColor(.black)
                .frame(width: 380, alignment: .trailing)
            
            Slider(value: $value, in: 0...1, onEditingChanged: { isEditing in
                if !isEditing {
                    onDragEnd()
                }
            })
            .accentColor(.black)
            
            Text("\(Int(value * 100))%")
                .font(.system(size: 36, weight: .bold, design: .monospaced))
                .foregroundColor(.black)
                .frame(width: 120, alignment: .leading)
        }
    }
}

//#Preview(traits: .landscapeLeft) {
//    SettingsView(currentGameState: .constant(.settings))
//        .environment(GameData())
//}
