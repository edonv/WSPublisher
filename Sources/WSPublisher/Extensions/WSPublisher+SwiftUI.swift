//
//  WSPublisher+SwiftUI.swift
//  
//
//  Created by Edon Valdman on 9/4/23.
//

import SwiftUI
import Combine

extension View {
    public func onWebSocketEvent(
        _ manager: WebSocketPublisher,
        perform action: @escaping (WebSocketPublisher.WSEvent) -> Void
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
