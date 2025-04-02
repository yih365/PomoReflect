//
//  FocusStatsView 2.swift
//  PomodoroReflect
//
//  Created by Yiyi Huang on 3/30/25.
//


import SwiftUI
import _SwiftData_SwiftUI

struct FocusLogView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var sessionManager = SessionManager.shared
    @State private var selectedFocus: Int = 0
    @State private var showToast: Bool = false
    @State private var toastMsg = ""
    @State private var popupManager = PopupManager.shared
    @Query private var focusLevels: [FocusLevel]
    private var graphLimit = 15

    var body: some View {
        VStack {
            Text("How focused were you? (Focus #\(sessionManager.sessionId))")
                .font(.headline)
                .foregroundColor(.black)

            HStack {
                ForEach(1...5, id: \.self) { level in
                    Circle()
                        .fill(level <= selectedFocus ? Color.dullRed : Color.gray.opacity(0.3))
                        .frame(width: 40, height: 40)
                        .onTapGesture {
                            if (isShowToastCondition(level: level)) {
                                showToast = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    showToast = false
                                }
                            }
                            selectedFocus = level
                            saveFocusLevel()
                            popupManager.hidePopup()
                        }
                }
            }
            .padding()
            .onChange(of: sessionManager.sessionId) {
                resetSelectedFocus()
            }
            
            if showToast {
                ToastView(message: toastMsg)
                    .transition(.opacity)
            }
        }
        .padding()
        .background(Color.pagePigment)
    }
    
    private func resetSelectedFocus() {
        // Reset selectedFocus when the session ID changes
        selectedFocus = 0
    }
    
    private func saveFocusLevel() {
        guard sessionManager.sessionId > 0 else { return }
        guard selectedFocus > 0 else { return }
        print("Setting focus level \(selectedFocus) for session \(sessionManager.sessionId)")
        
        for focusLevel in focusLevels {
            print(focusLevel.sessionId)
        }
        
        withAnimation {
            let newStat = FocusLevel(level: selectedFocus, sessionId: sessionManager.sessionId, sessionDuration: sessionManager.prevSessionDuration)

            if let index = focusLevels.firstIndex(where: { $0.sessionId == sessionManager.sessionId }) {
                focusLevels[index].level = selectedFocus // Update focus level
                try? modelContext.save() // Save changes
            } else {
                // When adding element,
                // Erase element outside of graph limit
                // currenltly, no limit
//                if focusLevels.count >= graphLimit {
//                    // Remove element at index current sessionId - graphLimit
//                    if let index = focusLevels.firstIndex(where: { $0.sessionId == sessionManager.sessionId - graphLimit }) {
//                        modelContext.delete(focusLevels[index])
//                    }
//                }
                modelContext.insert(newStat)
            }
        }
    }
    // Add after saveFocusLevel() function
    private func isShowToastCondition(level: Int) -> Bool {
        let previousFocus = focusLevels.max(by: { $0.sessionId < $1.sessionId })?.level ?? 0

        if sessionManager.sessionId == 0 {
            toastMsg = "Finish a focus session to log your focus level."
            resetSelectedFocus()
        } else if sessionManager.sessionId > 1 && level > previousFocus {
            toastMsg = "Better focus! Good job!"
        } else if level < previousFocus && level < 3 {
            toastMsg = "Uh oh."
        } else {
            return false
        }
        return true
    }
}

#Preview {
    FocusStatsView()
        .modelContainer(for: FocusLevel.self, inMemory:true)
}
