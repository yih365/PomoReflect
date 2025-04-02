//
//  FocusLevelChart.swift
//  PomodoroReflect
//
//  Created by Yiyi Huang on 3/24/25.
//
import Charts
import SwiftUI
import SwiftData


enum ChartType {
    case daily
    case weekly
}

struct FocusLevelChart: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var focusLevels: [FocusLevel]
    
    private var graphLimit: Int
    private var chartType: ChartType
    
    init(graphLimit: Int, chartType: ChartType = .daily) {
        self.graphLimit = graphLimit
        self.chartType = chartType
    }

    var body: some View {
        VStack {
            Text(chartType == .daily ? "Daily Focus Levels" : "Weekly Average Focus")
                .font(.headline)
                .foregroundColor(.black)

            switch chartType {
            case .daily:
                dailyChart
            case .weekly:
                weeklyChart
            }
        }
    }
    
    private var dailyChart: some View {
        Chart(focusLevels.sorted(by: {$0.sessionId > $1.sessionId})) { focus in
            LineMark(
                x: .value("Session", focus.sessionId),
                y: .value("Focus Level", focus.level)
            )
            .foregroundStyle(Color.dullRed)
            .symbol(.circle)
        }
        .chartYScale(domain: 1...5)
        .chartXScale(domain: getLowerBound()...getUpperBound())
        .chartXAxis {
            AxisMarks { _ in
                AxisGridLine().foregroundStyle(Color.gray)
                AxisTick().foregroundStyle(Color.gray)
                AxisValueLabel().foregroundStyle(Color.gray)
            }
        }
        .chartYAxis {
            AxisMarks { _ in
                AxisGridLine().foregroundStyle(Color.gray)
                AxisTick().foregroundStyle(Color.gray)
                AxisValueLabel().foregroundStyle(Color.gray)
            }
        }
        .frame(height: 300)
        .padding()
    }
    
    private var weeklyChart: some View {
        let weeklyData = calculateWeeklyAverages()
        return Chart(weeklyData) { data in
            BarMark(
                x: .value("Day", data.day),
                y: .value("Average Focus", data.average)
            )
            .foregroundStyle(Color.dullRed)
        }
        .chartYScale(domain: 0...5)
        .chartYAxis {
            AxisMarks(position: .leading, values: .stride(by: 1)) { value in
                AxisGridLine().foregroundStyle(Color.gray)
                AxisTick().foregroundStyle(Color.gray)
                AxisValueLabel {
                    if let intValue = value.as(Int.self) {
                        Text("\(intValue)")
                            .foregroundStyle(Color.gray)
                    }
                }
            }
        }
        .frame(height: 300)
        .padding()
    }
    
    private func calculateWeeklyAverages() -> [WeeklyFocusData] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: focusLevels) { level in
            calendar.component(.weekday, from: level.timestamp)
        }
        
        return (1...7).compactMap { weekday in
            let levels = grouped[weekday] ?? []
            guard !levels.isEmpty else { return nil }
            
            let average = Double(levels.map(\.level).reduce(0, +)) / Double(levels.count)
            return WeeklyFocusData(
                day: calendar.weekdaySymbols[weekday - 1],
                average: average
            )
        }
    }
    
    private func getLowerBound() -> Int {
        return (focusLevels.map{ $0.sessionId }).min() ?? 1
    }
    
    private func getUpperBound() -> Int {
        return (focusLevels.map{ $0.sessionId }).max() ?? graphLimit
    }
}

struct WeeklyFocusData: Identifiable {
    let id = UUID()
    let day: String
    let average: Double
}
