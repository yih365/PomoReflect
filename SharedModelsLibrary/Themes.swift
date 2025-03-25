//
//  Themes.swift
//  PomodoroReflect
//
//  Created by Yiyi Huang on 2/24/25.
//

import SwiftUICore

extension Color {
    static let longBlue = Color(red: 0.4, green: 0.6, blue: 0.96)
    static let customBlue = Color(red: 0.5, green: 0.6, blue: 0.96)
    static let dullRed = Color(red: 0.95, green: 0.5, blue: 0.45)
    static let pagePigment = Color(red: 1, green: 0.99, blue: 0.98)
}

struct Themes {
    static var shared: Themes = Themes()
    @State var colors: [Color] = [.dullRed, .customBlue, .longBlue]
    @State var colorsDict: [String: Color] = [
        "Focus": .dullRed,
        "Short Break": .customBlue,
        "Long Break": .longBlue
    ]
}
