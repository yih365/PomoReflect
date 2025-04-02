//
//  BreathingExerciseView.swift
//  PomodoroReflect
//
//  Created by Yiyi Huang on 3/25/25.
//


import SwiftUI

struct BoxBreathingView: View {
    @State private var isExercising = false
    @StateObject private var boxAnimation = BoxBreathingAnimation()
    @State private var timerFunctionality = TimerFunctionality.shared

    var body: some View {
        VStack {
            Text("Box Breathing Exercise")
                .font(.title2)
//                .padding(.bottom)
                .foregroundColor(.black)
            
            Text("Breathe in, hold, breathe out, and hold (each for 4 seconds).")
                .font(.caption)
                .multilineTextAlignment(.center)
//                .padding()
                .foregroundColor(.black)

            BoxBreathingAnimationView(animation: boxAnimation)
                .padding(40)
                .frame(height: 300)  // Add fixed height to ensure consistent spacing
            
            Spacer()  // Add spacer to push button to bottom
            
            Button(action: {
                isExercising.toggle()
                if isExercising {
                    boxAnimation.startAnimation()
                } else {
                    boxAnimation.stopAnimation()
                }
            }) {
                Text(isExercising ? "Stop Exercise" : "Start Exercise")
                    .foregroundColor(.white)
                    .padding()
                    .background(timerFunctionality.selectedTab != 0 ? Themes.shared.colors[timerFunctionality.selectedTab] : Color.black)
                    .cornerRadius(10)
            }
            .padding(.bottom, 40)  // Add bottom padding to button
        }
        .padding()
    }
}

struct BoxBreathingView_Previews: PreviewProvider {
    static var previews: some View {
        BoxBreathingView()
    }
}
