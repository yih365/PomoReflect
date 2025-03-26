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
    @State private var mode = ViewMode.FullTimer
    @State private var timerViewHeightOffset: CGFloat = 0
    @State private var pageViewHeightOffset: CGFloat = 0
    @State private var timerViewHeight: CGFloat = 0 // Store TimerView height
    
    @AppStorage("lastOpenedTab") private var selectedTab: Int = 0

    private var timerPageSplit = CGFloat(15)
    
    init() {
        Notifs.requestNotificationPermission()
    }
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Note.self,
            FocusLevel.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    func getTimerViewHeight(geometry: GeometryProxy) -> CGFloat {
        var startViewHeight = CGFloat(0)
        let maxHeight = geometry.size.height * (timerPageSplit-1)/(timerPageSplit)
        switch (mode) {
        case ViewMode.FullTimer:
            startViewHeight = maxHeight
        case ViewMode.HalfTimer:
            startViewHeight = 200
        case ViewMode.FullPage:
            startViewHeight = 0
        }
        
        var viewHeight = startViewHeight + timerViewHeightOffset
        viewHeight = min(viewHeight, maxHeight)
        viewHeight = max(viewHeight, 0)
        return viewHeight
    }
    
    func getGoalViewHeight(geometry: GeometryProxy) -> CGFloat {
        let maxHeight = geometry.size.height
        
        return maxHeight - timerViewHeight
        
//        switch (mode) {
//        case ViewMode.FullTimer:
//            viewHeight = 0
//        case ViewMode.HalfTimer:
//            viewHeight = maxHeight - getTimerViewHeight(geometry: geometry)
//        case ViewMode.FullPage:
//            viewHeight = maxHeight
//        }
//        
//        viewHeight -= timerViewHeightOffset
//        viewHeight = max(viewHeight, 0)
//        viewHeight = min(viewHeight, maxHeight)
//        return viewHeight
    }
    
    func timerViewNotNone() -> Bool {
        return mode == ViewMode.FullPage && timerViewHeightOffset > 0
    }
    
    func pageViewNotNone() -> Bool {
        return mode == ViewMode.FullTimer && timerViewHeightOffset < 0
    }
    
    var body: some Scene {
        WindowGroup {
            GeometryReader { geometry in
                VStack {
                    // Timer
                    if (mode != ViewMode.FullPage || timerViewNotNone()) {
                        TimerView(viewMode: $mode, onHeightChange: { height in
                            timerViewHeight = height
                        })
                        .frame(width: geometry.size.width, height: getTimerViewHeight(geometry: geometry))
                    }
                    
                    // View expander toggle
                    VStack{
                            Button(action: {
                                    if (mode == ViewMode.FullTimer) {
                                        mode = ViewMode.HalfTimer
                                    } else {
                                        mode = ViewMode.FullTimer
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: mode == ViewMode.HalfTimer ? "chevron.down" : "chevron.up")
                                            .foregroundColor(.black)
                                    }
                                    .frame(width: 200, height: 30)
                                        .background(
                                            Capsule()
                                                .fill(Color.white)
                                                .overlay(
                                                    Capsule()
                                                        .stroke(Color.black, lineWidth: 0.5)
                                                )
                                        )
                                }
                        
                        // Page view
                        if (mode != .FullTimer || pageViewNotNone()) {
                            TabView(selection: $selectedTab) {
                                ScrollView {
                                    GoalWritingView()
                                }
                                .tabItem {
                                    Label("Goal", systemImage: "target") // 🎯
                                }
                                .tag(0)
                                
                                ScrollView {
                                    FocusStatsView()
                                }
                                .tabItem {
                                    Label("Focus Levels", systemImage: "chart.bar.fill") // 📊
                                }
                                .tag(1)

                                ScrollView {
                                    BreakExercisesView()
                                }
                                .tabItem {
                                    Label("Break Exercises", systemImage: "figure.mind.and.body") // 🧘
                                }
                                .tag(2)
                            }
                            .frame(height: getGoalViewHeight(geometry: geometry))
                            .toolbarBackground(Color.pagePigment, for: .tabBar)
                        } else {
                            Rectangle()
                                .fill(Color.pagePigment)
                                .frame(width: 300, height: geometry.size.height/timerPageSplit)
                        }
                    }
                    .modelContainer(sharedModelContainer)
                    .background(Color.pagePigment)
                    .clipShape(RoundedCornersShape(radius: 20, corners: [.topLeft, .topRight]))
                    .shadow(radius: 5)
                }
                .background(TimerView.backgroundColor())
                .coordinateSpace(name: "screen")
            }
        }
    }
}

struct RoundedCornersShape: Shape {
    var radius: CGFloat
    var corners: UIRectCorner

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
