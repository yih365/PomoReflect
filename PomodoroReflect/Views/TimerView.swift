//
//  TimerView.swift
//  PomodoroReflect
//
//  Created by Yiyi Huang on 10/14/24.
//

import SwiftUI

extension Color {
    static let longBlue = Color(red: 0.4, green: 0.6, blue: 0.96)
    static let customBlue = Color(red: 0.5, green: 0.6, blue: 0.96)
    static let dullRed = Color(red: 0.95, green: 0.5, blue: 0.45)
}

struct TimerView: View {
    @State private var showSettings = false
    
    @State private var selectedTab: Int = 0
    @State private var totalTabWidth: CGFloat = 0
    
    // State save for auto switch to long break
    @State private var avgFocusForLongBreak: Double = 4
    @State private var numCompleteFocusSessions: Int = 0
    
    // Timer variables
    @State private var timer: Timer? = nil
    @State private var remainingTimeInSecs: Int = 25*60
    @State private var isTimerRunning = false
    
    // Settings
    @State private var autoStartBreaks = UserDefaults.standard.bool(forKey: "autoStartBreaks")

    // List of pairs (timer name, duration in seconds)
    @State private var tabs = [
        ("Focus",UserDefaults.standard.integer(forKey: "Focus") > 0 ? UserDefaults.standard.integer(forKey: "Focus") : 25 * 60),
           ("Short Break",UserDefaults.standard.integer(forKey: "Short Break") > 0 ? UserDefaults.standard.integer(forKey: "Short Break") : 5 * 60),
           ("Long Break",UserDefaults.standard.integer(forKey: "Long Break") > 0 ? UserDefaults.standard.integer(forKey: "Long Break") : 10 * 60)
    ]
    @State private var colors:[Color] = [.dullRed, .customBlue, .longBlue]
    
    @State private var tabSpacing: CGFloat = 10
    
    var body: some View {
        ZStack {
            // Dynamic background color based on timer state and selected tab
            backgroundColor(for: selectedTab)
                .edgesIgnoringSafeArea(.all) // Ensures the background fills the entire screen
            
            VStack {
                // Use the TopBar view here
                TopBar(timerColor: colors[selectedTab],logoName: "leaf.fill", onSettingsTapped: {
                    showSettings = true
                })
                .sheet(isPresented: $showSettings) {
                    TimerSettingsView(tabs: $tabs, autoStartBreaks: $autoStartBreaks, onSave: {
                        stopTimer()
                        remainingTimeInSecs = tabs[selectedTab].1
                    })
                }
                
                Spacer()
                
                // Tab buttons
                GeometryReader { geometry in
                    HStack(spacing: tabSpacing) {
                        ForEach(0..<tabs.count, id: \.self) { index in
                            Button(action: {
                                selectedTab = index
                                resetTimer()
                            }) {
                                Text(tabs[index].0)
                                    .padding()
                                    .foregroundColor(getTabForegroundColor(for: index))
                                    .background(selectedTab == index ? colors[index] : Color.clear)
                                    .font(.system(size: 16))
                                    .cornerRadius(10)
                            }.background(GeometryReader { tabGeometry in
                                Color.clear
                                    .onAppear {
                                        // Capture the total width of all tabs
                                        totalTabWidth += tabGeometry.size.width
                                    }
                            })
                        }
                    }
                    .padding(.bottom, 20)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                }
                .frame(height: 50)
                
                // Time text
                VStack(spacing: 20) {
                    Text(timeString(from: remainingTimeInSecs))
                        .foregroundColor(.white)
                        .padding()
                        .font(.system(size: 65, weight: .bold))
                    
                    Button(action: {
                        print("Button tapped in Tab \(selectedTab + 1)")
                        if isTimerRunning {
                            stopTimer()
                        } else {
                            startTimer()
                        }
                    }) {
                        Text(isTimerRunning ? "Stop Timer" : "Start Timer")
                            .foregroundColor(colors[selectedTab])
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(.white)
                            .cornerRadius(10)
                    }
                }
                .padding()
                .background(colors[selectedTab])
                .cornerRadius(15)
                .frame(width: totalTabWidth + CGFloat(tabs.count - 1) * tabSpacing)
                
                Spacer()
                Spacer()
            }
        }
            .onAppear(
                perform: loadDefaultTimers
            )
        }
    
    private func loadDefaultTimers() {
            let focusTime = UserDefaults.standard.integer(forKey: "Focus")
            let shortBreakTime = UserDefaults.standard.integer(forKey: "Short Break")
            let longBreakTime = UserDefaults.standard.integer(forKey: "Long Break")
            
//        tabs[0].1 = focusTime > 0 ? focusTime: tabs[0].1
        tabs[0].1 = 1
        tabs[1].1 = shortBreakTime > 0 ? shortBreakTime : tabs[1].1
        tabs[2].1 = longBreakTime > 0 ? longBreakTime : tabs[2].1
            
        remainingTimeInSecs = tabs[0].1 // Default to focus time on load
    }
    
    func switchTab() {
        if selectedTab == 0 { // If currently in Focus mode
            if numCompleteFocusSessions % Int(floor(avgFocusForLongBreak)) == 0 {
                selectedTab = 2
            } else {
                selectedTab = 1 // Switch to Short Break
            }
        } else if selectedTab == 1 { // If in Short Break
            selectedTab = 0 // Switch back to Focus mode
        }
        resetTimer()
        
        print("start break",autoStartBreaks)
        print("selected tab",selectedTab)
        if (autoStartBreaks && selectedTab != 0) {
            startTimer()
        }
    }
    
    func startTimer() {
        print("starting timer?")
        isTimerRunning = true
        AudioManager.shared.playSilentAudio()
//        AudioManager.shared.playTimerEnd()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if remainingTimeInSecs > 0 {
                remainingTimeInSecs -= 1
                scheduleCountdownNotifications(timerDuration: remainingTimeInSecs)
            } else {
                // Timer has finished
                AudioManager.shared.playTimerEnd()
                if (selectedTab == 0) {
                    // Finished in Focus Mode
                    numCompleteFocusSessions += 1
                }
                switchTab()
                stopTimer()
            }
        }
    }
    
    func stopTimer() {
        isTimerRunning = false
        AudioManager.shared.stopSilentAudio()
        timer?.invalidate()
        timer = nil
    }
    
    func resetTimer() {
        isTimerRunning = false
        stopTimer()
        remainingTimeInSecs = tabs[selectedTab].1
    }
    
    func timeString(from seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func backgroundColor(for tab: Int) -> Color {
        if isTimerRunning {
            return colors[selectedTab]
        } else {
            return .white
        }
    }
    
    func getTabForegroundColor(for tab: Int) -> Color {
        if (selectedTab == tab || isTimerRunning) {
            return .white
        } else {
            return colors[selectedTab]
        }
    }
}

#Preview {
    TimerView()
}
