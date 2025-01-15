//
//  PomodoroReflectApp.swift
//  PomodoroReflect
//
//  Created by Yiyi Huang on 10/14/24.
//

import SwiftUI
import SwiftData

@main
struct PomodoroReflectApp: App {
//    static var notificationDelegate = NotificationDelegate()
    
    init() {
        print("init is called")
        requestNotificationPermission()
            // Set the delegate to the static instance
//        UNUserNotificationCenter.current().delegate = PomodoroReflectApp.notificationDelegate
        }
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            GeometryReader { geometry in
                VStack {
                    //            TopBar(logoName: "leaf.fill", onSettingsTapped: {
                    //                print("Settings tapped")
                    //                // Add your settings action here
                    //            })
                    TimerView().frame(width: geometry.size.width, height: geometry.size.height)
                    //            GoalWritingView()
                    //            ContentView()
                }
            }
        }
        .modelContainer(sharedModelContainer)
    }
}

//class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
//    // Foreground presentation handler (to suppress pop-up)
//    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//        // Suppress pop-up and sound in the foreground
//        completionHandler([]) // No banner, no sound, no badge
//    }
//    
//    // Background notification handling
//    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
//        // Handle background notification (e.g., open the app to a specific screen)
//        completionHandler()
//    }
//}
