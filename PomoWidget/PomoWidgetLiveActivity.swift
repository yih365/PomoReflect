//
//  PomoWidgetLiveActivity.swift
//  PomoWidget
//
//  Created by Yiyi Huang on 2/19/25.
//

import WidgetKit
import SwiftUI
import ActivityKit
import AppIntents

struct PomoWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TimerActivityAttributes.self) { context in
            HStack {
                Image(systemName:"app.fill") // Make sure this image is in Assets.xcassets
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                VStack {
                    Text(context.attributes.timerType)
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    if (context.state.timerRunning) {
                        Text(timerInterval: Date.now...context.state.endTime, countsDown: true)
                            .font(.title)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } else {
                        Text("\(getMins(from: context.state.remainingTime)):\(getSecs(from: context.state.remainingTime))")
                            .font(.title)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                Spacer()
                
                // Play/Pause Button
                Button(intent: PomoLiveIntent(timerRunning: context.state.timerRunning)) {
                    Image(systemName: context.state.timerRunning ? "pause.fill" : "play.fill")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .clipShape(Circle())
                }
            }
            .padding()
            .activityBackgroundTint(Themes.shared.colorsDict[context.attributes.timerType])
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Text(context.attributes.timerType)
                }
                DynamicIslandExpandedRegion(.trailing) {
//                    Text("\(getMin(from:context.state.remainingTime)):\(getSecs(from:context.state.remainingTime))")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Tap to open app")
                        .font(.caption)
                }
            } compactLeading: {
                Image(systemName: "timer")
            } compactTrailing: {
            } minimal: {
//                Text("\(getMin(from:context.state.remainingTime)):\(getSecs(from:context.state.remainingTime))")
            }
        }
    }
}

#Preview("Notification", as: .content, using: TimerActivityAttributes.preview) {
    PomoWidgetLiveActivity()
} contentStates: {
    TimerActivityAttributes.ContentState.zero
}
