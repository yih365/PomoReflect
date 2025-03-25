//
//  Note.swift
//  PomodoroReflect
//
//  Created by Yiyi Huang on 3/16/25.
//

import Foundation
import SwiftData

@Model
final class Note {
    var text: String

    init(text: String) {
        self.text = text
    }
}
