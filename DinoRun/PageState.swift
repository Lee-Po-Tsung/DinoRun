//
//  PageState.swift
//  DinoRun
//
//  Created by test on 2026/5/16.
//

import Foundation

// App 畫面狀態
enum GameState {
    case home       // 開始頁面
    case playing    // 遊戲畫面
    case shop       // 商店頁面
    case equipment  // 裝備頁面
    case settings   // 設定頁面
}

enum PlayingState {
    case nothing
    case starting
    case playing
    case paused
    case gameover
}
