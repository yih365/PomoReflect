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
    private var activity: Activity<TimerActivityAttributes>?

    func startLiveActivity(duration: TimeInterval, timerType: String) {
        // If an activity already exists, update it instead of creating a new one
        if let existingActivity = activity {
            updateLiveActivity(remainingTime: duration, timerType: timerType, isRunning: true)
            return
        }

        print("Start live activity")
        if ActivityAuthorizationInfo().areActivitiesEnabled {
            let attributes = TimerActivityAttributes()
            let initialState = TimerActivityAttributes.ContentState(
                endTime: Date.now.addingTimeInterval(duration),
                remainingTime: duration,
                timerRunning: true,
                timerType: timerType
            )

            do {
                let newActivity = try Activity.request(
                    attributes: attributes,
                    content: .init(state: initialState, staleDate: Date().addingTimeInterval(duration)),
                    pushType: nil
                )
                activity = newActivity
                print("Live Activity started: \(newActivity.id)")
            } catch {
                print("Failed to start Live Activity: \(error.localizedDescription)")
            }
        }
    }

    func updateLiveActivity(remainingTime: TimeInterval, timerType: String, isRunning: Bool) {
        guard let existingActivity = activity else {
            print("No active Live Activity to update")
            return
        }

        let newState = TimerActivityAttributes.ContentState(
            endTime: Date.now.addingTimeInterval(remainingTime),
            remainingTime: remainingTime,
            timerRunning: isRunning,
            timerType: timerType
        )

        Task {
            let updatedContent = ActivityContent(state: newState, staleDate: Date().addingTimeInterval(remainingTime))
            await existingActivity.update(updatedContent)
            print("Live Activity updated")
        }
    }

    func pauseLiveActivity(remainingTime: TimeInterval, timerType: String) {
        updateLiveActivity(remainingTime: remainingTime, timerType: timerType, isRunning: false)
    }

    func stopLiveActivity() {
        Task {
            if let existingActivity = activity {
                await existingActivity.end(nil, dismissalPolicy: .immediate)
                print("Stopped live activity")
                activity = nil // Clear the reference
            }
        }
    }
}
