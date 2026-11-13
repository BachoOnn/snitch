//
//  Hairline.swift
//  Snitch
//
//  Created by BOniani on 09/11/2026.
//

import SwiftUI

struct Hairline: View {
    var color: Color = Theme.divider

    var body: some View {
        Rectangle().fill(color).frame(height: Theme.Size.hairline)
    }
}
