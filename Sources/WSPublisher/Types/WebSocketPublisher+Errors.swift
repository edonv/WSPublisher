//
//  WSErrors.swift
//  
//
//  Created by Edon Valdman on 9/4/23.
//

import Foundation

/// A non-namespaced shorthand for ``WebSocketPublisher/Errors``.
public typealias WSErrors = WebSocketPublisher.Errors

extension WebSocketPublisher {
    @available(*, deprecated, renamed: "Errors", message: "WSErrors has been renamed to `Errors` for the sake of brevity.")
    public typealias WSErrors = Errors
    
    /// Errors pertaining to ``WebSocketPublisher``.
    public enum Errors: Error {
        /// Thrown when there is no active connection.
        case noActiveConnection
    }
}
