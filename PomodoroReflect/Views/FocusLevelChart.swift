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
        let twentyFourHoursAgo = calendar.date(byAdding: .hour, value: -24, to: now)!
        
        let recentFocusLevels = focusLevels.filter { level in
            return level.timestamp >= twentyFourHoursAgo && level.timestamp <= now
        }.sorted(by: { $0.sessionId > $1.sessionId })
        
        return recentFocusLevels
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
            return calendar.dateComponents([.weekOfYear, .year], from: level.timestamp)
        }
        
        let sortedWeeks = grouped.keys.sorted { comp1, comp2 in
            // First compare years
            if comp1.year != comp2.year {
                return (comp1.year ?? 0) < (comp2.year ?? 0)
            }
            
            // If same year, compare weeks
            return (comp1.weekOfYear ?? 0) < (comp2.weekOfYear ?? 0)
        }
        
        // Take last n weeks
        let numberOfWeeks = min(sortedWeeks.count, max(52, sortedWeeks.count))
        let weeksToShow = Array(sortedWeeks.suffix(numberOfWeeks))
        
        return weeksToShow.enumerated().map { index, weekComp in
            let levels = grouped[weekComp] ?? []
            let average = Double(levels.map(\.level).reduce(0, +)) / Double(levels.count)
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
