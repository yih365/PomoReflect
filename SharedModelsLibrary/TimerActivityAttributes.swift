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
        var remainingTime: TimeInterval
    }

    var timerType: String
}
