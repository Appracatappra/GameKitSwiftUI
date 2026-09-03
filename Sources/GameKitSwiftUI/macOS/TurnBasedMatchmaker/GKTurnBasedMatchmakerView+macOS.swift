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
/// Created by Sascha Müllner on 28.03.21.
/// Modified by Appracatappra, LLC on 2026/09/03

#if os(macOS)
import Foundation
import GameKit
import SwiftUI

/// The turn-based matchmaker view.
public struct GKTurnBasedMatchmakerView: NSViewControllerRepresentable {
    
    // MARK: - Properties
    /// Holds the match request.
    private let matchRequest: GKMatchRequest
    
    // Holds the canceled handler.
    private let canceled: () -> Void
    
    // Holds the failed handler.
    private let failed: (Error) -> Void
    
    // Holds the started handler.
    private let started: (GKTurnBasedMatch) -> Void
    
    // MARK: - Initializers.
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
    }
    
    /// Creates a new instance.
    /// - Parameters:
    ///   - minPlayers: The minimum number of players.
    ///   - maxPlayers: The maximum number of players.
    ///   - inviteMessage: The invite message.
    ///   - canceled: Handle the request being canceled.
    ///   - failed: Handle the request failing.
    ///   - started: Handle the request starting.
    public init(minPlayers: Int,
                maxPlayers: Int,
                inviteMessage: String,
                canceled: @escaping () -> Void,
                failed: @escaping (Error) -> Void,
                started: @escaping (GKTurnBasedMatch) -> Void) {
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
    /// Creates the view controller.
    /// - Parameter context: The view context.
    /// - Returns: Returns the new view controller.
    public func makeNSViewController(
        context: NSViewControllerRepresentableContext<GKTurnBasedMatchmakerView>) -> TurnBasedMatchmakerViewController {
        return TurnBasedMatchmakerViewController(
            matchRequest: self.matchRequest) {
            self.canceled()
        } failed: { (error) in
            self.failed(error)
        } started: { (match) in
            self.started(match)
        }
    }
    
    /// Update the view controller.
    /// - Parameters:
    ///   - uiViewController: The view controller.
    ///   - context: The view context.
    public func updateNSViewController(
        _ nsViewController: TurnBasedMatchmakerViewController,
        context: NSViewControllerRepresentableContext<GKTurnBasedMatchmakerView>) {
    }
}

#endif
