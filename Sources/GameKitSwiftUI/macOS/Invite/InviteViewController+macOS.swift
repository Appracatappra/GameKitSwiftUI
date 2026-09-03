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

/// The invite view controller.
public class InviteViewController: NSViewController, GKMatchDelegate, GKLocalPlayerListener {
    
    // MARK: - Properties
    /// Holds the GameKit invite.
    private let invite: GKInvite
    
    /// Holds the cenceled handler.
    private let canceled: () -> Void
    
    /// Holds the failed handler.
    private let failed: (Error) -> Void
    
    // Holds the started handler.
    private let started: (GKMatch) -> Void

    // MARK: - Initializers
    /// Creates a new instance.
    /// - Parameters:
    ///   - invite: The GameKit invite.
    ///   - canceled: Handle the invite being canceled.
    ///   - failed: Handle the invite failing.
    ///   - started: Handle the invite starting.
    public init(invite: GKInvite,
                canceled: @escaping () -> Void,
                failed: @escaping (Error) -> Void,
                started: @escaping (GKMatch) -> Void) {
        self.invite = invite
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
    /// Load the view.
    public override func loadView() {
        self.view = NSView()
    }
    
    /// Handle the view starting to appear.
    public override func viewWillAppear() {
        super.viewWillAppear()
        if GKLocalPlayer.local.isAuthenticated {
            self.showInviteViewController()
        } else {
            self.showAuthenticationViewController()
        }
    }
    
    /// Handle the view disappearing.
    public override func viewWillDisappear() {
        super.viewWillDisappear()
        self.removeAll()
    }
    
    /// Show the authentication view.
    public func showAuthenticationViewController() {
        let authenticationViewController = GKAuthenticationViewController { (error) in
            self.failed(error)
        } authenticated: { (player) in
            self.showInviteViewController()
        }
        self.add(authenticationViewController)
    }
    
    /// Show the invite view.
    public func showInviteViewController() {
        if let viewController = GKMatchManager.shared.createInvite(invite: self.invite,
                                                                     canceled: self.canceled,
                                                                     failed: self.failed,
                                                                     started: self.started) {
            
            self.add(viewController)
        } else {
            self.canceled()
        }
    }
}

#endif
