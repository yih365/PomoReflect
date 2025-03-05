//
//  CountdownLiveActivity.swift
//  PomodoroReflect
//
//  Created by Yiyi Huang on 2/12/25.
//

import ActivityKit
import Foundation

final class CountdownLiveActivity {
    static let shared = CountdownLiveActivity()
    private var activityID: String?

    func startLiveActivity(duration: TimeInterval, timerType: String) {
        stopLiveActivity()
        
        if ActivityAuthorizationInfo().areActivitiesEnabled {
            let pomoWidgetAttributes = TimerActivityAttributes(timerType: timerType)
            let initialState = TimerActivityAttributes.ContentState(endTime: Date.now.addingTimeInterval(duration), remainingTime: duration, timerRunning: true)
            
            do {
                let activity = try Activity.request(
                    attributes: pomoWidgetAttributes,
                    content: .init(state: initialState, staleDate: Date().addingTimeInterval(duration)),
                    pushType: nil
                )
                activityID = activity.id
                
                print("Live Activity started: \(activity.id)")
            } catch {
                // Handle other errors
                print("An unexpected error occurred: \(error.localizedDescription)")
            }
        }
    }
    
    func pauseLiveActivity(remainingTime: TimeInterval) {
        Task {
            // Pause the timer by updating the content
            let newState = TimerActivityAttributes.ContentState(endTime: Date.now.addingTimeInterval(remainingTime), remainingTime: remainingTime, timerRunning: false)
            let activity = Activity<TimerActivityAttributes>.activities.first(where: {$0.id == activityID})
            let updatedContent = ActivityContent(state: newState, staleDate: Date().addingTimeInterval(remainingTime))
            await activity?.update(updatedContent)
        }
    }
    
    func stopLiveActivity() {
        Task {
            await Activity<TimerActivityAttributes>.activities.first(where: { $0.id == activityID })?.end(nil, dismissalPolicy: .immediate)
        }
    }
}
