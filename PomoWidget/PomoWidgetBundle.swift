//
//  PomoWidgetBundle.swift
//  PomoWidget
//
//  Created by Yiyi Huang on 2/19/25.
//

import WidgetKit
import SwiftUI

@main
struct PomoWidgetBundle: WidgetBundle {
    var body: some Widget {
        PomoWidget()
        PomoWidgetControl()
        PomoWidgetLiveActivity()
    }
}
