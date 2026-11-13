//
//  EntryFilter.swift
//  Snitch
//
//  Created by BOniani on 05/11/2026.
//

import Foundation

struct EntryFilter: Equatable {
    enum StatusClass: Int, CaseIterable, Hashable {
        case success = 2, redirect, clientError, serverError

        var label: String { "\(rawValue)00" }

        func contains(_ code: Int) -> Bool { code / 100 == rawValue }
    }

    enum Token: Hashable {
        case statusClass(StatusClass)
        case code(Int)
        case failed
        case pending
        case method(String)
        case host(String)

        var label: String {
            switch self {
            case .statusClass(let statusClass): return statusClass.label
            case .code(let code): return String(code)
            case .failed: return "Failed"
            case .pending: return "Pending"
            case .method(let method): return method
            case .host(let host): return host
            }
        }
    }

    var statusClasses: Set<StatusClass> = []
    var codes: [Int] = []
    var failed = false
    var pending = false
    var methods: Set<String> = []
    var hosts: Set<String> = []

    var isEmpty: Bool { tokens.isEmpty }

    var tokens: [Token] {
        StatusClass.allCases.filter(statusClasses.contains).map(Token.statusClass)
            + codes.map(Token.code)
            + (failed ? [.failed] : [])
            + (pending ? [.pending] : [])
            + methods.sorted().map(Token.method)
            + hosts.sorted().map(Token.host)
    }

    mutating func remove(_ token: Token) {
        switch token {
        case .statusClass(let statusClass): statusClasses.remove(statusClass)
        case .code(let code): codes.removeAll { $0 == code }
        case .failed: failed = false
        case .pending: pending = false
        case .method(let method): methods.remove(method)
        case .host(let host): hosts.remove(host)
        }
    }

    mutating func toggle(_ statusClass: StatusClass) {
        statusClasses.toggle(statusClass)
    }

    mutating func toggleMethod(_ method: String) {
        methods.toggle(method)
    }

    mutating func toggleHost(_ host: String) {
        hosts.toggle(host)
    }

    @discardableResult
    mutating func addCode(_ text: String) -> Bool {
        guard let code = Int(text.trimmingCharacters(in: .whitespaces)), (100...599).contains(code) else {
            return false
        }
        if !codes.contains(code) { codes.append(code) }
        return true
    }
}
