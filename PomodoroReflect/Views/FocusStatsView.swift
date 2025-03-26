import SwiftUI
import _SwiftData_SwiftUI

struct FocusStatsView: View {
    @Environment(\.modelContext) private var modelContext
    
    @StateObject private var sessionManager = SessionManager.shared

    @State private var selectedFocus: Int = 0
    
    @Query private var focusLevels: [FocusLevel]
    
    // Max session shown in graph at once
    private var graphLimit = 10

    var body: some View {
        VStack {
            Text("How focused were you? (Focus#\(sessionManager.sessionId))")
                .font(.headline)
                .foregroundColor(.black)

            HStack {
                ForEach(1...5, id: \.self) { level in
                    Circle()
                        .fill(level <= selectedFocus ? Color.blue : Color.gray.opacity(0.3))
                        .frame(width: 40, height: 40)
                        .onTapGesture {
                            selectedFocus = level
                            saveFocusLevel()
                        }
                }
            }
            .padding()
            .onChange(of: sessionManager.sessionId) { _ in
                resetSelectedFocus()
            }
            
            FocusLevelChart(graphLimit: graphLimit)
                .padding()
            
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

#Preview {
    FocusStatsView()
        .modelContainer(for: FocusLevel.self, inMemory:true)
}
