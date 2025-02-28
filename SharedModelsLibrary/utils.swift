//
//  utils.swift
//  PomodoroReflect
//
//  Created by Yiyi Huang on 2/24/25.
//

import Foundation

func getSecs(from timeInterval: TimeInterval) -> Int {
    return NSInteger(timeInterval) % 60
}

func getMins(from timeInterval: TimeInterval) -> Int {
    return (NSInteger(timeInterval)/60) % 60
}
