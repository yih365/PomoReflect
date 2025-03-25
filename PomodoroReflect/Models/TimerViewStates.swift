//
//  TimerViewStates.swift
//  PomodoroReflect
//
//  Created by Yiyi Huang on 3/11/25.
//

import CoreFoundation
import Foundation

class TimerViewStates:ObservableObject {
    static var shared = TimerViewStates()
    
    // Tab states
    @Published var tabsCollected: Int = 0
    @Published var totalTabWidth: CGFloat = 0
    @Published var tabSpacing: CGFloat = 10
    
    var numTabs = 3
    
    func updateTabWidths(tabWidth: CGFloat) {
        if (tabsCollected < numTabs) {
            tabsCollected += 1
            totalTabWidth += tabWidth
        }
    }
}
