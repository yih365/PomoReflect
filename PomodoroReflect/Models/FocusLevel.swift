//
//  FocusLevel.swift
//  PomodoroReflect
//
//  Created by Yiyi Huang on 3/16/25.
//

import Foundation
import SwiftData

@Model
final class FocusLevel {
    // Focus level ranging from 1-5
    var sessionId: Int
    var level: Int

    init(level: Int, sessionId: Int) {
        self.level = level
        self.sessionId = sessionId
    }
}
