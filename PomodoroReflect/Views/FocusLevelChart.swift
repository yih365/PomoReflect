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
    @Query(sort: \FocusLevel.timestamp, order: .reverse) private var focusLevels: [FocusLevel]
    
    private var graphLimit: Int
    private var chartType: ChartType
    
    init(graphLimit: Int, chartType: ChartType = .daily) {
        self._focusLevels = Query(sort: \FocusLevel.timestamp, order: .reverse)
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
    
    private func getTodayFocusLevels() -> [FocusLevel] {
        let calendar = getLocalCalendar()
        let now = Date()
        let todayComponents = calendar.dateComponents([.year, .month, .day], from: now)
        
        let todayFocusLevels = focusLevels.filter { level in
            let levelComponents = calendar.dateComponents([.year, .month, .day], from: level.timestamp)
            let matches = levelComponents.year == todayComponents.year &&
                       levelComponents.month == todayComponents.month &&
                       levelComponents.day == todayComponents.day
            return matches
        }.sorted(by: { $0.sessionId > $1.sessionId })
        
        return todayFocusLevels
    }

    private var dailyChart: some View {
        return Chart(getTodayFocusLevels()) { focus in
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
            LineMark(
                x: .value("Week", data.day),
                y: .value("Average Focus", data.average)
            )
            .foregroundStyle(Color.dullRed)
            .symbol(.circle)
        }
        .chartYScale(domain: 0...5)
        .chartXAxis {
            AxisMarks { _ in
                AxisGridLine().foregroundStyle(Color.gray)
                AxisTick().foregroundStyle(Color.gray)
                AxisValueLabel()
                    .foregroundStyle(Color.gray)
            }
        }
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
        
        // Group focus levels by week
        let grouped = Dictionary(grouping: focusLevels) { level in
            print(level.timestamp)
            return calendar.dateComponents([.weekOfYear, .year], from: level.timestamp)
        }
        
        // Sort weeks chronologically
        let sortedWeeks = grouped.keys.sorted { comp1, comp2 in
            guard let date1 = calendar.date(from: comp1),
                  let date2 = calendar.date(from: comp2) else {
                return false
            }
            return date1 > date2
        }
        
        // Take last n weeks (n = max(50, number of weeks))
        let numberOfWeeks = min(sortedWeeks.count, max(50, sortedWeeks.count))
        let weeksToShow = Array(sortedWeeks.prefix(numberOfWeeks))
        
        return weeksToShow.enumerated().map { index, weekComp in
            let levels = grouped[weekComp] ?? []
            let average = Double(levels.map(\.level).reduce(0, +)) / Double(levels.count)
            
            // Format week label (e.g., "W1")
            let weekLabel = "W\(numberOfWeeks - index)"
            
            return WeeklyFocusData(
                day: weekLabel,
                average: average
            )
        }
    }
    
    private func getLowerBound() -> Int {
        return (getTodayFocusLevels().map{ $0.sessionId }).min() ?? 1
    }
    
    private func getUpperBound() -> Int {
        return (getTodayFocusLevels().map{ $0.sessionId }).max() ?? graphLimit
    }
}

struct WeeklyFocusData: Identifiable {
    let id = UUID()
    let day: String  // Represents the week label (e.g., "W1", "W2", etc.)
    let average: Double
}
