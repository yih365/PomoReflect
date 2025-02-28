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
    
    init() {
        requestNotificationPermission()
    }
    
//    var sharedModelContainer: ModelContainer = {
//        let schema = Schema([
//            Item.self,
//        ])
//        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
//
//        do {
//            return try ModelContainer(for: schema, configurations: [modelConfiguration])
//        } catch {
//            fatalError("Could not create ModelContainer: \(error)")
//        }
//    }()
    
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
//        .modelContainer(sharedModelContainer)
    }
}
