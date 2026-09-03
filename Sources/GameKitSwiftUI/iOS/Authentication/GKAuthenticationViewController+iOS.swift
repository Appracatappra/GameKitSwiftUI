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
import Foundation
import GameKit
import SwiftUI

/// The `GKAuthenticationView` Controller.
public class GKAuthenticationViewController: UIViewController {

    // MARK: - Properties
    /// If `true` show the loading indicator, else hide it.
    let showLoading: Bool
    
    /// The authentication failed handler.
    let failed: (Error) -> Void
    
    // The authentication succeeded handler.
    let authenticated: (GKLocalPlayer) -> Void
    
    // The loading controller.
    private let _loadingViewController = LoadingViewController()

    // MARK: - Initializers
    /// Creates a new instance.
    /// - Parameters:
    ///   - failed: Handle authentication failing.
    ///   - authenticated: Handle authentication succeeding.
    public init(failed: @escaping (Error) -> Void,
                authenticated: @escaping (GKLocalPlayer) -> Void) {
        self.showLoading = true
        self.failed = failed
        self.authenticated = authenticated
        super.init(nibName: nil, bundle: nil)
    }
    
    /// Creates a new instance.
    /// - Parameters:
    ///   - showLoading: If `true` show the loading indicator,
    ///   - failed: Handle authentication failing.
    ///   - authenticated: Handle authentication succeeding.
    public init(showLoading:Bool, failed: @escaping (Error) -> Void,
                authenticated: @escaping (GKLocalPlayer) -> Void) {
        
        self.showLoading = showLoading
        
        self.failed = failed
        self.authenticated = authenticated
        super.init(nibName: nil, bundle: nil)
    }
    
    /// Creates a new instance.
    /// - Parameter coder: The coder.
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Deinitialize.
    deinit {
    }

    // MARK: - Functions
    /// Handle the view appearing.
    /// - Parameter animated: If `true` the view is animated.
    public override func viewWillAppear(_ animated: Bool) {
        
        // Call base.
        super.viewWillAppear(animated)
        
        // Show loading?
        if showLoading {
            // Yes, add it to view.
            self.add(_loadingViewController)
        }
        
        // Attempt to authenticate.
        GKAuthentication.shared.authenticate { (authenticationViewController) in
            self.add(authenticationViewController)
        } failed: { [weak self] error in
            // Log error.
            os_log("Authentication failed %{public}@", log: OSLog.authentication, type: .error, error.localizedDescription)

            // Send error to caller.
            Task { @MainActor in
                self?.failed(error)
            }
        } authenticated: { (player) in
            // Log success.
            os_log("Player authenticated %{public}@", log: OSLog.authentication, type: .info, player.displayName)
            
            // Inform caller of success.
            self.authenticated(player)
        }
    }
    
    /// Handle the view disappearing.
    /// - Parameter animated: If `true` the view is animated.
    public override func viewWillDisappear(_ animated: Bool) {
        self.removeAll()
    }
}

#endif
