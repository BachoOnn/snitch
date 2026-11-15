//
//  JSONProperties.swift
//  Snitch
//
//  Created by BOniani on 15/11/2026.
//

import Foundation

enum JSONProperties {
    private static let options: JSONSerialization.WritingOptions = [.sortedKeys, .withoutEscapingSlashes]
    private static let dateFormatter = ISO8601DateFormatter()

    static func timestamp(_ date: Date) -> String {
        dateFormatter.string(from: date)
    }

    static func encode(_ object: [String: Any]) -> Data {
        let safe = jsonSafe(object)
        guard JSONSerialization.isValidJSONObject(safe),
              let data = try? JSONSerialization.data(withJSONObject: safe, options: options)
        else { return Data("{}".utf8) }
        return data
    }

    static func decode(_ data: Data) -> [String: Any] {
        (try? JSONSerialization.jsonObject(with: data)) as? [String: Any] ?? [:]
    }

    /// A value as display text: strings as they are, anything else as compact JSON.
    static func text(_ value: Any) -> String {
        let safe = jsonSafe(value)
        if let string = safe as? String { return string }
        guard let data = try? JSONSerialization.data(withJSONObject: safe, options: options.union(.fragmentsAllowed))
        else { return String(describing: safe) }
        return String(decoding: data, as: UTF8.self)
    }

    static func jsonSafe(_ value: Any) -> Any {
        let mirror = Mirror(reflecting: value)
        if mirror.displayStyle == .optional {
            guard let wrapped = mirror.children.first?.value else { return NSNull() }
            return jsonSafe(wrapped)
        }
        switch value {
        case is NSNull, is String:
            return value
        case let number as NSNumber:
            let double = number.doubleValue
            return double.isFinite ? number : "\(double)"
        case let dictionary as [String: Any]:
            return dictionary.mapValues(jsonSafe)
        case let dictionary as [AnyHashable: Any]:
            return Dictionary(dictionary.map { ("\($0.key)", jsonSafe($0.value)) }) { first, _ in first }
        case let array as [Any]:
            return array.map(jsonSafe)
        case let date as Date:
            return timestamp(date)
        case let url as URL:
            return url.absoluteString
        case let uuid as UUID:
            return uuid.uuidString
        case let data as Data:
            return "<\(data.count) bytes>"
        default:
            return String(describing: value)
        }
    }
}
