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
import Combine
import Foundation
import GameKit
import SwiftUI

/// The matchmaking view controller.
public class MatchmakerViewController: NSViewController, GKMatchDelegate, GKLocalPlayerListener {
    
    // MARK: - Properties
    ///Holds the match request.
    private let matchRequest: GKMatchRequest
    
    /// Holds the matchmaking mode.
    private var matchmakingMode: Any? = nil
    
    /// Holds the canceled handler.
    private let canceled: () -> Void
    
    /// Holds the failed handler.
    private let failed: (Error) -> Void
    
    // Holds the started handler.
    private let started: (GKMatch) -> Void
    
    // Holds the cancellable token.
    private var cancellable: AnyCancellable?
    
    /// Holds the loading view controller.
    private let loadingViewController = LoadingViewController()
    
    // MARK: - Initializers
    /// Creates a new instance.
    /// - Parameters:
    ///   - matchRequest: The match request.
    ///   - matchmakingMode: The matchmaking mode.
    ///   - canceled: Handle matchmaking being canceled.
    ///   - failed: Handle matchmaking failing.
    ///   - started: Handle matchmaking starting.
    @available(macOS 11.0, *)
    public init(matchRequest: GKMatchRequest,
                matchmakingMode: GKMatchmakingMode,
                canceled: @escaping () -> Void,
                failed: @escaping (Error) -> Void,
                started: @escaping (GKMatch) -> Void) {
        self.matchRequest = matchRequest
        self.matchmakingMode = matchmakingMode
        self.canceled = canceled
        self.failed = failed
        self.started = started
        super.init(nibName: nil, bundle: nil)
    }

    /// Creates a new instance.
    /// - Parameters:
    ///   - matchRequest: The match request.
    ///   - canceled: Handle matchmaking being canceled.
    ///   - failed: Handle matchmaking failing.
    ///   - started: Handle matchmaking starting.
    public init(matchRequest: GKMatchRequest,
                canceled: @escaping () -> Void,
                failed: @escaping (Error) -> Void,
                started: @escaping (GKMatch) -> Void) {
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
    /// Load the view.
    public override func loadView() {
        self.view = NSView()
        self.view.setBoundsSize(NSSize(width: 800, height: 600))
    }
    
    /// Subscribe to matchmaking events.
    public func subscribe() {
        self.cancellable = GKMatchManager
            .shared
            .invite
            .sink { (invite) in
                self.showInvite(invite: invite)
        }
    }
    
    /// Show the matchmaking invite.
    /// - Parameter invite: The invite to show.
    public func showInvite(invite: Invite) {
        
        guard let invite = invite.gkInvite else { return }
        
        if let viewController = GKMatchManager.shared.createInvite(invite: invite,
                                                                     canceled: self.canceled,
                                                                     failed: self.failed,
                                                                     started: self.started) {
            self.add(viewController)
        } else {
            self.canceled()
        }
    }
    
    /// Unsubscribe to matchmaking event.
    public func unsubscribe() {
        self.cancellable?.cancel()
    }
    
    /// Handle the view appearing.
    public override func viewWillAppear() {
        super.viewWillAppear()
        self.add(loadingViewController)
        if GKLocalPlayer.local.isAuthenticated {
            self.showMatchmakerViewController()
        } else {
            self.showAuthenticationViewController()
        }
        self.subscribe()
    }
    
    /// Handle the view disappearing.
    public override func viewWillDisappear() {
        super.viewWillDisappear()
        self.removeAll()
        self.unsubscribe()
    }
    
    /// Show the authentication view.
    public func showAuthenticationViewController() {
        let authenticationViewController = GKAuthenticationViewController { (error) in
            self.failed(error)
        } authenticated: { (player) in
            self.showMatchmakerViewController()
        }
        self.add(authenticationViewController)
    }
    
    /// Show the matchmaking view.
    public func showMatchmakerViewController() {
        if let viewController = GKMatchManager.shared.createMatchmaker(request: self.matchRequest,
                                                                     canceled: self.canceled,
                                                                     failed: self.failed,
                                                                     started: self.started) {
            
            if #available(macOS 11.0, *) {
                viewController.matchmakingMode = self.matchmakingMode as? GKMatchmakingMode ?? .default
            }
            
            self.add(viewController)
        } else {
            self.canceled()
        }
    }
}

#endif
