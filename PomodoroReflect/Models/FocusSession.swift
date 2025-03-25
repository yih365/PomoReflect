//
//  FocusSession.swift
//  PomodoroReflect
//
//  Created by Yiyi Huang on 3/24/25.
//

import Foundation
import SwiftData

@Model
final class FocusSession {
    var focusSessions: [FocusLevel]

    init() {
        self.focusSessions = []
    }
    
    func addFocusLevel(_ focusLevel: FocusLevel) {
        focusSessions.append(focusLevel)
    }
}

