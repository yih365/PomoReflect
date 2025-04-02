import SwiftUI
import _SwiftData_SwiftUI

struct FocusStatsView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var sessionManager = SessionManager.shared
    @Query private var focusLevels: [FocusLevel]
    @State private var selectedChartType: ChartType = .daily
    private var graphLimit = 15

    var body: some View {
        VStack {
            FocusLogView()
            
            // Stats section
            if !focusLevels.isEmpty {
                VStack(spacing: 16) {
                    Text("Focus Statistics")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(Color.black)
                    
                    HStack(spacing: 20) {
                        StatItemView(
                            title: "Average",
                            value: String(format: "%.1f", Double(focusLevels.map { $0.level }.reduce(0, +)) / Double(focusLevels.count)),
                            subtitle: "Focus Level"
                        )
                        
                        StatItemView(
                            title: "Highest",
                            value: "\(focusLevels.map { $0.level }.max() ?? 0)",
                            subtitle: "Achievement"
                        )
                        
                        StatItemView(
                            title: "Total",
                            value: "\(focusLevels.count)",
                            subtitle: "Sessions"
                        )
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.white)
                        .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
                )
                .padding(.horizontal)
                .padding(.bottom, 10)
            }
            
            Picker("Chart Type", selection: $selectedChartType) {
                Text("Daily").tag(ChartType.daily)
                Text("Weekly").tag(ChartType.weekly)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            
            FocusLevelChart(graphLimit: graphLimit, chartType: selectedChartType)
                .padding()
            
            Button(action: {
                resetFocusLevels()
            }) {
                HStack {
                    Image(systemName: "arrow.counterclockwise.circle.fill")
                    Text("Reset Focus Levels")
                }
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.red.opacity(0.8))
                        .shadow(color: .red.opacity(0.3), radius: 4, x: 0, y: 2)
                )
            }
            .padding(.top, 10)
        }
        .padding()
        .background(Color.pagePigment)
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


struct StatItemView: View {
    let title: String
    let value: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.black)
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .frame(minWidth: 80)
    }
}
