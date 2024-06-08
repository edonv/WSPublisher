//
//  WSErrors.swift
//  
//
//  Created by Edon Valdman on 9/4/23.
//

import Foundation

extension WebSocketPublisher {
    /// Errors pertaining to ``WebSocketPublisher``.
    public enum Errors: Error {
        /// Thrown when there is no active connection.
        case noActiveConnection
    }
}
