//
//  PomoLiveIntent.swift
//  PomodoroReflect
//
//  Created by Yiyi Huang on 2/20/25.
//

import SwiftUI
import AppIntents

struct PomoLiveIntent: LiveActivityIntent {
    init() {
        
    }
    
    init(activityId: String) {
        self.activityId = activityId
    }
    
    static var title: LocalizedStringResource = "Refresh Activity"
    static var description = IntentDescription("Get the newest Energy Status")
        
    @Parameter
    private var activityId: String?
    
    func perform() async throws -> some IntentResult{
//        print("refreshing \(String(describing: activityId))")
//        if let activityId = activityId {
//            await LiveActivityManager.endActivity(activityId)
//        }
        return .result()
    }
}
