//
//  WebSocketPublisher+URLSessionDelegate.swift
//  
//
//  Created by Edon Valdman on 9/4/23.
//

import Foundation
import Combine

extension WebSocketPublisher: URLSessionWebSocketDelegate {
    /// This function is called automatically by the delegate system when the WebSocket connection
    /// opens successfully.
    public func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        let event = Event.connected(`protocol`)
        _subject.send(event)
        startListening()
    }
    
    /// This function is called automatically by the delegate system when the WebSocket connection
    /// is closed.
    public func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        defer { clearTaskData() }
        
        let reasonStr = reason != nil ? String(data: reason!, encoding: .utf8) : nil
        _subject.send(.disconnected(closeCode, reasonStr))
    }
}
