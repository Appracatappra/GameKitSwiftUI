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
/// Created by Sascha Müllner on 23.02.21.
/// Modified by Appracatappra, LLC on 2026/09/03

#if os(macOS)
import SwiftUI

/// The loading indicator view.
class LoadingViewController: NSViewController {
    
    // MARK: - Static Properties
    /// Sets the new spinner style.
    public static var spinnerStyle: UIActivityIndicatorView.Style = .large
    
    /// Sets the new spinner color.
    public static var spinnerColor: NSColor = NSColor.white
    
    /// Sets the new spinner background color.
    public static var spinnerBackgroundColor: NSColor = NSColor.black.withAlphaComponent(0.5)
    
    // MARK: - Initializers
    /// Creates a new instance.
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    /// Creates a new instance.
    /// - Parameter coder: The coder.
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Functions
    /// Loads the view.
    public override func loadView() {
        self.view = NSView()
        
        // Build spinner
        let spinner = NSProgressIndicator()
        spinner.translatesAutoresizingMaskIntoConstraints = false
        
        // Ensure the progress indicator is layer-backed
        spinner.wantsLayer = true
        
        // Larger size?
        if LoadingViewController.spinnerStyle == .large {
            // Set anchor
            spinner.layer?.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            
            // Scale spinner
            spinner.layer?.transform = CATransform3DMakeScale(2.0, 2.0, 1.0)
        }

        // Create a color filter (e.g., changing it to red)
        if let filter = CIFilter(name: "CIColorMonochrome") {
            filter.setDefaults()
            filter.setValue(CIColor(color: LoadingViewController.spinnerColor), forKey: "inputColor")
            filter.setValue(1.0, forKey: "inputIntensity")
            
            // Apply the filter to the progress indicator's layer
            spinner.contentFilters = [filter]
        }
        
        // Start and add indicator to view.
        spinner.startAnimation(self)
        self.view.addSubview(spinner)
        
        // Set background color
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = LoadingViewController.spinnerBackgroundColor.cgColor

        // Center our spinner both horizontally & vertically
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
#endif
