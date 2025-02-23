//
//  PomoWidgetAttributes.swift
//  PomodoroReflect
//
//  Created by Yiyi Huang on 2/19/25.
//

import ActivityKit
import WidgetKit
import SwiftUI


public struct PomoWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

extension PomoWidgetAttributes {
    static var preview: PomoWidgetAttributes {
        PomoWidgetAttributes(name: "World")
    }
}

extension PomoWidgetAttributes.ContentState {
    static var smiley: PomoWidgetAttributes.ContentState {
        PomoWidgetAttributes.ContentState(emoji: "😀")
     }
     
     static var starEyes: PomoWidgetAttributes.ContentState {
         PomoWidgetAttributes.ContentState(emoji: "🤩")
     }
}
