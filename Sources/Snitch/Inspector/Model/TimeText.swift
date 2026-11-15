//
//  TimeText.swift
//  Snitch
//
//  Created by BOniani on 15/11/2026.
//

import Foundation

enum TimeText {
    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()

    static func string(from date: Date) -> String {
        formatter.string(from: date)
    }
}
