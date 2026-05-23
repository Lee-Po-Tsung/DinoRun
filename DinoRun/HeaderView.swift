//
//  HeaderView.swift
//  DinoRun
//
//  Created by test on 2026/5/17.
//

import SwiftUI

struct HeaderView: View {
    let text : String
    @Binding var currentGameState: GameState
    let returnBtn : Bool
    let coin: Bool
    
    @Environment(GameData.self) var gameData
    
    init(_ text: String, currentGameState: Binding<GameState>, returnBtn : Bool = true, coin: Bool = true) {
        self.text = text
        self._currentGameState = currentGameState
        self.returnBtn = returnBtn
        self.coin = coin
    }
    
    var body: some View {
        ZStack {
            if returnBtn {
                HStack {
                    Button(action: { currentGameState = .home }) {
                        Image(systemName: "house.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.white)
                            .padding(15)
                            .background(Color(white: 0.3))
                            .cornerRadius(8)
                    }
                    Spacer()
                    coinV(num: gameData.coins, 50)
                    .padding()
                    .padding(.trailing, 20)
                    .background(Color(white: 0.7))
                    .cornerRadius(15)
                }
            }
            MyText(text, size: 100)
                .tracking(6)
                .foregroundColor(.black)
                .padding(.vertical, 24)
                .padding(.horizontal, 100)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(white: 0.85))
                        .shadow(color: .white.opacity(0.8), radius: 4, x: -2, y: -2)
                        .shadow(color: .black.opacity(0.6), radius: 10, x: 8, y: 8)
                )
                .padding(.vertical, 50)
        }
    }
}

struct coinV : View {
    let num: Int
    let imgSize: CGFloat
    let textSize: CGFloat
    
    init(num: Int, _ size: CGFloat) {
        self.num = num
        self.imgSize = size
        self.textSize = size
    }
    
    init(num: Int, _ imgSize: CGFloat, _ textSize: CGFloat) {
        self.num = num
        self.imgSize = imgSize
        self.textSize = textSize
    }
    
    var body: some View {
        HStack {
            Image("coin1")
                .resizable()
                .interpolation(.none)
                .scaledToFit()
                .frame(height: imgSize)
            MyText(" X\(num)", size: textSize)
                .foregroundStyle(Color.yellow)
        }
        .shadow(color: .black, radius: 1, x: 1, y: 1)
    }
}

#Preview {
    HeaderView("Hello", currentGameState: .constant(.equipment), returnBtn: true)
        .environment(GameData())
}
