//
//  GlassExtension.swift
//  The Spy
//
//  Created by Julian Schumacher on 05.07.26.
//  Copyright © 2026 Julian Schumacher. All rights reserved. 
//

import SwiftUI

/// A version-agnostic description of a Liquid Glass configuration.
///
/// The system `Glass` type is only available on iOS 26 and later, so it can't
/// be used as a parameter type in code that also compiles for earlier versions.
/// `CustomGlass` mirrors the parts of the `Glass` API we care about (variant,
/// tint, interactivity) and is only converted into a real `Glass` inside an
/// availability check.
internal struct CustomGlass {

    /// The base variant of the glass material.
    internal enum Variant {
        case regular
        case clear
    }

    private var variant: Variant
    private var tintColor: Color?
    private var isInteractive: Bool

    private init(
        variant: Variant,
        tintColor: Color? = nil,
        isInteractive: Bool = false
    ) {
        self.variant = variant
        self.tintColor = tintColor
        self.isInteractive = isInteractive
    }

    /// The regular variant of the Liquid Glass material.
    internal static let regular = CustomGlass(variant: .regular)

    /// The clear variant of the Liquid Glass material.
    internal static let clear = CustomGlass(variant: .clear)

    /// Returns a copy tinted with the given color.
    internal func tint(_ color: Color?) -> CustomGlass {
        var copy = self
        copy.tintColor = color
        return copy
    }

    /// Returns a copy configured to react to touch and pointer interactions.
    internal func interactive(_ isEnabled: Bool = true) -> CustomGlass {
        var copy = self
        copy.isInteractive = isEnabled
        return copy
    }

    /// Resolves this configuration into a system `Glass` value.
    @available(iOS 26, *)
    internal func resolved() -> Glass {
        var glass: Glass = variant == .clear ? .clear : .regular
        if let tintColor {
            glass = glass.tint(tintColor)
        }
        if isInteractive {
            glass = glass.interactive()
        }
        return glass
    }
}

extension View {
    /// Applies a Liquid Glass effect on iOS 26 and later, falling back to a
    /// material background on earlier versions.
    ///
    /// - Parameters:
    ///   - glass: The glass configuration to apply. Configure it with the same
    ///     fluent style as the system API, e.g. `.regular.tint(.orange).interactive()`.
    ///   - shape: The shape used to clip the effect.
    @ViewBuilder
    func glass(
        _ glass: CustomGlass = .regular,
        in shape: some Shape = RoundedRectangle(cornerRadius: 20)
    ) -> some View {
        if #available(iOS 26, *) {
            self.glassEffect(glass.resolved(), in: shape)
        } else {
            self.background(.ultraThinMaterial, in: shape)
        }
    }
}
