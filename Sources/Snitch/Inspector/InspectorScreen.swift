//
//  InspectorScreen.swift
//  Snitch
//
//  Created by BOniani on 15/11/2026.
//

import Foundation

enum InspectorScreen: Hashable {
    case network
    case events(String)

    @MainActor static var last: InspectorScreen = .network

    var title: String {
        switch self {
        case .network: return "Network"
        case .events(let source): return source
        }
    }

    static func available(sources: [String]) -> [InspectorScreen] {
        [.network] + sources.map(InspectorScreen.events)
    }
}

struct EventRoute: Hashable {
    let id: UUID
}
