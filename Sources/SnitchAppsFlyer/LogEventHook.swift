//
//  LogEventHook.swift
//  SnitchAppsFlyer
//
//  Created by BOniani on 17/11/2026.
//

import Foundation
import ObjectiveC

/// Wraps AppsFlyer's two public `logEvent` methods so each call is reported first, then runs
/// exactly as before.
///
/// Both methods hand the event straight to the same internal method, and neither calls the
/// other, so wrapping both reports each event once. Only the public methods are wrapped,
/// because their names and arguments are AppsFlyer's documented API.
enum LogEventHook {
    typealias Report = (_ sdk: AnyObject, _ name: String, _ values: [AnyHashable: Any]?) -> Void

    static let logEvent = NSSelectorFromString("logEvent:withValues:")
    static let logEventWithCompletion = NSSelectorFromString("logEventWithEventName:eventValues:completionHandler:")

    /// Wraps the methods `type` has and returns how many it wrapped. A method that is missing,
    /// or whose arguments aren't the expected objects, is left alone. Call once per class.
    @discardableResult
    static func install(in type: AnyClass, report: @escaping Report) -> Int {
        var wrapped = 0

        if let method = method(logEvent, in: type, argumentTypes: ["@", "@"]) {
            typealias Original = @convention(c) (AnyObject, Selector, NSString?, NSDictionary?) -> Void
            let original = unsafeBitCast(method_getImplementation(method), to: Original.self)
            let replacement: @convention(block) (AnyObject, NSString?, NSDictionary?) -> Void = { sdk, name, values in
                if let name { report(sdk, name as String, values as? [AnyHashable: Any]) }
                original(sdk, logEvent, name, values)
            }
            method_setImplementation(method, imp_implementationWithBlock(replacement))
            wrapped += 1
        }

        if let method = method(logEventWithCompletion, in: type, argumentTypes: ["@", "@", "@?"]) {
            typealias Original = @convention(c) (AnyObject, Selector, NSString?, NSDictionary?, AnyObject?) -> Void
            let original = unsafeBitCast(method_getImplementation(method), to: Original.self)
            let replacement: @convention(block) (AnyObject, NSString?, NSDictionary?, AnyObject?) -> Void = { sdk, name, values, completion in
                if let name { report(sdk, name as String, values as? [AnyHashable: Any]) }
                original(sdk, logEventWithCompletion, name, values, completion)
            }
            method_setImplementation(method, imp_implementationWithBlock(replacement))
            wrapped += 1
        }

        return wrapped
    }

    /// The instance method, if its arguments after `self` and `_cmd` have exactly these
    /// Objective-C type encodings.
    static func method(_ selector: Selector, in type: AnyClass, argumentTypes: [String]) -> Method? {
        guard let method = class_getInstanceMethod(type, selector),
              Int(method_getNumberOfArguments(method)) == argumentTypes.count + 2
        else { return nil }
        for (offset, expected) in argumentTypes.enumerated() {
            guard let encoding = method_copyArgumentType(method, UInt32(offset + 2)) else { return nil }
            defer { free(encoding) }
            guard String(cString: encoding) == expected else { return nil }
        }
        return method
    }
}
