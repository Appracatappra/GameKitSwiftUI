//
//  UIActivityIndicatorStyle.swift
//  GameKitSwiftUI
//
//  Created by Kevin Mullins on 9/3/26.
//

#if os(macOS)
/// Stub `UIActivityIndicatorView` class to support the same UI customizations as the iOS, iPadOS and tvOS versions of the controls.
public class UIActivityIndicatorView {
    
    /// Defines the stype of the `NSProgressIndicator` to display.
    public enum Style : Int, @unchecked Sendable {
        
        /// Displays a medium sized indicator.
        case medium = 100

        /// Displays a large sized indicator.
        case large = 101
    }
}
#endif
