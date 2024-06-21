//
//  WebSocketPublisher+Event.swift
//
//
//  Created by Edon Valdman on 9/4/23.
//

import Foundation

import HTTPTypes

/// A non-namespaced shorthand for ``WebSocketPublisher/Event``.
public typealias WSEvent = WebSocketPublisher.Event

extension WebSocketPublisher {
    @available(*, deprecated, renamed: "Event", message: "WSEvent has been renamed to `Event` for the sake of brevity.")
    public typealias WSEvent = Event
    
    /// Events that are published via ``WebSocketPublisher/publisher``.
    public enum Event {
        /// Occurs when ``WebSocketPublisher/publisher`` is initially created.
        case publisherCreated
        
        /// Occurs when the connection is opened successfully.
        case connected(_ protocol: String?, upgradeHeaders: HTTPFields)
        
        /// Occurs when the connection is closed.
        case disconnected(Disconnect)
        
        /// Occurs when ``WebSocketPublisher/webSocketTask`` receives a `Data` message.
        case data(Data)
        
        /// Occurs when ``WebSocketPublisher/webSocketTask`` receives a `String` message.
        case string(String)
        
        /// This is used as a fallback, due to
        /// [`URLSessionWebSocketTask.Message`](https://developer.apple.com/documentation/foundation/urlsessionwebsockettask/message)
        /// being made with the possibility of new cases.
        case generic(URLSessionWebSocketTask.Message)
        
        /// Occurs when the connection is closed.
        public static func disconnected(_ closeCode: URLSessionWebSocketTask.CloseCode, _ reason: String?) -> Event {
            .disconnected(.closeCode(closeCode, reason))
        }
        
        /// The connection closes with a [`URLError`](https://developer.apple.com/documentation/foundation/urlerror), instead of with a close code.
        ///
        /// # Examples
        /// Common scenarios include:
        /// - Attemping to establish a connection with a URL that doesn't support a WebSocket connection.
        /// - Attemping to establish a connection that fails the WebSocket handshake.
        /// - ~~A connected WebSocket server closes without sending a close code.~~
        ///     - This scenario is being internally mapped to a ``disconnected(_:_:)`` type.
        public static func disconnected(_ urlError: URLError) -> Event {
            .disconnected(.urlError(urlError))
        }
        
        /// Occurs when the connection is closed.
        public static func disconnected(_ error: Error) -> Event {
            .disconnected(.unknownError(error))
        }
    }
}

extension WebSocketPublisher.Event {
    public enum Disconnect: Sendable {
        /// The connection closes safely with a close code, and optionally with a descriptive reason.
        case closeCode(_ closeCode: URLSessionWebSocketTask.CloseCode, _ reason: String?)
        
        /// The connection closes with an error, instead of with a close code.
        ///
        /// # Examples
        /// Common scenarios include:
        /// - Attemping to establish a connection with a URL that doesn't support a WebSocket connection.
        /// - Attemping to establish a connection that fails the WebSocket handshake.
        /// - ~~A connected WebSocket server closes without sending a close code.~~
        ///     - This scenario is being internally mapped to a ``disconnected(_:_:)`` type.
        case urlError(URLError)
        
        /// Some other type of `Error` occurs that isn't a `URLError`.
        case unknownError(Error)
    }
}
