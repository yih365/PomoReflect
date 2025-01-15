//
//  TopBar.swift
//  PomodoroReflect
//
//  Created by Yiyi Huang on 1/9/25.
//


import SwiftUI

struct TopBar: View {
    var timerColor: Color
    var logoName: String
    var onSettingsTapped: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: logoName)
                .resizable()
                .frame(width: 30, height: 30)
                .padding(.leading)

            Spacer()

            Button(action: {
                onSettingsTapped()
            }) {
                Image(systemName: "gear")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .padding(.trailing)
                    .foregroundColor(.white)
            }
        }
        .padding()
        .background(timerColor)
        .frame(maxWidth: .infinity)
    }
}
