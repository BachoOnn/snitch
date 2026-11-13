//
//  SessionProtocols.swift
//  Snitch
//
//  Created by BOniani on 11/11/2026.
//

import Foundation
import ObjectiveC

/// URLSession doesn't say which session a request came from, so each installed
/// configuration gets its own protocol subclass that re-sends with its settings.
enum SessionProtocols {
    // Caps growth in apps that build a new session for every request.
    static let limit = 64

    private static let lock = NSLock()
    private static var configurations: [ObjectIdentifier: URLSessionConfiguration] = [:]
    private static var forwarders: [ObjectIdentifier: Forwarder] = [:]

    static func makeClass(for configuration: URLSessionConfiguration) -> AnyClass {
        lock.withLock {
            guard configurations.count < limit else { return SnitchURLProtocol.self }
            let name = "SnitchURLProtocol_\(configurations.count + 1)_\(UInt32.random(in: 0...UInt32.max))"
            guard let subclass = objc_allocateClassPair(SnitchURLProtocol.self, name, 0) else {
                return SnitchURLProtocol.self
            }
            objc_registerClassPair(subclass)
            configurations[ObjectIdentifier(subclass)] = configuration
            return subclass
        }
    }

    static func forwarder(for protocolClass: AnyClass) -> Forwarder? {
        let key = ObjectIdentifier(protocolClass)
        return lock.withLock {
            if let forwarder = forwarders[key] { return forwarder }
            guard let configuration = configurations[key] else { return nil }
            let forwarder = Forwarder(configuration: forwardingCopy(of: configuration))
            forwarders[key] = forwarder
            return forwarder
        }
    }

    static func forwardingCopy(of configuration: URLSessionConfiguration) -> URLSessionConfiguration {
        let copy = configuration.copy() as! URLSessionConfiguration
        copy.protocolClasses = copy.protocolClasses?.filter { !($0 is SnitchURLProtocol.Type) }
        return copy
    }
}
