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
    public enum Event: Hashable, Sendable {
        /// Occurs when ``WebSocketPublisher/publisher`` is initially created.
        case publisherCreated
        
        /// Occurs when the connection is opened successfully.
        case connected(Connect)
        
        /// Occurs when the connection is closed, or it fails to connect.
        case disconnected(Disconnect)
        
        /// Occurs when ``WebSocketPublisher/webSocketTask`` receives a `Data` message.
        case data(Data)
        
        /// Occurs when ``WebSocketPublisher/webSocketTask`` receives a `String` message.
        case string(String)
        
        /// This is used as a fallback, due to
        /// [`URLSessionWebSocketTask.Message`](https://developer.apple.com/documentation/foundation/urlsessionwebsockettask/message)
        /// being made with the possibility of new cases.
        case generic(URLSessionWebSocketTask.Message)
    }
}

extension WebSocketPublisher.Event {
    // MARK: - .connected
    
    public struct Connect: Sendable, Hashable {
        public let `protocol`: String?
        public let response: HTTPResponse
        
        public var headers: HTTPFields {
            response.headerFields
        }
        
        internal init(_ protocol: String?, response: HTTPResponse) {
            self.protocol = `protocol`
            self.response = response
        }
    }
    
    public static func connected(_ protocol: String?, response: HTTPResponse) -> WebSocketPublisher.Event {
        .connected(Connect(`protocol`, response: response))
    }
    
    // MARK: - .disconnected
    
    public enum Disconnect: Sendable, Hashable {
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
        case unknownError(NSError)
    }
    
    /// Occurs when the connection is closed.
    public static func disconnected(_ closeCode: URLSessionWebSocketTask.CloseCode, _ reason: String?) -> WebSocketPublisher.Event {
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
    public static func disconnected(_ urlError: URLError) -> WebSocketPublisher.Event {
        .disconnected(.urlError(urlError))
    }
    
    /// Occurs when the connection is closed.
    public static func disconnected(_ error: Error) -> WebSocketPublisher.Event {
        .disconnected(.unknownError(error as NSError))
    }
}

extension WebSocketPublisher.Event: CustomStringConvertible {
    public var description: String {
        switch self {
        case .publisherCreated:
            return "publisherCreated"
        case .connected(let connect):
            var strs = [String]()
            if let p = connect.protocol {
                strs.append("protocol: \"\(p)\"")
            }
            if !connect.headers.isEmpty {
                strs.append("headers: [\(connect.headers.map(\.description).joined(separator: ", "))]")
            }
            let suffix = strs.isEmpty ? "" : "(" + strs
                .joined(separator: ", ") + ")"
            return "connected" + suffix
        
        case .disconnected(let disconnect):
            let detail: String
            switch disconnect {
            case .closeCode(let code, let reason):
                let reasonStr = reason.map { "\"\($0)\""} ?? "nil"
                detail = "code: \(code), reason: \(reasonStr)"
            case .urlError(let urlError):
                detail = "error: \(urlError)"
            case .unknownError(let error):
                detail = "error: \(error)"
            }
            
            return "disconnected(\(detail))"
        case .data(let data):
            return "data(\(data))"
        case .string(let string):
            return "string(\"\(string)\")"
        case .generic(let message):
            return "generic(\(message))"
        }
    }
}
