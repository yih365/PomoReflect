//
//  FocusLevel.swift
//  PomodoroReflect
//
//  Created by Yiyi Huang on 3/16/25.
//

import Foundation
import SwiftData
import SharedModelsLibrary  // Add this import

@Model
final class FocusLevel {
    var sessionId: Int
    var level: Int
    var timestamp: Date
    var sessionDuration: Int  // in minutes
    
    init(level: Int, sessionId: Int, sessionDuration: Int) {
        self.level = level
        self.sessionId = sessionId
        let calendar = getLocalCalendar()
        self.timestamp = calendar.startOfDay(for: Date())
        self.sessionDuration = sessionDuration
    }
}
