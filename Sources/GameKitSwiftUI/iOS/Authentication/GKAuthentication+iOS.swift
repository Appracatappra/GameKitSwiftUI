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
/// Created by Sascha Müllner on 23.02.21.
/// Modified by Appracatappra, LLC on 2026/09/03

#if os(iOS) || os(tvOS)
import os.log
import Combine
import Foundation
import GameKit

/**
    Authenticates the local player with Game Center.
 */
public final class GKAuthentication: NSObject, GKLocalPlayerListener {

    // MARK: - Enumerations
    /// Defines an error that will be thrown if authentication fails.
    public struct AuthenticationError: LocalizedError {
        /// Holds the message.
        let message: String
        
        // Provide the description string required by LocalizedError
        public var errorDescription: String? {
            return message
        }
    }
    
    // MARK: - Static Properties
    /// Holds the common shared instance of `GKAuthentication`.
    nonisolated(unsafe) public static let shared = GKAuthentication()
    
    /// If `true` the logout process will time-out after a given number of seconds. If `false` the time-out will not occur.
    nonisolated(unsafe) public static var useTimeout: Bool = true;
    
    /// Sets the number of seconds before a time-out occurs.
    /// - remark: Time-out will only occur if the `useTimeout` property is set to `true`.
    nonisolated(unsafe) public static var timeoutSeconds: TimeInterval = 10.0
    
    // MARK: - Properties
    /// Holds an authentication time-out timer.
    private var timer: Timer?
    
    /// Holds the last authentication error.
    private(set) var authenticationError: Error?
    
    /// If `true` the user is authenticated, else they are not.
    private(set) public var isAuthenticated = CurrentValueSubject<Bool, Never>(false)
    
    // MARK: - Initializers
    /// Creates a new instance.
    private override init() {
        // Set initial authentication state.
        self.isAuthenticated.value = GKLocalPlayer.local.isAuthenticated
        
        // Call base.
        super.init()
        
        // Setup internal observer for GameKit authentication changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(GKAuthentication.authenticationChanged),
            name: Notification.Name.GKPlayerAuthenticationDidChangeNotificationName,
            object: nil
        )
    }
    
    /// Deinitialize.
    deinit {
        self.stopTimer()
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Functions
    /// Handle the local user authentication state changing.
    @objc fileprivate func authenticationChanged() {
        self.isAuthenticated.value = GKLocalPlayer.local.isAuthenticated
    }
    
    /// Authenticates the local player.
    /// - Parameters:
    ///   - authenticationViewController: The authentication view controller.
    ///   - failed: Handle the authentication failing.
    ///   - authenticated: Handle the authentication succeeding.
    public func authenticate(authenticationViewController: @escaping (UIViewController) -> Void,
                             failed: @Sendable @escaping (Error) -> Void,
                             authenticated: @escaping (GKLocalPlayer) -> Void) {
        
        // Is authenticated?
        if GKLocalPlayer.local.isAuthenticated {
            // Yes, stop timer, notify caller and abort.
            stopTimer()
            authenticated(GKLocalPlayer.local)
            return
        }
        
        // Did authentication fail?
        if let authenticationError = self.authenticationError {
            // Yes, stop timer, notify caller and abort.
            stopTimer()
            failed(authenticationError)
            return
        }
        
        // Invalidate any existing timer to prevent duplicates
        timer?.invalidate()
        
        // Start a time-out timer?
        if GKAuthentication.useTimeout {
            // Yes, Schedule a timer that ends after the given number of seconds elapse.
            timer = Timer.scheduledTimer(withTimeInterval: GKAuthentication.timeoutSeconds, repeats: false) { currentTimer in
                // Notify caller of time-out.
                failed(AuthenticationError(message: "GKLocalPlayer Local Authentication Timed Out."))
                currentTimer.invalidate()
            }
        }
        
        // Handle authentication.
        GKLocalPlayer.local.authenticateHandler = { viewController, error in

            // Authentication has started, cancel the time-out.
            self.stopTimer()
            
            // Is authenticated?
            if GKLocalPlayer.local.isAuthenticated {
                // Yes, notify caller and abort.
                authenticated(GKLocalPlayer.local)
                return
            }

            // Is error?
            if let error = error {
                // Yes, log error, notify caller and abort.
                os_log("Authentication failed %{public}@", log: OSLog.authentication, type: .error, error.localizedDescription)
                self.authenticationError = error
                failed(error)
                return
            }
            
            // Was a Game Center view returned?
            if let viewController {
                // Yes, Ask caller to display authentication view.
                authenticationViewController(viewController)
            } else {
                // No, an error has occurred, inform the user and cancel authentication.
                failed(AuthenticationError(message: "GKLocalPlayer Local Authentication failed to return a valid Game Center View."))
            }
        }
    }
    
    /// Stops the timer.
    func stopTimer() {
        // Manually stop the timer and erase it.
        timer?.invalidate()
        timer = nil
    }
}

#endif
