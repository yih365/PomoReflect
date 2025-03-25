//
//  SessionManager.swift
//  PomodoroReflect
//
//  Created by Yiyi Huang on 3/17/25.
//


import SwiftUI

class SessionManager : ObservableObject {
    static var shared = SessionManager()

    @AppStorage("sessionId") var sessionId: Int = 0
    
    // Function to increment sessionId
    func startNewSession() {
        sessionId += 1
    }
}
