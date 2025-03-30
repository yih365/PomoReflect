//
//  TimerFunctionality.swift
//  PomodoroReflect
//
//  Created by Yiyi Huang on 2/28/25.
//

import Observation
import Foundation
import SwiftUI

@Observable
class TimerFunctionality {
    static var shared = TimerFunctionality()
    
    let sharedDefaults = UserDefaults(suiteName: "group.com.yh.pomodorofocus") ?? UserDefaults.standard
    
    private var popupManager = PopupManager.shared
    
    // Don't need state here because session is only ever written, not read
    private var sessionManager = SessionManager.shared

    // List of pairs (timer name, duration in seconds)
    var tabs = [
        ("Focus", 25 * 60),
           ("Short Break", 5 * 60),
           ("Long Break", 10 * 60)
    ]
    
    // Timer variables
    var timer: Timer? = nil
    var remainingTimeInSecs: Int = 25*60
    var isTimerRunning = false
    var selectedTab: Int = 0
    
    // Settings
    var autoStartBreaks: Bool = true   // Auto start breaks and timer
    var selectedBackgroundNoise = AudioManager.backgroundNoiseOptions[0]
    var showFocusLevelsPopup: Bool = true

    // State save for auto switch to long break
    var avgFocusForLongBreak: Double = 4
    var numCompleteFocusSessions: Int = 0

    init() {
        // Load default settings
        let focusTime = sharedDefaults.integer(forKey: "Focus")
        let shortBreakTime = sharedDefaults.integer(forKey: "Short Break")
        let longBreakTime = sharedDefaults.integer(forKey: "Long Break")
        
//        tabs[0].1 = focusTime > 0 ? focusTime: tabs[0].1
            tabs[0].1 = 5
        tabs[1].1 = shortBreakTime > 0 ? shortBreakTime : tabs[1].1
//            tabs[1].1 = 5
        tabs[2].1 = longBreakTime > 0 ? longBreakTime : tabs[2].1
            
        // Default to focus time on load
        remainingTimeInSecs = tabs[0].1
        
        autoStartBreaks = sharedDefaults.bool(forKey: "autoStartBreaks")
        selectedBackgroundNoise = sharedDefaults.string(forKey: "BGNoise") ?? AudioManager.backgroundNoiseOptions[0]
        showFocusLevelsPopup = sharedDefaults.bool(forKey: "showFocusOnFocusEnd")
    }
    
    func resetTimerDur() {
        isTimerRunning = false
        remainingTimeInSecs = tabs[selectedTab].1
    }
    
    func playBgAudio() {
        AudioManager.shared.playBgAudio(selectedAudio: selectedBackgroundNoise, isFocusTimer: selectedTab == 0)
    }
    
    func toggleTimer() {
        if self.isTimerRunning {
            stopTimer()
        } else {
            startTimer()
        }
    }

    func startTimer() {
        isTimerRunning = true
        playBgAudio()
        CountdownLiveActivity.shared.startLiveActivity(duration: TimeInterval(remainingTimeInSecs), timerType: tabs[selectedTab].0)
        DispatchQueue.main.async {
            self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                if self.remainingTimeInSecs > 0 {
                    self.remainingTimeInSecs -= 1
                } else {
                    // Timer has finished
                    AudioManager.shared.playTimerEnd()
                    Notifs.scheduleTimerEndNotifications()
                    CountdownLiveActivity.shared.stopLiveActivity()
                    if (self.selectedTab == 0) {
                        // Finished in Focus Mode
                        self.numCompleteFocusSessions += 1
                        
                        // Increment session ID only for focus session
                        self.sessionManager.startNewSession()
                        
                        // If set, show focus levels logging pop up
                        if (self.showFocusLevelsPopup) {
                            self.popupManager.showPopup()
                        }
                    }
                    self.stopTimer()
                    self.switchTab()
                }
            }
        }
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

    func stopTimer() {
        isTimerRunning = false
        AudioManager.shared.stopBgAudio()
        CountdownLiveActivity.shared.pauseLiveActivity(remainingTime:TimeInterval(remainingTimeInSecs))
        timer?.invalidate()
        timer = nil
        
    }
}
