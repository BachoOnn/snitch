//
//  EventFormatting.swift
//  Snitch
//
//  Created by BOniani on 15/11/2026.
//

import Foundation

extension AnalyticsEvent {
    var displayTime: String {
        TimeText.string(from: date)
    }

    /// The detail, else the property names such as `product_id · price`, else the user.
    var subtitle: String {
        if let detail, !detail.isEmpty { return detail }
        if !propertyNames.isEmpty { return propertyNames.joined(separator: " · ") }
        return userID ?? "No properties"
    }

    func matches(_ search: String) -> Bool {
        let needle = search.trimmingCharacters(in: .whitespaces)
        guard !needle.isEmpty else { return true }
        return [name, userID ?? "", String(decoding: properties, as: UTF8.self)]
            .contains { $0.range(of: needle, options: .caseInsensitive) != nil }
    }

    /// The whole event as pretty-printed JSON, for copying.
    var copyText: String {
        let all = JSONProperties.decode(properties)
            .merging(JSONProperties.decode(sdkPropertiesJSON)) { own, _ in own }
        var object: [String: Any] = [
            "event": name,
            "timestamp": JSONProperties.timestamp(date),
            "properties": all,
        ]
        if let userID { object["user"] = userID }
        let data = try? JSONSerialization.data(
            withJSONObject: object,
            options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        )
        return data.map { String(decoding: $0, as: UTF8.self) } ?? name
    }
}
