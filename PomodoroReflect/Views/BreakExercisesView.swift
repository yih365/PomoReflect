//
//  BreakExercisesView.swift
//  PomodoroReflect
//
//  Created by Yiyi Huang on 3/25/25.
//


import SwiftUI

struct BreakExercisesView: View {
    @State private var selectedExercise: ExerciseType = .breathing
    
    @State private var timerFunctionality = TimerFunctionality.shared
    
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
                        .background(getBgColor(for: .breathing))
                        .foregroundColor(getFgColor(for: .breathing))
                        .cornerRadius(10)
                }

                Button(action: {
                    selectedExercise = .doodling
                }) {
                    Text("Doodling")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(getBgColor(for: .doodling))
                        .foregroundColor(getFgColor(for: .doodling))
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
        .background(Color.pagePigment)
    }
    
    private func getBgColor(for exercise: ExerciseType) -> Color {
        if (selectedExercise == exercise) {
            if (timerFunctionality.selectedTab == 0) {
                // Not in break tab
                return .black
            }
            return Themes.shared.colors[timerFunctionality.selectedTab]
        }
        
        return bgColorUnselected
    }
    
    private func getFgColor(for exercise: ExerciseType) -> Color {
        if (selectedExercise == exercise) {
            return .white
        }
        
        if (timerFunctionality.selectedTab == 0) {
            // Not on a break tab
            return .black
        }
        
        return Themes.shared.colors[timerFunctionality.selectedTab]
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
