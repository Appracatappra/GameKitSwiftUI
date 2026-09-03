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
/// Created by Sascha Müllner on 22.11.20.
/// Modfied by Sascha Müllner on 17.12.20.
/// Modified by Appracatappra, LLC on 2026/09/03

#if os(iOS) || os(tvOS)
import Foundation
import GameKit
import SwiftUI

/// GameKit Invite View.
public struct GKInviteView: UIViewControllerRepresentable {

    // MARK: - Properties
    /// Holds the GameKit invite.
    private let invite: GKInvite
    
    /// Holds the cancel handler.
    private let canceled: () -> Void
    
    // Holds the failed handler.
    private let failed: (Error) -> Void
    
    /// Holds the started handler.
    private let started: (GKMatch) -> Void

    // MARK: - Initializers
    /// Creates a new instance.
    /// - Parameters:
    ///   - invite: The Gamekit Invite.
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
    }

    // MARK: - Functions
    /// Makes the View Controller.
    /// - Parameter context: The view context.
    /// - Returns: Returns the new view controller.
    public func makeUIViewController(
        context: UIViewControllerRepresentableContext<GKInviteView>) -> InviteViewController {
        
        // Build and return the controller.
        return InviteViewController(
            invite: self.invite) {
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
    public func updateUIViewController(
        _ uiViewController: InviteViewController,
        context: UIViewControllerRepresentableContext<GKInviteView>) {
    }
}
#endif
