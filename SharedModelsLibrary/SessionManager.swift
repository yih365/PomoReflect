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
    @AppStorage("prevSessionDuration") var prevSessionDuration: Int = 0

    // Function to increment sessionId
    func startNewSession(prevSessionDuration: Int) {
        sessionId += 1
        self.prevSessionDuration = prevSessionDuration
    }
    
    func resetSession() {
        sessionId = 0
    }
}
