//
//  SourceLogo.swift
//  Snitch
//
//  Created by BOniani on 15/11/2026.
//

import SwiftUI

/// An analytics SDK's logo. Single-color template logos take `tint`; others keep their colors.
struct SourceLogo: View {
    let image: UIImage
    let tint: Color

    var body: some View {
        Image(uiImage: image)
            .renderingMode(image.renderingMode == .alwaysTemplate ? .template : .original)
            .resizable()
            .scaledToFit()
            .foregroundStyle(tint)
            .accessibilityHidden(true)
    }
}
