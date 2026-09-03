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
/// Created by Sascha Müllner on 26.02.21.
/// Modified by Appracatappra, LLC on 2026/09/03

import os.log
import Combine
import Foundation
import GameKit
import SwiftUI

/// The GameKit Match Manager.
public final class GKMatchManager: NSObject, @unchecked Sendable {
    
    // MARK: - Static Properties
    /// Holds the common shared match manager.
    public static let shared = GKMatchManager()
    
    // MARK: - Propreties
    /// Holds the local player.
    private(set) public var localPlayer = CurrentValueSubject<GKLocalPlayer, Never>(GKLocalPlayer.local)
    
    // Holds the match.
    private(set) public var match = CurrentValueSubject<Match, Never>(Match.zero)
    
    // Holds the invite.
    private(set) public var invite = CurrentValueSubject<Invite, Never>(Invite.zero)
    
    /// Holds the match canceled handler.
    private var canceled: () -> Void = {}
    
    // Holds the match failed handler.
    private var failed: (Error) -> Void = { _ in }
    
    // Holds the match started handler.
    private var started: (GKMatch) -> Void = { _ in }
    
    // MARK: - Initializers
    /// Creates a new instance.
    private override init() {
        super.init()
        
        // Subscribe to motifications.
        NotificationCenter.default.addObserver(
            forName: Notification.Name("GKAcceptedGameInvite"),
            object: nil,
            queue: nil)
        { notification in
            self.invite.send(Invite.needsToAuthenticate)
        }
        
        NotificationCenter.default.addObserver(
            forName: Notification.Name("GKPlayerAuthenticationDidChangeNotificationName"),
            object: nil,
            queue: nil)
        { notification in
            self.localPlayer.send(GKLocalPlayer.local)
        }
        
        NotificationCenter.default.addObserver(
            forName: Notification.Name("GKPlayerDidChangeNotificationName"),
            object: nil,
            queue: nil)
        { notification in
            self.localPlayer.send(GKLocalPlayer.local)
        }
        
        // Register self.
        GKLocalPlayer.local.register(self)
    }
        
    // MARK: - Functions
    /// Creates invite.
    /// - Parameters:
    ///   - invite: The invite to create.
    ///   - canceled: Handle the invite being canceled.
    ///   - failed: Handle the invite failing.
    ///   - started: Handle the invite starting.
    /// - Returns: Returns a matchmaker controller.
    @MainActor internal func createInvite(invite: GKInvite,
                                 canceled: @escaping () -> Void,
                                 failed: @escaping (Error) -> Void,
                                 started: @escaping (GKMatch) -> Void) -> GKMatchmakerViewController? {
        self.canceled = canceled
        self.failed = failed
        self.started = started
        
        guard GKLocalPlayer.local.isAuthenticated,
              let matchmakerViewController = GKMatchmakerViewController(invite: invite) else {
            GKMatchmaker.shared().cancel()
            canceled()
            return nil
        }
        
        matchmakerViewController.matchmakerDelegate = self
        return matchmakerViewController
    }
    
    /// Creates a matchmaker.
    /// - Parameter invite: The invite.
    /// - Returns: Returns a matchmaker controller.
    @MainActor internal func createMatchmaker(invite: GKInvite) -> GKMatchmakerViewController? {
        guard GKLocalPlayer.local.isAuthenticated,
              let matchmakerViewController = GKMatchmakerViewController(invite: invite) else {
            GKMatchmaker.shared().cancel()
            return nil
        }
        
        matchmakerViewController.matchmakerDelegate = self
        return matchmakerViewController
    }
    
    /// Creates a matchmaker.
    /// - Parameters:
    ///   - request: The match request.
    ///   - canceled: Handle the invite being canceled.
    ///   - failed: Handle the invite failing.
    ///   - started: Handle the invite starting.
    /// - Returns: Returns a view controller.
    @MainActor internal func createMatchmaker(request: GKMatchRequest,
                                 canceled: @escaping () -> Void,
                                 failed: @escaping (Error) -> Void,
                                 started: @escaping (GKMatch) -> Void) -> GKMatchmakerViewController? {
        self.canceled = canceled
        self.failed = failed
        self.started = started
        guard GKLocalPlayer.local.isAuthenticated,
              let matchmakerViewController = GKMatchmakerViewController(matchRequest: request) else {
            GKMatchmaker.shared().cancel()
            canceled()
            return nil
        }
        
        matchmakerViewController.matchmakerDelegate = self
        return matchmakerViewController
    }
    
    /// Cancel matchmaking.
    public func cancel() {
        GKMatchmaker.shared().cancel()
        self.invite.send(Invite.zero)
        self.match.send(Match.zero)
    }
}

#if os(iOS) || os(tvOS)
/// Extends `GKMatchManager`
extension GKMatchManager: @preconcurrency GKMatchmakerViewControllerDelegate {

    // MARK: - Functions
    /// Handle the match starting.
    /// - Parameters:
    ///   - viewController: The view controller.
    ///   - match: The match.
    @MainActor public func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFind match: GKMatch) {
        viewController.dismiss(
            animated: true,
            completion: {
                os_log("Matchmaking successful!", log: OSLog.matchmaking, type: .info)
                self.match.send(Match(gkMatch: match))
                self.started(match)
                viewController.remove()
        })
    }
    
    /// Handle the match being canceled.
    /// - Parameter viewController: The view controller.
    public func matchmakerViewControllerWasCancelled(_ viewController: GKMatchmakerViewController) {
        viewController.dismiss(
            animated: true,
            completion: {
                os_log("Matchmaking cancelled!", log: OSLog.matchmaking, type: .error)
                self.invite.send(Invite.zero)
                self.match.send(Match.zero)
                self.canceled()
                viewController.remove()
        })
    }
    
    /// Handle the match failing.
    /// - Parameters:
    ///   - viewController: The view controller.
    ///   - error: The error message.
    public func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFailWithError error: Error) {
        viewController.dismiss(
            animated: true,
            completion: {
                os_log("Matchmaking failed: %{public}@", log: OSLog.matchmaking, type: .error, error.localizedDescription)
                self.invite.send(Invite.zero)
                self.match.send(Match.zero)
                self.failed(error)
                viewController.remove()
        })
    }
}

#elseif os(macOS)
/// Extends `GKMatchManager`.
extension GKMatchManager: GKMatchmakerViewControllerDelegate {

    // MARK: - Functions
    /// Handle the match starting.
    /// - Parameters:
    ///   - viewController: The view controller.
    ///   - match: The match.
    public func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFind match: GKMatch) {
        Task {@MainActor in
            viewController.dismiss(self)
        }
        os_log("Matchmaking successful!", log: OSLog.matchmaking, type: .info)
        self.match.send(Match(gkMatch: match))
        self.started(match)
    }
    
    /// Handle the match being canceled.
    /// - Parameter viewController: The view controller.
    public func matchmakerViewControllerWasCancelled(_ viewController: GKMatchmakerViewController) {
        Task {@MainActor in
            viewController.dismiss(self)
        }
        os_log("Matchmaking cancelled!", log: OSLog.matchmaking, type: .error)
        self.invite.send(Invite.zero)
        self.match.send(Match.zero)
        self.canceled()
    }
    
    /// Handle the match failing.
    /// - Parameters:
    ///   - viewController: The view controller
    ///   - error: The error description.
    public func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFailWithError error: Error) {
        Task {@MainActor in
            viewController.dismiss(self)
        }
        os_log("Matchmaking failed: %{public}@", log: OSLog.matchmaking, type: .error, error.localizedDescription)
        self.invite.send(Invite.zero)
        self.match.send(Match.zero)
        self.failed(error)
    }
}
#endif

/// Extends `GKMatchManager`.
extension GKMatchManager: GKLocalPlayerListener {
    
    // MARK: - Functions
    /// Sends invite to player.
    /// - Parameters:
    ///   - player: The player.
    ///   - invite: The invite.
    public func player(_ player: GKPlayer,
                didAccept invite: GKInvite) {
        os_log("Player invited: %{public}@", log: OSLog.invite, type: .info, invite)
        self.invite.send(Invite(gkInvite: invite))
    }
}
