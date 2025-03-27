//
//  TimerView.swift
//  PomodoroReflect
//
//  Created by Yiyi Huang on 10/14/24.
//

import SwiftUI


struct TimerView: View {
    @Binding var viewMode: ViewMode
    var onHeightChange: ((CGFloat) -> Void)? // Closure to send height updates
    
    @State private var timer: TimerFunctionality = TimerFunctionality.shared
    @StateObject private var timerViewStates = TimerViewStates.shared

    @State private var showSettings = false
    
    var body: some View {
        ZStack {
            // Dynamic background color based on timer state and selected tab
            TimerView.backgroundColor()
                .edgesIgnoringSafeArea(.all) // Ensures the background fills the entire screen
            
            VStack {
                if (viewMode != ViewMode.HalfTimer) {
                // Use the TopBar view here
                TopBar(timerRunning:$timer.isTimerRunning,timerColor: Themes.shared.colors[timer.selectedTab],logoName: "AppIcon", onSettingsTapped: {
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
                                        .padding(viewMode == ViewMode.HalfTimer ? 5: 20)
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
                    .padding(.bottom, viewMode == ViewMode.HalfTimer ? 0: 18)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                }
                .frame(height: viewMode == ViewMode.HalfTimer ? 25 : 50)
                }

                if (viewMode == ViewMode.HalfTimer) {
                    HStack {
                        // Time text
                        Text(timeString(from: timer.remainingTimeInSecs))
                            .foregroundColor(.white)
                            .padding(.trailing, 10)
                            .font(.system(size: 65, weight: .bold))
                        
                        Button(action: {
                            if timer.isTimerRunning {
                                stopTimer()
                            } else {
                                timer.startTimer()
                            }
                        }) {
                            HStack {
                                Image(systemName: timer.isTimerRunning ? "pause.fill" : "play.fill")
                                    .font(.title2)
                            }
                            .foregroundColor(Themes.shared.colors[timer.selectedTab])
                            .padding(7)
                            .background(.white)
                            .cornerRadius(10)
                        }
                    }
                    .padding(10)
                    .background(Themes.shared.colors[timer.selectedTab])
                    .cornerRadius(15)
                } else {
                    VStack(spacing: 20) {
                        // Time text
                        Text(timeString(from: timer.remainingTimeInSecs))
                            .foregroundColor(.white)
                            .padding()
                            .font(.system(size: 65, weight: .bold))
                        
                        Button(action: {
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
                    if (viewMode == ViewMode.HalfTimer) {
                        Spacer()
                    }
                }
                    }
        }
        .onAppear(
            perform: loadDefaultSettings
        )
        .frame(width: UIScreen.main.bounds.width)
        .overlay(
            GeometryReader { geo in
                Color.clear
                    .onAppear {
                        onHeightChange?(geo.size.height)
                    }
                    .onChange(of: geo.size.height) {
                        onHeightChange?($1) // Access new height using $1
                    }
            }
        )
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
