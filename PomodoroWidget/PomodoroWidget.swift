//
//  PomodoroWidget.swift
//  PomodoroReflect
//
//  Created by Yiyi Huang on 2/16/25.
//


import WidgetKit
import SwiftUI
import ActivityKit

struct PomodoroWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TimerActivityAttributes.self) { context in
            VStack {
                Text(context.attributes.timerType)
                    .font(.headline)
                    .foregroundColor(.white)
                Text("\(context.state.remainingTime) sec left")
                    .font(.title2)
                    .foregroundColor(.white)
            }
            .padding()
            .background(Color.red)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Text(context.attributes.timerType)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("\(context.state.remainingTime) sec")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Tap to open app")
                        .font(.caption)
                }
            } compactLeading: {
                Image(systemName: "timer")
            } compactTrailing: {
                Text("\(context.state.remainingTime)s")
            } minimal: {
                Text("\(context.state.remainingTime)")
            }
        }
    }
}
