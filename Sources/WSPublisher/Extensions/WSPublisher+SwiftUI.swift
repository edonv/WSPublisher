//
//  WSPublisher+SwiftUI.swift
//  
//
//  Created by Edon Valdman on 9/4/23.
//

import SwiftUI
import Combine

extension View {
    /// Adds an action to perform when this view detects an ``WebSocketPublisher/Event`` emitted by the given ``WebSocketPublisher``.
    /// - Parameters:
    ///   - manager: The ``WebSocketPublisher`` to listen to (``WebSocketPublisher/publisher``).
    ///   - action: The action to perform when an event is emitted by `manager`. The event emitted by `manager` is passed as a parameter to `action`.
    /// - Returns: A view that triggers `action` when `manager` emits an event.
    public func onWebSocketEvent(
        _ manager: WebSocketPublisher,
        perform action: @escaping (WebSocketPublisher.Event) -> Void
    ) -> some View {
        self.onReceive(manager.publisher, perform: action)
    }
    
    public func onWebSocketConnect(
        _ manager: WebSocketPublisher,
        perform action: @escaping (_ protocol: String?) -> Void
    ) -> some View {
        self.onReceive(
            manager.publisher
                // Explicitly noted as String?? so it doesn't fully-unwrap the parameter
                .compactMap { event -> String?? in
                    guard case .connected(let p) = event else { return nil }
                    return p
                },
            perform: action
        )
    }
    
    /// Adds an action to perform when this view detects an ``WebSocketPublisher/Event/disconnected(_:_:)`` event emitted by the given ``WebSocketPublisher``.
    /// - Parameters:
    ///   - manager: The ``WebSocketPublisher`` to listen to (``WebSocketPublisher/publisher``).
    ///   - action: The action to perform when a ``WebSocketPublisher/Event/disconnected(_:_:)`` event is emitted by `manager`. The event's properties are passed as a parameter to `action`.
    /// - Returns: A view that triggers `action` when `manager` emits an event.
    public func onWebSocketDisconnect(
        _ manager: WebSocketPublisher,
        perform action: @escaping (_ closeCode: URLSessionWebSocketTask.CloseCode, _ reason: String?) -> Void
    ) -> some View {
        self.onReceive(
            manager.publisher
                .compactMap { event in
                    guard case .disconnected(let closeCode, let reason) = event else { return nil }
                    return (closeCode, reason)
                },
            perform: action
        )
    }
    
    /// Adds an action to perform when this view detects an ``WebSocketPublisher/Event/data(_:)`` event emitted by the given ``WebSocketPublisher``.
    /// - Parameters:
    ///   - manager: The ``WebSocketPublisher`` to listen to (``WebSocketPublisher/publisher``).
    ///   - action: The action to perform when a ``WebSocketPublisher/Event/data(_:)`` event is emitted by `manager`. The event's properties are passed as a parameter to `action`.
    /// - Returns: A view that triggers `action` when `manager` emits an event.
    public func onWebSocketData(
        _ manager: WebSocketPublisher,
        perform action: @escaping (_ data: Data) -> Void
    ) -> some View {
        self.onReceive(
            manager.publisher
                .compactMap { event in
                    guard case .data(let data) = event else { return nil }
                    return data
                },
            perform: action
        )
    }
    
    /// Adds an action to perform when this view detects an ``WebSocketPublisher/Event/string(_:)`` event emitted by the given ``WebSocketPublisher``.
    /// - Parameters:
    ///   - manager: The ``WebSocketPublisher`` to listen to (``WebSocketPublisher/publisher``).
    ///   - action: The action to perform when a ``WebSocketPublisher/Event/string(_:)`` event is emitted by `manager`. The event's properties are passed as a parameter to `action`.
    /// - Returns: A view that triggers `action` when `manager` emits an event.
    public func onWebSocketString(
        _ manager: WebSocketPublisher,
        perform action: @escaping (_ string: String) -> Void
    ) -> some View {
        self.onReceive(
            manager.publisher
                .compactMap { event in
                    guard case .string(let string) = event else { return nil }
                    return string
                },
            perform: action
        )
    }
}
