//
//  WSEvent.swift
//  
//
//  Created by Edon Valdman on 9/4/23.
//

import Foundation

extension WebSocketPublisher {
    /// Events that are published via ``WebSocketPublisher/publisher``.
    public enum WSEvent {
        /// Occurs when ``WebSocketPublisher/publisher`` is initially created.
        case publisherCreated
        
        /// Occurs when the connection is opened successfully.
        case connected(_ protocol: String?)
        
        /// Occurs when the connection is closed.
        case disconnected(_ closeCode: URLSessionWebSocketTask.CloseCode, _ reason: String?)
        
        /// Occurs when ``WebSocketPublisher/webSocketTask`` receives a `Data` message.
        case data(Data)
        
        /// Occurs when ``WebSocketPublisher/webSocketTask`` receives a `String` message.
        case string(String)
        
        /// This is used as a fallback, due to
        /// [URLSessionWebSocketTask.Message](https://developer.apple.com/documentation/foundation/urlsessionwebsockettask/message)
        /// being made with the possibility of new cases.
        case generic(URLSessionWebSocketTask.Message)
    }
}
