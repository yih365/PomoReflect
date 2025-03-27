//
//  TimerSettingsView.swift
//  PomodoroReflect
//
//  Created by Yiyi Huang on 1/9/25.
//


import SwiftUI
import WidgetKit

struct TimerSettingsView: View {
    @Binding var tabs: [(String,Int)] // Binding to pass and update default timers
    @Binding var autoStartBreaks: Bool
    @Binding var selectedBackgroundNoise: String
    @State private var focusTime = ""
    @State private var shortBreakTime = ""
    @State private var longBreakTime = ""
    @Environment(\.dismiss) var dismiss
    var onSave: ((Bool) -> Void)? // Closure to handle save action
    
    
    init(tabs: Binding<[(String, Int)]>, autoStartBreaks: Binding<Bool>, selectedBackgroundNoise: Binding<String>, onSave: ((Bool) -> Void)? = nil) {
        self._tabs = tabs
        self._autoStartBreaks = autoStartBreaks
        self._selectedBackgroundNoise = selectedBackgroundNoise
        // Initialize state variables with formatted timer durations
        self._focusTime = State(initialValue: "\(tabs.wrappedValue[0].1 / 60)")
        self._shortBreakTime = State(initialValue: "\(tabs.wrappedValue[1].1 / 60)")
        self._longBreakTime = State(initialValue: "\(tabs.wrappedValue[2].1 / 60)")
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Set Timer Durations (Minutes)")) {
                    HStack {
                        Text(tabs[0].0)
                        TextField(tabs[0].0, text: $focusTime)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text(tabs[1].0)
                        TextField(tabs[1].0, text: $shortBreakTime)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text(tabs[2].0)
                        TextField(tabs[2].0, text: $longBreakTime)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                Toggle("Auto Start Breaks and Focus", isOn: $autoStartBreaks)
                                .padding()
                
                Picker("Background Noise", selection: $selectedBackgroundNoise) {
                    ForEach(AudioManager.backgroundNoiseOptions, id: \.self) { noise in
                        Text(noise).tag(noise)
                    }
                }
                .pickerStyle(MenuPickerStyle()) // Dropdown style
            }
            .navigationBarTitle("Settings", displayMode: .inline)
            .navigationBarItems(trailing: Button("Save") {
                let oldFocus = tabs[0].1
                let oldShortTimer = tabs[1].1
                let oldLongTimer = tabs[2].1
                
                // Save the user inputs to default timers
                tabs[0].1 = Int(focusTime) != nil ? Int(focusTime)!*60 : tabs[0].1
                tabs[1].1 = Int(shortBreakTime) != nil ? Int(shortBreakTime)!*60 : tabs[1].1
                tabs[2].1 = Int(longBreakTime) != nil ? Int(longBreakTime)!*60 : tabs[2].1
                
                // If any timer duration is changed, set as parameter in save function
                // so that save function can reset the timer
                onSave?(oldFocus != tabs[0].1 || oldShortTimer != tabs[1].1 || oldLongTimer != tabs[2].1)

                // Save to UserDefaults
                if (oldFocus != tabs[0].1) {
                    UserDefaults.standard.set(tabs[0].1, forKey: tabs[0].0)
                }
                if (oldShortTimer != tabs[1].1) {
                    UserDefaults.standard.set(tabs[1].1, forKey: tabs[1].0)
                }
                if (oldLongTimer != tabs[2].1) {
                    UserDefaults.standard.set(tabs[2].1, forKey: tabs[2].0)
                }
                
                // Save to UserDefaults
                UserDefaults.standard.set(autoStartBreaks, forKey: "autoStartBreaks")
                UserDefaults.standard.set(selectedBackgroundNoise, forKey: "BGNoise")
                
                // Reload widget
                WidgetCenter.shared.reloadAllTimelines()
                
                dismiss()
            })
        }
    }
}
