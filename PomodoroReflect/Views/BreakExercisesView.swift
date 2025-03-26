//
//  BreakExercisesView.swift
//  PomodoroReflect
//
//  Created by Yiyi Huang on 3/25/25.
//


import SwiftUI

struct BreakExercisesView: View {
    @State private var selectedExercise: ExerciseType = .breathing
    
    private var bgColorSelected = Color.customBlue
    private var bgColorUnselected = Color.white

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
                        .background(selectedExercise == .breathing ? bgColorSelected : bgColorUnselected)
                        .foregroundColor(getFgColor(for: .breathing))
//                        .underline(selectedExercise != .breathing)
                        .cornerRadius(10)
                }

                Button(action: {
                    selectedExercise = .doodling
                }) {
                    Text("Doodling")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(selectedExercise == .doodling ? bgColorSelected : bgColorUnselected)
                        .foregroundColor(getFgColor(for: .doodling))
//                        .underline(selectedExercise != .doodling)
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
    
    private func getFgColor(for exercise: ExerciseType) -> Color {
        if (selectedExercise == exercise) {
            return .white
        }
        return bgColorSelected
    }
}

struct BreathingExerciseView: View {
    var body: some View {
//        Text("Breathing Exercise")
//            .font(.title)
        BoxBreathingView()
    }
}

struct DoodlingExerciseView: View {
    var body: some View {
//        Text("Doodling Exercise")
//            .font(.title)
        DoodleView()
    }
}

#Preview {
    BreakExercisesView()
}
