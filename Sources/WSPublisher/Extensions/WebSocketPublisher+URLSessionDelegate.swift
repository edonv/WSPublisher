//
//  WebSocketPublisher+URLSessionDelegate.swift
//  
//
//  Created by Edon Valdman on 9/4/23.
//

import Foundation
import Combine

import HTTPTypesFoundation

extension WebSocketPublisher: URLSessionWebSocketDelegate {
    /// This function is called automatically by the delegate system when the WebSocket connection
    /// opens successfully.
    public func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        let headers = webSocketTask.httpResponse?.headerFields ?? [:]
        _subject.send(.connected(`protocol`, upgradeHeaders: headers))
        startListening()
    }
    
    /// This function is called automatically by the delegate system when the WebSocket connection
    /// is closed.
    public func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        defer { clearTaskData() }
        
        let reasonStr = reason != nil ? String(data: reason!, encoding: .utf8) : nil
        _subject.send(.disconnected(closeCode, reasonStr))
    }
    
    /// This function is called automatically by the delegate system when the WebSocket connection disconnected without a close code.
    public func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didCompleteWithError error: (any Error)?
    ) {
        guard task == self.webSocketTask,
              let error = error as? NSError else { return }
        
        defer { clearTaskData() }
        
        // This is what is received when connected server closes abruptly without sending a close code first.
        if error.domain == NSPOSIXErrorDomain
            && error.code == 57
            && error.userInfo[NSURLErrorFailingURLErrorKey] as? URL == task.originalRequest?.url {
            _subject.send(.disconnected(.abnormalClosure, "Server closed without a close code."))
        } else if let urlError = error as? URLError {
            _subject.send(.disconnected(urlError))
        } else {
            _subject.send(.disconnected(error))
        }
    }
}
