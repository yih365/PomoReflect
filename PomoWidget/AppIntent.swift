//
//  AppIntent.swift
//  PomoWidget
//
//  Created by Yiyi Huang on 2/19/25.
//

import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Configuration" }
    static var description: IntentDescription { "This is the Pomo widget." }

    // An example configurable parameter.
    @Parameter(title: "Start Focus Time", default: "25:00")
    var focusTime: String
}
