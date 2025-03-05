//
//  utils.swift
//  PomodoroReflect
//
//  Created by Yiyi Huang on 2/24/25.
//

import Foundation

func getTimeString(from timeInterval: TimeInterval) -> String {
    return "\(getMinsString(from: timeInterval)):\(getSecsString(from: timeInterval))"
}

func getSecsString(from timeInterval: TimeInterval) -> String {
    return String(format: "%02d", NSInteger(timeInterval) % 60)
}

func getMinsString(from timeInterval: TimeInterval) -> String {
    return String(format: "%02d", (NSInteger(timeInterval)/60) % 60)
}
