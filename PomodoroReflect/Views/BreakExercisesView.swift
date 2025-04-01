//
//  BreakExercisesView.swift
//  PomodoroReflect
//
//  Created by Yiyi Huang on 3/25/25.
//


import SwiftUI

struct BreakExercisesView: View {
    @State private var timerFunctionality = TimerFunctionality.shared
    
    @State private var tabStates = TabStates.shared
    
    private var bgColorUnselected = Color.white

    var body: some View {
        VStack {
            // Buttons to switch exercises
            HStack {
                Button(action: {
                    tabStates.selectedBreakTab = .breathing
                }) {
                    Text("Breathing")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(getBgColor(for: BreakTabs.breathing))
                        .foregroundColor(getFgColor(for: BreakTabs.breathing))
                        .cornerRadius(10)
                }

                Button(action: {
                    tabStates.selectedBreakTab = .doodling
                }) {
                    Text("Doodling")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(getBgColor(for: BreakTabs.doodling))
                        .foregroundColor(getFgColor(for: BreakTabs.doodling))
                        .cornerRadius(10)
                }
            }
            .padding()

            // Content area for selected exercise
            Spacer()
            if tabStates.selectedBreakTab == .breathing {
                BreathingExerciseView()
            } else {
                DoodlingExerciseView()
            }
            Spacer()
        }
        .background(Color.pagePigment)
    }
    
    private func getBgColor(for exercise: BreakTabs) -> Color {
        if (tabStates.selectedBreakTab == exercise) {
            if (timerFunctionality.selectedTab == 0) {
                // Not in break tab
                return .black
            }
            return Themes.shared.colors[timerFunctionality.selectedTab]
        }
        
        return bgColorUnselected
    }
    
    private func getFgColor(for exercise: BreakTabs) -> Color {
        if (tabStates.selectedBreakTab == exercise) {
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
        BoxBreathingView()
    }
}

struct DoodlingExerciseView: View {
    var body: some View {
        DoodleView()
    }
}

#Preview {
    BreakExercisesView()
}
