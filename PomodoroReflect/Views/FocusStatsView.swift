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
            Text("How focused were you? (Session#\(sessionManager.sessionId))")
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
            
            FocusLevelChart(graphLimit: graphLimit)
                .padding()
            
            Spacer()
            Spacer()
        }
        .padding()
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
