//
//  Notifications.swift
//  PomodoroReflect
//
//  Created by Yiyi Huang on 1/12/25.
//

import UserNotifications

func scheduleCountdownNotifications(timerDuration: Int) {
    let notificationCenter = UNUserNotificationCenter.current()
    
    // Remove all delivered notifications
// UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    
    let content = UNMutableNotificationContent()
    content.title = "Pomodoro Timer"
    content.body = "Time remaining: \(formatTime(seconds: timerDuration))"
    content.sound = .none
    content.categoryIdentifier = "noBannerCategory"
   
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(0.1), repeats: false)
    let request = UNNotificationRequest(identifier: "PomodoroTimer_pomo", content: content, trigger: trigger)
    
    notificationCenter.add(request) { error in
        if let error = error {
            print("Error scheduling notification: \(error.localizedDescription)")
        }
    }
}

func scheduleTimerEndNotifications() {
    let notificationCenter = UNUserNotificationCenter.current()
    
    // Remove all delivered notifications
    UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    
    let content = UNMutableNotificationContent()
    content.title = "Pomodoro Timer"
    content.body = "Timer Ended!"
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

func formatTime(seconds: Int) -> String {
    let minutes = seconds / 60
    let seconds = seconds % 60
    return String(format: "%02d:%02d", minutes, seconds)
}

func requestNotificationPermission() {
    print("requesting notification permission")
    UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .provisional]) { granted, error in
        if let error = error {
            print("Error requesting notification permission: \(error.localizedDescription)")
        } else if granted {
            print("Notification permission granted")
        } else {
            print("Notification permission denied")
        }
        
//        if granted {
//                        // Register notification categories
//                        let noBannerCategory = UNNotificationCategory(identifier: "noBannerCategory", actions: [], intentIdentifiers: [], options: [])
//                        UNUserNotificationCenter.current().setNotificationCategories([noBannerCategory])
//                    }
    }
}
