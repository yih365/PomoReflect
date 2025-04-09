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
//    @State private var mode = ViewMode.FullTimer
    @State private var timerViewHeightOffset: CGFloat = 0
    @State private var pageViewHeightOffset: CGFloat = 0
    @State private var timerViewHeight: CGFloat = 0 // Store TimerView height
    
    // Managers
    @State private var popupManager = PopupManager.shared
    @State private var tabStates = TabStates.shared

    private var timerPageSplit = CGFloat(15)
    
    init() {
        Notifs.requestNotificationPermission()
        UserDefaults.standard.register(defaults: ["autoStartBreaks" : true,
                                                  "showFocusOnFocusEnd": true,
                                                 ])
        
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()  // Ensures full color coverage
        appearance.backgroundColor = UIColor(Color.pagePigment) // Set tab bar background color

        // Customize unselected tab color
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.gray
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.gray]

        // Customize selected tab color
//        appearance.stackedLayoutAppearance.selected.iconColor = UIColor.red
//        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.red]

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
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
        switch (tabStates.mode) {
        case ViewMode.FullTimer:
            startViewHeight = maxHeight
        case ViewMode.HalfTimer:
            // Reduced height for HalfTimer mode
            startViewHeight = 150
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
    }
    
    func timerViewNotNone() -> Bool {
        return tabStates.mode == ViewMode.FullPage && timerViewHeightOffset > 0
    }
    
    func pageViewNotNone() -> Bool {
        return tabStates.mode == ViewMode.FullTimer && timerViewHeightOffset < 0
    }
    
    var body: some Scene {
        WindowGroup {
            GeometryReader { geometry in
                ZStack{
                    VStack {
                        // Timer
                        if (tabStates.mode != ViewMode.FullPage || timerViewNotNone()) {
                            TimerView(viewMode: $tabStates.mode, onHeightChange: { height in
                                timerViewHeight = height
                            })
                            .frame(width: geometry.size.width, height: getTimerViewHeight(geometry: geometry))
                        }
                        
                        // View expander toggle
                        VStack{
                            Button(action: {
                                if (tabStates.mode == ViewMode.FullTimer) {
                                    tabStates.mode = ViewMode.HalfTimer
                                } else {
                                    tabStates.mode = ViewMode.FullTimer
                                }
                                print(tabStates.mode)
                            }) {
                                HStack {
                                    Image(systemName: tabStates.mode == ViewMode.HalfTimer ? "chevron.down" : "chevron.up")
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
                            .padding(.top, 10)
                            
                            // Page view
                            if (tabStates.mode != .FullTimer || pageViewNotNone()) {
                                TabView(selection: $tabStates.selectedTab) {
                                    ScrollView {
                                        GoalWritingView()
                                    }
                                    .tabItem {
                                        Label("Goal", systemImage: "target") // 🎯
                                    }
                                    .tag(0)
                                    .background(Color.pagePigment)
                                    
                                    ScrollView {
                                        FocusStatsView()
                                    }
                                    .tabItem {
                                        Label("Focus Levels", systemImage: "chart.bar.fill") // 📊
                                    }
                                    .tag(1)
                                    .background(Color.pagePigment)
                                    
                                    ScrollView {
                                        BreakExercisesView()
                                    }
                                    .tabItem {
                                        Label("Break Exercises", systemImage: "figure.mind.and.body") // 🧘
                                    }
                                    .tag(2)
                                    .background(Color.pagePigment)
                                }
                                .frame(height: getGoalViewHeight(geometry: geometry))
                                .toolbarBackground(Color.pagePigment, for: .tabBar)
                                .tint(Color(.darkGray))
                                .background(Color.pagePigment)
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
                    
                    if (popupManager.isPopupVisible) {
                        VStack {
                            FocusLogView()
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("1 - Could barely focus on the task")
                                Text("3 - Mostly focused but with some distracting thoughts")
                                Text("5 - Little to no distracting thoughts")
                            }
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.top, 8)
                        }
                        .modelContainer(sharedModelContainer)
                        .frame(width: 300)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(radius: 10)
                        .transition(.scale)
                    }
                }
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
