//
//  Set+Toggle.swift
//  Snitch
//
//  Created by BOniani on 13/11/2026.
//

extension Set {
    mutating func toggle(_ member: Element) {
        if remove(member) == nil {
            insert(member)
        }
    }
}
