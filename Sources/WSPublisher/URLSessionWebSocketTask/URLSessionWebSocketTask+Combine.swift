//
//  URLSessionWebSocketTask+Combine.swift
//  
//
//  Created by Edon Valdman on 9/4/23.
//

import Foundation
import Combine

extension URLSessionWebSocketTask {
    /// Wraps [URLSessionWebSocketTask.send(_:completionHandler:)](https://developer.apple.com/documentation/foundation/urlsessionwebsockettask/3281790-send)
    /// in a [Future](https://developer.apple.com/documentation/combine/future).
    /// - Parameter message: The [URLSessionWebSocketTask.Message](https://developer.apple.com/documentation/foundation/urlsessionwebsockettask/Message) to send.
    /// - Returns: A [Future](https://developer.apple.com/documentation/combine/future) without any value, signalling
    /// the message has been sent. Fails if an error occurs.
    public func send(_ message: Message) -> Future<Void, Error> {
        return Future { promise in
            self.send(message) { error in
                if let err = error {
                    promise(.failure(err))
                } else {
                    promise(.success(()))
                }
            }
        }
    }
    
    /// Wraps [URLSessionWebSocketTask.sendPing(pongReceiveHandler:)](https://developer.apple.com/documentation/foundation/urlsessionwebsockettask/3181206-sendping)
    /// in a [Future](https://developer.apple.com/documentation/combine/future).
    /// - Returns: A [Future](https://developer.apple.com/documentation/combine/future) without any value, signalling
    /// the response pong had been received. Fails if an error occurs.
    public func sendPing() -> Future<Void, Error> {
        return Future { promise in
            self.sendPing { error in
                if let err = error {
                    promise(.failure(err))
                } else {
                    promise(.success(()))
                }
            }
        }
    }
    
    /// Wraps [URLSessionWebSocketTask.receive(completionHandler:)](https://developer.apple.com/documentation/foundation/urlsessionwebsockettask/3281789-receive)
    /// in a [Future](https://developer.apple.com/documentation/combine/future).
    /// - Returns: A  [Future](https://developer.apple.com/documentation/combine/future) containing a received
    /// [URLSessionWebSocketTask.Message](https://developer.apple.com/documentation/foundation/urlsessionwebsockettask/Message),
    /// completing when a message has been received. Fails if an error occurs while waiting to receive the next message.
    public func receiveOnce() -> Future<URLSessionWebSocketTask.Message, Error> {
        return Future { promise in
            self.receive(completionHandler: promise)
        }
    }
}
