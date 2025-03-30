import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), focusTime: "25:00")
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date(), focusTime: getFocusTime())
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []
        let currentDate = Date()
        
        // Retrieve the focus time from UserDefaults
        let focusTime = getFocusTime()

        // Generate a timeline with entries containing the focus time
        for hourOffset in 0..<5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, focusTime: focusTime)
            entries.append(entry)
        }

        return Timeline(entries: entries, policy: .atEnd)
    }

    // Helper function to retrieve the focus time from UserDefaults
    private func getFocusTime() -> String {
        var secs = UserDefaults(suiteName: "group.com.yh.pomodorofocus")?.integer(forKey: "Focus") ?? 0
        if secs == 0 {
            secs = 25*60 // default to 25 mins
        }
//        return String(secs)
        
        return getTimeString(from: TimeInterval(secs))
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let focusTime: String
}

struct PomoWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
            Text("Start Focus Time")
                .foregroundColor(.white)
            Text(entry.focusTime)
                .font(.largeTitle)
                .bold()
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Ensure full coverage
        .background(Color.dullRed) // Set the entire background to dullRed
    }
}

struct PomoWidget: Widget {
    let kind: String = "PomoWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            PomoWidgetEntryView(entry: entry)
        }
    }
}

extension ConfigurationAppIntent {
    fileprivate static var twentyFive: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.focusTime = "25:00"
        return intent
    }
}

#Preview(as: .systemSmall) {
    PomoWidget()
} timeline: {
    SimpleEntry(date: .now, focusTime: "25:00")
}
