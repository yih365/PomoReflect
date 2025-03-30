//
//  BreathingExerciseView.swift
//  PomodoroReflect
//
//  Created by Yiyi Huang on 3/25/25.
//


import SwiftUI

struct BoxBreathingView: View {
    var body: some View {
        VStack {
            Text("Breathe in, hold, breathe out, and hold (each for 4 seconds).\nImagine a box while you do this.")
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding()
                .foregroundColor(.black)

            // Placeholder for the box breathing diagram
            Image("box-diagram")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
                .padding()
        }
        .padding()
    }
}

struct BoxBreathingView_Previews: PreviewProvider {
    static var previews: some View {
        BoxBreathingView()
    }
}
