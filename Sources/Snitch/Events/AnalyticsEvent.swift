//
//  AnalyticsEvent.swift
//  Snitch
//
//  Created by BOniani on 15/11/2026.
//

import Foundation

/// One analytics event, as an analytics SDK was about to send it.
///
/// Adapters such as `SnitchPostHog` create these and pass them to ``Snitch/record(_:)``.
/// Properties are stored as JSON, so values that JSON can't hold, such as dates and URLs,
/// are kept as text.
public struct AnalyticsEvent: Identifiable, Equatable, Sendable {
    /// A unique identifier for this event.
    public let id: UUID
    /// The SDK that sent the event, such as `PostHog`. Each source gets its own screen.
    public let source: String
    /// The event name.
    public let name: String
    /// The user the event belongs to, if the SDK knows one.
    public let userID: String?
    /// When the event was captured.
    public let date: Date
    /// Whether the SDK created the event on its own, such as a screen view or app launch.
    public let isAutomatic: Bool
    /// A short note shown under the name instead of the property names, such as a screen name.
    public let detail: String?

    let properties: Data
    let propertyNames: [String]
    let sdkProperties: [String: String]
    let sdkPropertiesJSON: Data

    var propertyCount: Int { propertyNames.count }
    var sdkPropertyCount: Int { sdkProperties.count }

    /// Creates an event.
    ///
    /// - Parameters:
    ///   - source: The SDK that sent the event, such as `PostHog`.
    ///   - name: The event name.
    ///   - userID: The user the event belongs to, if known.
    ///   - date: When the event was captured.
    ///   - id: A unique identifier, such as the SDK's own event ID.
    ///   - isAutomatic: Whether the SDK created the event on its own.
    ///   - detail: A short note shown under the name, such as the screen of a screen view.
    ///   - properties: The properties the app set on the event.
    ///   - sdkProperties: The properties the SDK added, such as device and app details.
    public init(
        source: String,
        name: String,
        userID: String? = nil,
        date: Date = Date(),
        id: UUID = UUID(),
        isAutomatic: Bool = false,
        detail: String? = nil,
        properties: [String: Any] = [:],
        sdkProperties: [String: Any] = [:]
    ) {
        self.id = id
        self.source = source
        self.name = name
        self.userID = userID
        self.date = date
        self.isAutomatic = isAutomatic
        self.detail = detail
        self.properties = JSONProperties.encode(properties)
        self.propertyNames = properties.keys.sorted()
        self.sdkProperties = sdkProperties.mapValues(JSONProperties.text)
        self.sdkPropertiesJSON = JSONProperties.encode(sdkProperties)
    }
}

extension AnalyticsEvent: CustomStringConvertible, CustomDebugStringConvertible {
    /// The source and event name, such as `PostHog product_viewed`, without properties.
    public var description: String { "\(source) \(name)" }

    /// Same as ``description``.
    public var debugDescription: String { description }
}
