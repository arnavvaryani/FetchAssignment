//
//  SafariWebView.swift
//  FetchTakeHomeAssesment
//
//  Created by Arnav Varyani on 6/2/25.
//

import SwiftUI
import SafariServices

/// A SwiftUI-compatible wrapper around `SFSafariViewController`
/// for displaying web content inside the app using Safari's in-app browser.
struct SafariWebView: UIViewControllerRepresentable {
    
    let url: URL
    
    /// Creates and configures the `SFSafariViewController`.
    /// - Parameter context: The context in which the view controller is created.
    /// - Returns: A configured instance of `SFSafariViewController`.
    func makeUIViewController(context: Context) -> SFSafariViewController {
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = false
        
        let safariVC = SFSafariViewController(url: url, configuration: config)
        safariVC.preferredControlTintColor = .systemBlue
        return safariVC
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
        //No need to update, just here to adhere to protocol stubs
    }
    
    
}
