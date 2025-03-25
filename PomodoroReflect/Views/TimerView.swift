//
//  TimerView.swift
//  PomodoroReflect
//
//  Created by Yiyi Huang on 10/14/24.
//

import SwiftUI


struct TimerView: View {
    @Binding var viewMode: ViewMode
    
    @State private var timer: TimerFunctionality = TimerFunctionality.shared
    @StateObject private var timerViewStates = TimerViewStates.shared

    @State private var showSettings = false
    
    // Screen spread animation
//    @State private var backgroundClr = Color.dullRed
//    @State private var spreadAnimation = false

    var body: some View {
        ZStack {
            // Dynamic background color based on timer state and selected tab
            TimerView.backgroundColor()
                .edgesIgnoringSafeArea(.all) // Ensures the background fills the entire screen
            
            VStack {
                // Use the TopBar view here
                TopBar(timerRunning:$timer.isTimerRunning,timerColor: Themes.shared.colors[timer.selectedTab],logoName: "leaf.fill", onSettingsTapped: {
                    showSettings = true
                })
                .sheet(isPresented: $showSettings) {
                    TimerSettingsView(tabs: $timer.tabs, autoStartBreaks: $timer.autoStartBreaks, selectedBackgroundNoise: $timer.selectedBackgroundNoise, onSave: {
                        (changedTimers: Bool) in
                        timer.playBgAudio()
                        if (changedTimers) {
                            stopTimer()
                            timer.remainingTimeInSecs = timer.tabs[timer.selectedTab].1
                        }
                    })
                }
                
                Spacer()
                
                GeometryReader { geometry in
                    // Tab buttons
                    HStack(spacing: timerViewStates.tabSpacing) {
                        ForEach(0..<timer.tabs.count, id: \.self) { index in
                            if (!timer.isTimerRunning || (timer.isTimerRunning && timer.selectedTab == index)) {
                                Button(action: {
                                    timer.selectedTab = index
                                    resetTimer()
                                }) {
                                    Text(timer.tabs[index].0)
                                        .padding()
                                        .foregroundColor(getTabForegroundColor(for: index))
                                        .background(getTabBackgroundColor(for:index))
                                        .font(.system(size: 16))
                                        .cornerRadius(10)
                                }.background(GeometryReader { tabGeometry in
                                    Color.clear
                                        .onAppear {
                                            // Capture the total width of all tabs on start
                                            timerViewStates.updateTabWidths(tabWidth: tabGeometry.size.width)
                                        }
                                })
                            }
                        }
                    }
                    .padding(.bottom, 20)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                }
                .frame(height: 50)
                
//                ZStack {
//                    // Background that animates to the timer's box color
//                    backgroundClr
//                        .edgesIgnoringSafeArea(.all)
//                        .scaleEffect(spreadAnimation ? 5 : 1) // Dynamically scale
//                        .opacity(spreadAnimation ? 1 : 0) // Fully visible when spreading
//                        .animation(.easeInOut(duration: 1), value: spreadAnimation) // Animation duration
//                    ZStack{
//                        RoundedRectangle(cornerRadius: 16)
//                            .fill(backgroundClr)
//                            .frame(width: 200, height: 100) // Timer box size
                        
                        VStack(spacing: 20) {
                            // Time text
                            Text(timeString(from: timer.remainingTimeInSecs))
                                .foregroundColor(.white)
                                .padding()
                                .font(.system(size: 65, weight: .bold))
                            
                            Button(action: {
                                //                        print("Button tapped in Tab \(selectedTab + 1)")
//                                spreadAnimation.toggle()
                                if timer.isTimerRunning {
                                    stopTimer()
                                } else {
                                    timer.startTimer()
                                }
                            }) {
                                HStack {
                                    Image(systemName: timer.isTimerRunning ? "pause.fill" : "play.fill")
                                        .font(.title2)
                                    Text(timer.isTimerRunning ? "Stop Timer" : "Start Timer")
                                }
                                .foregroundColor(Themes.shared.colors[timer.selectedTab])
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(.white)
                                .cornerRadius(10)
                            }
                        }
                        .padding()
                        .background(Themes.shared.colors[timer.selectedTab])
                        .cornerRadius(15)
                        .frame(width: timerViewStates.totalTabWidth + CGFloat(timer.tabs.count - 1) * timerViewStates.tabSpacing)
                        
                        Spacer()
                        Spacer()
                    }
//                }
//            }
        }
        .onAppear(
            perform: loadDefaultSettings
        )
        .frame(width: UIScreen.main.bounds.width)
    }
    
    private func loadDefaultSettings() {
    }
    
    func stopTimer() {
        timer.stopTimer()
    }
    
    func resetTimer() {
        timer.resetTimerDur()
        stopTimer()
    }
    
    func timeString(from seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    static func backgroundColor() -> Color {
        if TimerFunctionality.shared.isTimerRunning {
            return Themes.shared.colors[TimerFunctionality.shared.selectedTab]
        } else {
            return .white
        }
    }
    
    func getTabForegroundColor(for tab: Int) -> Color {
        if (timer.isTimerRunning) {
            // Only selected tab should be visible
            return Themes.shared.colors[timer.selectedTab]
        }
        
        // Timer not running
        if (timer.selectedTab == tab) {
            return .white
        }
        return Themes.shared.colors[timer.selectedTab]
    }
    
    func getTabBackgroundColor(for tab: Int) -> Color {
        if (timer.isTimerRunning) {
            // Only selected tab should be visible
            return .white
        }
        
        // Timer not running
        if (timer.selectedTab == tab) {
            return Themes.shared.colors[tab]
        }
        return .white
    }
}

#Preview {
    @Previewable @State var mode = ViewMode.HalfTimer
    TimerView(viewMode: $mode)
}
