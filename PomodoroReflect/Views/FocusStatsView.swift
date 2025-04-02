import SwiftUI
import _SwiftData_SwiftUI

struct FocusStatsView: View {
    @Environment(\.modelContext) private var modelContext
    
    @StateObject private var sessionManager = SessionManager.shared

    @State private var selectedFocus: Int = 0
    @State private var showToast: Bool = false
    
    @State private var toastMsg = ""
    
    @Query private var focusLevels: [FocusLevel]
    
    // Max session shown in graph at once
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
                            // Show toast
                            if (isShowToastCondition(level: level)) {
                                showToast = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    showToast = false
                                }
                            }

                            selectedFocus = level
                            saveFocusLevel()
                        }
                }
            }
            .padding()
            .onChange(of: sessionManager.sessionId) {
                resetSelectedFocus()
            }
            
            FocusLevelChart(graphLimit: graphLimit)
                .padding()
                .overlay(
                    VStack {
                        Spacer() // Pushes toast to the bottom
                        if showToast {
                            ToastView(message: toastMsg)
                                .transition(.opacity)
                                .padding(.bottom, 40) // Adjust position
                        }
                    }
                )

            Button(action: {
                resetFocusLevels()
            }) {
                Text("Reset Focus Levels")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(10)
            }
        }
        .padding()
        .background(Color.pagePigment)
    }
    
    /*
     This method will also set toast message.
     */
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
    
    private func resetSelectedFocus() {
        // Reset selectedFocus when the session ID changes
        selectedFocus = 0
    }
    
    private func resetFocusLevels() {
        do {
            let fetchRequest = FetchDescriptor<FocusLevel>()
            let focusLevels = try modelContext.fetch(fetchRequest)

            for focusLevel in focusLevels {
                modelContext.delete(focusLevel)
            }

            try modelContext.save()
            
            // Also reset Focus session
            sessionManager.resetSession()
        } catch {
            print("Error resetting focus levels: \(error)")
        }
    }
    
    private func saveFocusLevel() {
        guard sessionManager.sessionId > 0 else { return }
        guard selectedFocus > 0 else { return }
        print("Setting focus level \(selectedFocus) for session \(sessionManager.sessionId)")
        
        for focusLevel in focusLevels {
            print(focusLevel.sessionId)
        }
        
        withAnimation {
            let newStat = FocusLevel(level: selectedFocus, sessionId: sessionManager.sessionId)

            if let index = focusLevels.firstIndex(where: { $0.sessionId == sessionManager.sessionId }) {
                focusLevels[index].level = selectedFocus // Update focus level
                try? modelContext.save() // Save changes
            } else {
                // When adding element,
                // Erase element outside of graph limit
                if focusLevels.count >= graphLimit {
                    // Remove element at index current sessionId - graphLimit
                    if let index = focusLevels.firstIndex(where: { $0.sessionId == sessionManager.sessionId - graphLimit }) {
                        modelContext.delete(focusLevels[index])
                    }
                }
                modelContext.insert(newStat)
            }
        }
    }
}

struct ToastView: View {
    let message: String

    var body: some View {
        Text(message)
            .padding()
            .background(Color.black.opacity(0.8))
            .foregroundColor(.white)
            .clipShape(Capsule())
            .padding(.horizontal, 20)
    }
}

#Preview {
    FocusStatsView()
        .modelContainer(for: FocusLevel.self, inMemory:true)
}
