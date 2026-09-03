///
/// MIT License
///
/// Copyright (c) 2020 Sascha Müllner
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
/// Created by Sascha Müllner on 03.04.21.
/// Modified by Appracatappra, LLC on 2026/09/03

#if os(tvOS)
import Foundation
import GameKit
import SwiftUI

/// The turn-based matchmaker view controller.
public class TurnBasedMatchmakerViewController: UIViewController, GKTurnBasedMatchmakerViewControllerDelegate, GKMatchDelegate {

    // MARK: - Properties
    /// Holds the match request.
    private let matchRequest: GKMatchRequest
    
    /// Holds the canceled handler.
    private let canceled: () -> Void
    
    // Holds the failed handler.
    private let failed: (Error) -> Void
    
    // Holds the started handler.
    private let started: (GKTurnBasedMatch) -> Void
    
    // MARK: - Initializers
    /// Creates a new instance.
    /// - Parameters:
    ///   - matchRequest: The match request.
    ///   - canceled: Handle the request being canceled.
    ///   - failed: Handle the request failing.
    ///   - started: Handle the request starting.
    public init(matchRequest: GKMatchRequest,
                canceled: @escaping () -> Void,
                failed: @escaping (Error) -> Void,
                started: @escaping (GKTurnBasedMatch) -> Void) {
        self.matchRequest = matchRequest
        self.canceled = canceled
        self.failed = failed
        self.started = started
        super.init(nibName: nil, bundle: nil)
    }
    
    /// Creates a new instance.
    /// - Parameter coder: The coder.
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Functions
    /// Handle the view appearing.
    /// - Parameter animated: If `true` the view is animated.
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let viewController = GKTurnBasedMatchmakerViewController(matchRequest: self.matchRequest)
        viewController.turnBasedMatchmakerDelegate = self
        self.add(viewController)
    }

    /// Handle the turn-base matchmaker being canceled.
    /// - Parameter viewController: The view controller.
    public func turnBasedMatchmakerViewControllerWasCancelled(_ viewController: GKTurnBasedMatchmakerViewController) {
        viewController.dismiss(
            animated: true,
            completion: {
                self.canceled()
                viewController.remove()
        })
    }

    /// Handle the turn-based matchmaker failing.
    /// - Parameters:
    ///   - viewController: The view controller.
    ///   - error: The error message.
    public func turnBasedMatchmakerViewController(_ viewController: GKTurnBasedMatchmakerViewController, didFailWithError error: Error) {
        viewController.dismiss(
            animated: true,
            completion: {
                self.failed(error)
                viewController.remove()
        })
    }
}

#endif
