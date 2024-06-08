//
//  WebSocketPublisher+Async.swift
//  
//
//  Created by Edon Valdman on 9/4/23.
//

import Foundation
import Combine

extension WebSocketPublisher {
    /// Private async encapsulation for sending a
    /// [URLSessionWebSocketTask.Message](https://developer.apple.com/documentation/foundation/urlsessionwebsockettask/message) to
    /// the connected WebSocket server/host.
    ///
    /// - Parameter message: The [URLSessionWebSocketTask.Message](https://developer.apple.com/documentation/foundation/urlsessionwebsockettask/message) to send.
    /// - Throws: ``WebSocketPublisher/Errors/noActiveConnection`` if there isn't an active connection, or can fail if an
    /// error occurs while sending.
    /// - Returns: `Void`, signalling the message has been sent.
    private func send(_ message: URLSessionWebSocketTask.Message) async throws {
        let task = try confirmConnection()
        try await task.send(message)
    }
    
    /// Sends a `String` message to the connected WebSocket server/host.
    /// - Parameter message: The `String` message to send.
    /// - Throws: ``WebSocketPublisher/Errors/noActiveConnection`` if there isn't an active connection, or can fail if an
    /// error occurs while sending.
    /// - Returns: `Void`, signalling the message has been sent.
    public func send(_ message: String) async throws {
        try await send(.string(message))
    }
    
    /// Sends a `Data` message to the connected WebSocket server/host.
    /// - Parameter message: The `Data` message to send.
    /// - Throws: ``WebSocketPublisher/Errors/noActiveConnection`` if there isn't an active connection, or can fail if an
    /// error occurs while sending.
    /// - Returns: `Void`, signalling the message has been sent.
    public func send(_ message: Data) async throws {
        try await send(.data(message))
    }
    
    /// Sends a ping to the connected WebSocket server/host.
    /// - Throws: ``WebSocketPublisher/Errors/noActiveConnection`` if there isn't an active connection, or can fail if an
    /// error occurs while sending.
    /// - Returns: `Void`, signalling the ping has been sent.
    public func ping() async throws {
        let task = try confirmConnection()
        try await task.sendPing()
    }
}

