//
//  URLSessionWebSocketTask+Async.swift
//  
//
//  Created by Edon Valdman on 9/4/23.
//

import Foundation

extension URLSessionWebSocketTask {
    /// Wraps [URLSessionWebSocketTask.sendPing(pongReceiveHandler:)](https://developer.apple.com/documentation/foundation/urlsessionwebsockettask/3181206-sendping)
    /// in an async function.
    /// - Throws: Fails if an error occurs while sending ping.
    /// - Returns: `Void`, the response pong had been received.
    public func sendPing() async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            self.sendPing { error in
                if let err = error {
                    continuation.resume(throwing: err)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }
}
