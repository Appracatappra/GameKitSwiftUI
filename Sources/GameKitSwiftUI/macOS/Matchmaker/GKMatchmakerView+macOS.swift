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
 
/// The GameKit matchmaker view.
public struct GKMatchmakerView: NSViewControllerRepresentable {

    // MARK: - Type Aliases
    /// The `NSViewControllerType` type alias.
    public typealias NSViewControllerType = MatchmakerViewController
    
    // MARK: - Properties
    /// Holds the match request.
    private let matchRequest: GKMatchRequest
    
    /// Holds the matchmaking mode.
    private var matchmakingMode: Any? = nil
    
    /// Holds the canceled handler.
    private let canceled: () -> Void
    
    /// Holds the failed handler.
    private let failed: (Error) -> Void
    
    /// Holds the started handler.
    private let started: (GKMatch) -> Void

    // MARK: - Initializers
    /// Creates a new instance.
    /// - Parameters:
    ///   - matchRequest: The match request.
    ///   - matchmakingMode: The matchmaking mode.
    ///   - canceled: Handle the matchmaking being canceled.
    ///   - failed: Handle the matchmaking failing.
    ///   - started: Handle the matchmaking starting.
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
    }
    
    /// Creates a new instance.
    /// - Parameters:
    ///   - minPlayers: The minimum number of players.
    ///   - maxPlayers: The maximum number of players.
    ///   - inviteMessage: The invite message.
    ///   - matchmakingMode: The matchmaking mode.
    ///   - canceled: Handle the matchmaking being canceled.
    ///   - failed: Handle the matchmaking failing.
    ///   - started: Handle the matchmaking starting.
    @available(macOS 11.0, *)
    public init(minPlayers: Int,
                maxPlayers: Int,
                inviteMessage: String,
                matchmakingMode: GKMatchmakingMode,
                canceled: @escaping () -> Void,
                failed: @escaping (Error) -> Void,
                started: @escaping (GKMatch) -> Void) {
        let matchRequest = GKMatchRequest()
        matchRequest.minPlayers = minPlayers
        matchRequest.maxPlayers = maxPlayers
        matchRequest.inviteMessage = inviteMessage
        self.matchRequest = matchRequest
        self.matchmakingMode = matchmakingMode
        self.canceled = canceled
        self.failed = failed
        self.started = started
    }

    /// Creates a new instance.
    /// - Parameters:
    ///   - matchRequest: The matchmaking request.
    ///   - canceled: Handle the matchmaking being canceled.
    ///   - failed: Handle the matchmaking failing.
    ///   - started: Handle the matchmaking starting.
    public init(matchRequest: GKMatchRequest,
                canceled: @escaping () -> Void,
                failed: @escaping (Error) -> Void,
                started: @escaping (GKMatch) -> Void) {
        self.matchRequest = matchRequest
        self.canceled = canceled
        self.failed = failed
        self.started = started
    }

    /// Creates a new instance.
    /// - Parameters:
    ///   - minPlayers: The minimum number of players.
    ///   - maxPlayers: The maximum number of players.
    ///   - inviteMessage: The invite message.
    ///   - canceled: Handle the matchmaking being canceled.
    ///   - failed: Handle the matchmaking failing.
    ///   - started: Handle the matchmaking starting.
    public init(minPlayers: Int,
                maxPlayers: Int,
                inviteMessage: String,
                canceled: @escaping () -> Void,
                failed: @escaping (Error) -> Void,
                started: @escaping (GKMatch) -> Void) {
        let matchRequest = GKMatchRequest()
        matchRequest.minPlayers = minPlayers
        matchRequest.maxPlayers = maxPlayers
        matchRequest.inviteMessage = inviteMessage
        self.matchRequest = matchRequest
        self.canceled = canceled
        self.failed = failed
        self.started = started
    }
    
    // MARK: - Functions
    /// Creates a view controller.
    /// - Parameter context: The view context.
    /// - Returns: Returns the new view controller.
    public func makeNSViewController(
        context: NSViewControllerRepresentableContext<GKMatchmakerView>) -> MatchmakerViewController {
        if #available(macOS 11.0, *) {
            return self.makeMatchmakerViewControllerForMacOS11AndHigher()
        } else {
            return self.makeMatchmakerViewController()
        }
    }
    
    /// Creates a view controller for modern OSes.
    /// - Returns: Returns the new view controller.
    @available(macOS 11.0, *)
    internal func makeMatchmakerViewControllerForMacOS11AndHigher() -> MatchmakerViewController {
        guard let matchmakingMode = self.matchmakingMode as? GKMatchmakingMode else {
            return self.makeMatchmakerViewController()
        }
        return MatchmakerViewController(
            matchRequest: self.matchRequest,
            matchmakingMode: matchmakingMode) {
            self.canceled()
        } failed: { (error) in
            self.failed(error)
        } started: { (match) in
            self.started(match)
        }
    }

    /// Creates a view controller for legacy OSes.
    /// - Returns: Returns the new view controller.
    internal func makeMatchmakerViewController() -> MatchmakerViewController {
        return MatchmakerViewController(
            matchRequest: self.matchRequest) {
            self.canceled()
        } failed: { (error) in
            self.failed(error)
        } started: { (match) in
            self.started(match)
        }
    }

    /// Updates the view controller.
    /// - Parameters:
    ///   - uiViewController: The view controller.
    ///   - context: The view context.
    public func updateNSViewController(
        _ nsViewController: MatchmakerViewController,
        context: NSViewControllerRepresentableContext<GKMatchmakerView>) {
    }
}

#endif
