///
/// MIT License
///
/// Copyright (c) 2020 Henrik Storch
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
/// Created by Henrik Storch on 02.10.21.
/// Modified by Appracatappra, LLC on 2026/09/03

#if os(macOS)
import Foundation
import GameKit
import SwiftUI

/// Game Center View Controller.
public struct GKGameCenterView: NSViewControllerRepresentable {

    // MARK: - Properties
    /// Holds the view controller.
    let viewController: GKGameCenterViewController

    // MARK: - Initializers.
    /// Creates a new instance.
    /// - Parameter viewController: The view controller.
    public init(viewController: GKGameCenterViewController = GKGameCenterViewController()) {
        self.viewController = viewController
    }

    // MARK: - Functions
    /// Create a new view controller
    /// - Parameter context: The view context.
    /// - Returns: Returns the new view controller.
    public func makeNSViewController(context: Context) -> GKGameCenterViewController {
        let gkVC = viewController
        gkVC.gameCenterDelegate = context.coordinator
        return gkVC
    }

    /// Updates the view controller.
    /// - Parameters:
    ///   - uiViewController: The view controller
    ///   - context: The view context.
    public func updateNSViewController(_ uiViewController: GKGameCenterViewController, context: Context) {
        return
    }

    /// Creates a coordinator.
    /// - Returns: Returns the new coordinator.
    public func makeCoordinator() -> GKCoordinator {
        return GKCoordinator(self)
    }
}

// MARK: - Coordinator
/// GameKit Coordinator.
public class GKCoordinator: NSObject, GKGameCenterControllerDelegate {
    var view: GKGameCenterView

    // MARK: - Initializers
    /// Creates a new instance.
    /// - Parameter gkView: The Game Center view.
    init(_ gkView: GKGameCenterView) {
        self.view = gkView
    }

    // MARK: - Functions
    /// Handle the view controller finishing.
    /// - Parameter gameCenterViewController: The view controller.
    public func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(gameCenterViewController)
    }
}

#endif
