//
//  Notifications.swift
//  PomodoroReflect
//
//  Created by Yiyi Huang on 1/12/25.
//

import UserNotifications

class Notifs {
    static func scheduleTimerEndNotifications() {
        let notificationCenter = UNUserNotificationCenter.current()
        
        // Remove all delivered notifications
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        
        let content = UNMutableNotificationContent()
        content.title = "Pomodoro Timer"
        content.body = "Timer Ended! Log your focus level!"
        content.sound = .none
        content.categoryIdentifier = "bannerCategory"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(0.1), repeats: false)
        let request = UNNotificationRequest(identifier: "PomodoroTimer_pomo_alert", content: content, trigger: trigger)
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
    
    static func requestNotificationPermission() {
        print("requesting notification permission")
        UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .provisional]) { granted, error in
            if let error = error {
                print("Error requesting notification permission: \(error.localizedDescription)")
            } else if granted {
                print("Notification permission granted")
            } else {
                print("Notification permission denied")
            }
        }
    }
}
