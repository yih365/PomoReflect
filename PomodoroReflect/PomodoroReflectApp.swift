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
    private var timerPageSplit = CGFloat(15)
    
    init() {
        Notifs.requestNotificationPermission()
        UITabBar.appearance().backgroundColor = UIColor.systemGray6
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
            startViewHeight = geometry.size.height/2
        case ViewMode.FullPage:
            startViewHeight = 0
        }
        
        var viewHeight = startViewHeight + timerViewHeightOffset
        viewHeight = min(viewHeight, maxHeight)
        viewHeight = max(viewHeight, 0)
        return viewHeight
    }
    
    func getGoalViewHeight(geometry: GeometryProxy) -> CGFloat {
        var viewHeight = CGFloat(0)
        let maxHeight = geometry.size.height
        switch (mode) {
        case ViewMode.FullTimer:
            viewHeight = 0
        case ViewMode.HalfTimer:
            viewHeight = geometry.size.height/2
        case ViewMode.FullPage:
            viewHeight = maxHeight
        }
        
        viewHeight -= timerViewHeightOffset
        viewHeight = max(viewHeight, 0)
        viewHeight = min(viewHeight, maxHeight)
        return viewHeight
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
                    if (mode != ViewMode.FullPage || timerViewNotNone()) {
                        TimerView(viewMode: $mode).frame(width: geometry.size.width, height: getTimerViewHeight(geometry: geometry))
                    }
                    
                    // Draggable Hint
                    VStack{
                            Capsule()
                                .fill(Color.gray.opacity(0.6))
                                .frame(width: 40, height: 5)
                                .padding(.top, 10)
                            .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .named("screen"))
                                .onChanged { value in
                                    timerViewHeightOffset = value.translation.height
                                }
                                .onEnded({ value in
                                    let predictedEnd = value.predictedEndLocation.y + timerViewHeightOffset
                                    let screenHeight = UIScreen.main.bounds.height
                                    if (predictedEnd < screenHeight*1/4) {
                                        mode = ViewMode.FullPage
                                    } else if (predictedEnd < screenHeight*2/3) {
                                        mode = ViewMode.HalfTimer
                                    } else {
                                        mode = ViewMode.FullTimer
                                    }
                                    timerViewHeightOffset = 0
                                }))
                        
                        if (mode != .FullTimer || pageViewNotNone()) {
                            TabView{
                                ScrollView {
                                    GoalWritingView()
                                }
                                .tabItem {
                                    Label("Goal", systemImage: "target") // 🎯 Icon for Goal Page
                                }
                                
                                ScrollView {
                                    FocusStatsView()
                                }
                                .tabItem {
                                    Label("Focus Levels", systemImage: "chart.bar.fill") // 📊 Icon for Focus Levels Page
                                }
                                
                                ScrollView {
                                    BreakExercisesView()
                                }
                                .tabItem {
                                    Label("Break Exercises", systemImage: "figure.mind.and.body") // 🧘
                                }
                            }
                            .frame(height: getGoalViewHeight(geometry: geometry))
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
