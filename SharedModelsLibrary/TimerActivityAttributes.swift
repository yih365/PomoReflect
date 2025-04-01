//
//  TimerActivityAttributes.swift
//  PomodoroReflect
//
//  Created by Yiyi Huang on 2/12/25.
//


import ActivityKit
import Foundation

struct TimerActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var endTime: Date
        var remainingTime: TimeInterval
        var timerRunning: Bool
        var timerType: String
    }
}

extension TimerActivityAttributes {
    static var preview: TimerActivityAttributes {
        TimerActivityAttributes()
    }
}

extension TimerActivityAttributes.ContentState {
    static var zero: TimerActivityAttributes.ContentState {
        TimerActivityAttributes.ContentState(endTime: Date.now, remainingTime: 0, timerRunning: false, timerType: "Focus")
     }
}
