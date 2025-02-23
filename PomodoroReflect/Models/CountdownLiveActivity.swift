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
        if ActivityAuthorizationInfo().areActivitiesEnabled {
            let pomoWidgetAttributes = PomoWidgetAttributes(name: "name")
            let initialState = PomoWidgetAttributes.ContentState(
                emoji: "!"
            )
            do {
                
                let activity = try Activity.request(
                    attributes: pomoWidgetAttributes,
                    content: .init(state: initialState, staleDate: nil),
                    pushType: nil
                )
                
//                activityID = activity.id
                
                print("Live Activity started: \(activity.id)")
//            catch {
//                print("Other error: \(error.localizedDescription)")
//                print("Other error: \(error.failureReason? as String)")
//            }
            } catch let error as ActivityAuthorizationError {
            // Handle ActivityAuthorizationError specifically
                print("Failure reason: \(error.failureReason ?? " non ")")
                switch error {
                case .attributesTooLarge:
                        print("The attributes provided for the Live Activity are too large.")
                    case .unsupported:
                        print("The device does not support Live Activities.")
                    case .denied:
                        print("User has disabled Live Activities in Settings.")
                    case .globalMaximumExceeded:
                        print("The device has reached the maximum number of ongoing Live Activities.")
                    case .targetMaximumExceeded:
                        print("The app has reached the maximum number of concurrent Live Activities.")
                    case .unsupportedTarget:
                        print("The app lacks the required entitlement to start a Live Activity.")
                    case .visibility:
                        print("The app tried to start the Live Activity while it was in the background.")
                    case .persistenceFailure:
                        print("The system couldn't persist the Live Activity.")
                    case .missingProcessIdentifier:
                        print("The process that tried to start the Live Activity is missing a process identifier.")
                    case .unentitled:
                        print("The app doesn't have the required entitlement to start a Live Activity.")
                    case .malformedActivityIdentifier:
                        print("The provided activity identifier is malformed.")
                    case .reconnectNotPermitted:
                        print("The process that tried to recreate the Live Activity is different from the original.")
                    default:
                        print("An unhandled ActivityAuthorizationError occurred.")
                }
            } catch {
                // Handle other errors
                print("An unexpected error occurred: \(error.localizedDescription)")
            }
        }
//        if ActivityAuthorizationInfo().areActivitiesEnabled {
//            let attributes = TimerActivityAttributes(timerType: timerType)
//            let initialState = TimerActivityAttributes.ContentState(remainingTime: duration)
//            
//            let activityContent = ActivityContent(state: initialState, staleDate: Date().addingTimeInterval(duration))
//            
//            do {
//                let activity = try Activity<TimerActivityAttributes>.request(attributes: attributes, content: activityContent, pushType: .token)
////                self.setup(withActivity: activity)
//                print("Live Activity started: \(activity.id)")
//            } catch {
//                print("Failed to start Live Activity: \(error.localizedDescription)")
//            }
//        }
    }
    
    func updateLiveActivity(remainingTime: TimeInterval) {
        Task {
            for activity in Activity<TimerActivityAttributes>.activities {
                let newState = TimerActivityAttributes.ContentState(remainingTime: remainingTime)
                let updatedContent = ActivityContent(state: newState, staleDate: Date().addingTimeInterval(remainingTime))

                await activity.update(updatedContent)
            }
        }
    }
    
    func stopLiveActivity() {
        Task {
            for activity in Activity<TimerActivityAttributes>.activities {
                await activity.end(nil, dismissalPolicy: .immediate)
            }
        }
    }
}
