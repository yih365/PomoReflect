//
//  BreakManager.swift
//  PomodoroReflect
//
//  Created by Yiyi Huang on 3/30/25.
//


//
//  DefaultBreakManager.swift
//  PomodoroReflect
//
//  Created by Yiyi Huang on 3/30/25.
//

import Observation
import Foundation

@Observable
class BreakManager {
    static let shared = BreakManager()
    
    private let userDefaultsKey = "SelectedBreakType"
    
    static var breakTypes = [
        "None",
        "Doodling",
        "Breathing",
        "Mixed"
    ]
    
    var selectedBreakType: String {
        didSet {
            UserDefaults.standard.set(selectedBreakType, forKey: userDefaultsKey)
        }
    }
    
    init() {
        // Load saved value from UserDefaults, default to "Mixed" if not set
        self.selectedBreakType = UserDefaults.standard.string(forKey: userDefaultsKey) ?? BreakManager.breakTypes[3]
    }
}
