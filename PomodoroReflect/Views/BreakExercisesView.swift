//
//  BreakExercisesView.swift
//  PomodoroReflect
//
//  Created by Yiyi Huang on 3/25/25.
//


import SwiftUI

struct BreakExercisesView: View {
    @State private var selectedExercise: ExerciseType = .breathing

    enum ExerciseType {
        case breathing, doodling
    }

    var body: some View {
        VStack {
            // Buttons to switch exercises
            HStack {
                Button(action: {
                    selectedExercise = .breathing
                }) {
                    Text("Breathing")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(selectedExercise == .breathing ? Color.gray.opacity(0.8) : Color.gray.opacity(0.5))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                Button(action: {
                    selectedExercise = .doodling
                }) {
                    Text("Doodling")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(selectedExercise == .doodling ? Color.gray.opacity(0.8) : Color.gray.opacity(0.5))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()

            // Content area for selected exercise
            Spacer()
            if selectedExercise == .breathing {
                BreathingExerciseView()
            } else {
                DoodlingExerciseView()
            }
            Spacer()
        }
    }
}

struct BreathingExerciseView: View {
    var body: some View {
        Text("Breathing Exercise")
            .font(.title)
        BoxBreathingView()
    }
}

struct DoodlingExerciseView: View {
    var body: some View {
        Text("Doodling Exercise")
            .font(.title)
        DoodleView()
    }
}

#Preview {
    BreakExercisesView()
}
