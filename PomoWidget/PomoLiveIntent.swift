//
//  PomoLiveIntent.swift
//  PomodoroReflect
//
//  Created by Yiyi Huang on 2/20/25.
//

import SwiftUI
import AppIntents

struct PomoLiveIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Timer live activity"
    static var description = IntentDescription("Pause and play timer")
    
    init(timerRunning: Bool) {
        self.timerRunning = timerRunning
    }
    
    init() {}
        
    @Parameter(title: "Is Timer Running")
    var timerRunning: Bool
    
    func perform() async throws -> some IntentResult{
        print("intent is called")
        return .result()
    }
}
