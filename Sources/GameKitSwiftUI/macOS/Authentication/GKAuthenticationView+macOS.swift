///
/// MIT License
///
/// Copyright (c) 2021 Sascha Müllner
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in all
/// copies or substantial portions of the Software.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
/// SOFTWARE.
///
/// Created by Sascha Müllner on 28.03.21.
/// Modified by Appracatappra, LLC on 2026/09/03

#if os(macOS)
import Foundation
import GameKit
import SwiftUI

/// GameKit Authentication View.
public struct GKAuthenticationView: NSViewControllerRepresentable {

    // MARK: - Properties
    /// If `true` show the loading indicator, else hide it.
    private let showLoading: Bool
    
    /// Failed authentication handler.
    private let failed: ((Error) -> Void)
    
    /// Successful authentication handler.
    private let authenticated: ((GKPlayer) -> Void)

    // MARK: - Initializers
    /// Creates a new instance.
    /// - Parameters:
    ///   - failed: Handle authentication failing.
    ///   - authenticated: Handle authentication succeeding.
    public init(failed: @escaping ((Error) -> Void),
                authenticated: @escaping ((GKPlayer) -> Void)) {
        self.showLoading = true
        self.failed = failed
        self.authenticated = authenticated
    }
    
    /// Creates a new instance.
    /// - Parameters:
    ///   - showLoading: If `true` show loading.
    ///   - failed: Handle authentication failing.
    ///   - authenticated: Handle authentication succeeding.
    public init(showLoading: Bool, failed: @escaping ((Error) -> Void),
                authenticated: @escaping ((GKPlayer) -> Void)) {
        self.showLoading = showLoading
        self.failed = failed
        self.authenticated = authenticated
    }
    
    /// Creates a new instance.
    /// - Parameters:
    ///   - showLoading: If `true` show loading.
    ///   - backgroundColor: The loading indicator background color.
    ///   - failed: Handle authentication failing.
    ///   - authenticated: Handle authentication succeeding.
    public init(showLoading: Bool, backgroundColor:NSColor, failed: @escaping ((Error) -> Void),
                authenticated: @escaping ((GKPlayer) -> Void)) {
        
        self.showLoading = showLoading
        LoadingViewController.spinnerBackgroundColor = backgroundColor
        
        self.failed = failed
        self.authenticated = authenticated
    }
    
    /// Creates a new instance.
    /// - Parameters:
    ///   - showLoading: If `true` show loading.
    ///   - spinnerStyle: Sets the loading indicator size.
    ///   - spinnerColor: Sets the loading indicator color.
    ///   - backgroundColor: The loading indicator background color.
    ///   - failed: Handle authentication failing.
    ///   - authenticated: Handle authentication succeeding.
    public init(showLoading: Bool, spinnerStyle: UIActivityIndicatorView.Style, spinnerColor: NSColor, backgroundColor:NSColor, failed: @escaping ((Error) -> Void),
                authenticated: @escaping ((GKPlayer) -> Void)) {
        
        self.showLoading = showLoading
        LoadingViewController.spinnerStyle = spinnerStyle
        LoadingViewController.spinnerColor = spinnerColor
        LoadingViewController.spinnerBackgroundColor = backgroundColor
        
        self.failed = failed
        self.authenticated = authenticated
    }

    // MARK: - Functions
    /// Creates the NSView's controller.
    /// - Parameter context: The view to build the controller for.
    /// - Returns: Returns the new View Controller.
    public func makeNSViewController(
        context: NSViewControllerRepresentableContext<GKAuthenticationView>) -> GKAuthenticationViewController {
        let authenticationViewController = GKAuthenticationViewController(showLoading: showLoading)
        { (failed) in
            self.failed(failed)
        } authenticated: { (player) in
            self.authenticated(player)
        }
            
        return authenticationViewController
    }

    /// Updates the view controller.
    /// - Parameters:
    ///   - nsViewController: The view controller.
    ///   - context: The view context.
    public func updateNSViewController(
        _ nsViewController: GKAuthenticationViewController,
        context: NSViewControllerRepresentableContext<GKAuthenticationView>) {
    }
}

#endif
