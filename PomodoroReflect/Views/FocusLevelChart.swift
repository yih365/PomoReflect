//
//  FocusLevelChart.swift
//  PomodoroReflect
//
//  Created by Yiyi Huang on 3/24/25.
//
import Charts
import SwiftUI
import SwiftData


struct FocusLevelChart: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var focusLevels: [FocusLevel]
    
    private var graphLimit: Int
    
    init(graphLimit: Int) {
        self.graphLimit = graphLimit
    }

    var body: some View {
        VStack {
            Text("Focus Levels Over Sessions")
                .font(.headline)

            Chart(focusLevels.sorted(by: {$0.sessionId > $1.sessionId})) { focus in
                LineMark(
                    x: .value("Session", focus.sessionId),
                    y: .value("Focus Level", focus.level)
                )
                .foregroundStyle(.blue)
                .symbol(.circle)
            }
            .chartYScale(domain: 1...5) // Focus level ranges from 1 to 5
            .chartXScale(domain: getLowerBound()...getUpperBound())
            .frame(height: 300)
            .padding()
        }
    }
    
    private func getLowerBound() -> Int {
        return (focusLevels.map{ $0.sessionId }).min() ?? 1
    }
    
    private func getUpperBound() -> Int {
        return (focusLevels.map{ $0.sessionId }).max() ?? graphLimit
    }
}
