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
    @State private var tabsCollected: Int = 0
    @State private var totalTabWidth: CGFloat = 0
    
    // State save for auto switch to long break
    @State private var avgFocusForLongBreak: Double = 4
    @State private var numCompleteFocusSessions: Int = 0
    
    // Timer variables
    @State private var timer: Timer? = nil
    @State private var remainingTimeInSecs: Int = 25*60
    @State private var isTimerRunning = false
    
    // Settings
    // Auto start breaks and timer
    @State private var autoStartBreaks = UserDefaults.standard.bool(forKey: "autoStartBreaks")
    @State private var selectedBackgroundNoise = TimerSettingsView.backgroundNoiseOptions[0]

    // List of pairs (timer name, duration in seconds)
    @State private var tabs = [
        ("Focus", 25 * 60),
           ("Short Break", 5 * 60),
           ("Long Break", 10 * 60)
    ]
    @State private var colors:[Color] = [.dullRed, .customBlue, .longBlue]
    
    // Screen spread animation
//    @State private var backgroundClr = Color.dullRed
//    @State private var spreadAnimation = false

    @State private var tabSpacing: CGFloat = 10
    
    var body: some View {
        ZStack {
            // Dynamic background color based on timer state and selected tab
            backgroundColor(for: selectedTab)
                .edgesIgnoringSafeArea(.all) // Ensures the background fills the entire screen
            
            VStack {
                // Use the TopBar view here
                TopBar(timerRunning:$isTimerRunning,timerColor: colors[selectedTab],logoName: "leaf.fill", onSettingsTapped: {
                    showSettings = true
                })
                .sheet(isPresented: $showSettings) {
                    TimerSettingsView(tabs: $tabs, autoStartBreaks: $autoStartBreaks, selectedBackgroundNoise: $selectedBackgroundNoise, onSave: {
                        stopTimer()
                        remainingTimeInSecs = tabs[selectedTab].1
                    })
                }
                
                Spacer()
                
                GeometryReader { geometry in
                    // Tab buttons
                    HStack(spacing: tabSpacing) {
                        ForEach(0..<tabs.count, id: \.self) { index in
                            if (!isTimerRunning || (isTimerRunning && selectedTab == index)) {
                                Button(action: {
                                    selectedTab = index
                                    resetTimer()
                                }) {
                                    Text(tabs[index].0)
                                        .padding()
                                        .foregroundColor(getTabForegroundColor(for: index))
                                        .background(getTabBackgroundColor(for:index))
                                        .font(.system(size: 16))
                                        .cornerRadius(10)
                                }.background(GeometryReader { tabGeometry in
                                    Color.clear
                                        .onAppear {
                                            // Capture the total width of all tabs on start
                                            if (tabsCollected < 3) {
                                                tabsCollected += 1
                                                totalTabWidth += tabGeometry.size.width
                                            }
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
                            Text(timeString(from: remainingTimeInSecs))
                                .foregroundColor(.white)
                                .padding()
                                .font(.system(size: 65, weight: .bold))
                            
                            Button(action: {
                                //                        print("Button tapped in Tab \(selectedTab + 1)")
//                                spreadAnimation.toggle()
                                if isTimerRunning {
                                    stopTimer()
                                } else {
                                    startTimer()
                                }
                            }) {
                                HStack {
                                    Image(systemName: isTimerRunning ? "pause.fill" : "play.fill")
                                        .font(.title2)
                                    Text(isTimerRunning ? "Stop Timer" : "Start Timer")
                                }
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
//                }
//            }
        }
        .onAppear(
            perform: loadDefaultSettings
        )
    }
    
    private func loadDefaultSettings() {
            let focusTime = UserDefaults.standard.integer(forKey: "Focus")
            let shortBreakTime = UserDefaults.standard.integer(forKey: "Short Break")
            let longBreakTime = UserDefaults.standard.integer(forKey: "Long Break")
            
//        tabs[0].1 = focusTime > 0 ? focusTime: tabs[0].1
        tabs[0].1 = 5
        tabs[1].1 = shortBreakTime > 0 ? shortBreakTime : tabs[1].1
//        tabs[1].1 = 5
        tabs[2].1 = longBreakTime > 0 ? longBreakTime : tabs[2].1
            
        remainingTimeInSecs = tabs[0].1 // Default to focus time on load
        
        autoStartBreaks = UserDefaults.standard.bool(forKey: "autoStartBreaks")
        selectedBackgroundNoise = UserDefaults.standard.string(forKey: "BGNoise") ?? TimerSettingsView.backgroundNoiseOptions[0]
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
        resetTimerDur()
        
        if (autoStartBreaks) {
            startTimer()
        }
    }
    
    func startTimer() {
        isTimerRunning = true
        AudioManager.shared.playBgAudio(selectedAudio: selectedBackgroundNoise)
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if remainingTimeInSecs > 0 {
                remainingTimeInSecs -= 1
                scheduleCountdownNotifications(timerDuration: remainingTimeInSecs)
            } else {
                // Timer has finished
                AudioManager.shared.playTimerEnd()
                scheduleTimerEndNotifications()
                if (selectedTab == 0) {
                    // Finished in Focus Mode
                    numCompleteFocusSessions += 1
                }
                stopTimer()
                switchTab()
            }
        }
    }
    
    func stopTimer() {
        isTimerRunning = false
        AudioManager.shared.stopBgAudio()
        timer?.invalidate()
        timer = nil
    }
    
    func resetTimer() {
        resetTimerDur()
        stopTimer()
    }
    
    func resetTimerDur() {
        isTimerRunning = false
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
        if (isTimerRunning) {
            // Only selected tab should be visible
            return colors[selectedTab]
        }
        
        // Timer not running
        if (selectedTab == tab) {
            return .white
        }
        return colors[selectedTab]
    }
    
    func getTabBackgroundColor(for tab: Int) -> Color {
        if (isTimerRunning) {
            // Only selected tab should be visible
            return .white
        }
        
        // Timer not running
        if (selectedTab == tab) {
            return colors[tab]
        }
        return .white
    }
}

#Preview {
    TimerView()
}
