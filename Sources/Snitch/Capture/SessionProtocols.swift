import Foundation
import ObjectiveC

/// Gives each configuration passed to `Snitch.install(in:)` its own protocol class, so
/// its requests are re-sent through a session with the same settings: the same cookie
/// store and cookie rules, cache, credentials, network policies and other protocol
/// classes. Without this, re-sent requests would use default settings, and cookies
/// would land in the shared store instead of the app's own.
///
/// URLSession doesn't tell a protocol which session a request came from, but it does
/// create the protocol from the configuration's own class list. A subclass made for one
/// configuration therefore knows its settings.
enum SessionProtocols {
    /// Past this many configurations, new ones share the plain class and default
    /// settings, so an app that builds a session for every request can't grow without end.
    static let limit = 64

    private static let lock = NSLock()
    private static var configurations: [ObjectIdentifier: URLSessionConfiguration] = [:]
    private static var forwarders: [ObjectIdentifier: Forwarder] = [:]

    /// A new protocol class tied to a copy of `configuration`, or the plain class if
    /// no more can be made.
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

    /// The forwarder for requests created by `protocolClass`, built on first use from
    /// the configuration as it is then, so settings changed after `install(in:)` count.
    /// `nil` for the plain class.
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

    /// A copy of `configuration` without Snitch's own classes, which would only
    /// decline the marked requests anyway.
    static func forwardingCopy(of configuration: URLSessionConfiguration) -> URLSessionConfiguration {
        let copy = configuration.copy() as! URLSessionConfiguration
        copy.protocolClasses = copy.protocolClasses?.filter { !($0 is SnitchURLProtocol.Type) }
        return copy
    }
}
