//
//  TabStates.swift
//  PomodoroReflect
//
//  Created by Yiyi Huang on 3/30/25.
//

import SwiftUI

enum BreakTabs {
    case doodling, breathing
}

@Observable
class TabStates {
    static var shared = TabStates()

    var pageOpen = false
    var selectedBreakTab = BreakTabs.breathing
    var mode = ViewMode.FullTimer

    private let userDefaultsKey = "lastOpenedTab"
    
    var selectedTab: Int {
        didSet {
            UserDefaults.standard.set(selectedTab, forKey: userDefaultsKey)
        }
    }
    
    init() {
        self.selectedTab = UserDefaults.standard.integer(forKey: userDefaultsKey) // Default to 0 if not set
    }
    
    func setBreakTabs(for breakExer: String) {
        if (breakExer == "None") {
            // don't open anything for None
            return
        }
        
        mode = ViewMode.HalfTimer  // Show page view
        selectedTab = 2  // Show break exercises page
        if (breakExer == "Doodling") {
            selectedBreakTab = .doodling
        } else if (breakExer == "Breathing") {
            selectedBreakTab = .breathing
        } else {
            // 50/50 for either based on random chance
            selectedBreakTab = [BreakTabs.doodling, BreakTabs.breathing].randomElement()!
        }
    }
}
