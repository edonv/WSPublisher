//
//  WSPublisher.swift
//  
//
//  Created by Edon Valdman on 7/8/22.
//

import Foundation
import Combine

import HTTPTypes
import HTTPTypesFoundation

/// Wraps around a subscribable [Publisher](https://developer.apple.com/documentation/combine/publisher)
/// for connection over WebSocket.
public class WebSocketPublisher: NSObject {
    /// The `URLRequest` used for creating an `URLSession` to start a connection.
    public var urlRequest: URLRequest? = nil
    
    /// The [URLSessionWebSocketTask](https://developer.apple.com/documentation/foundation/urlsessionwebsockettask)
    /// containing the active connection, when there is one.
    public private(set) var webSocketTask: URLSessionWebSocketTask? = nil
    
    /// Used for storing active `Combine` [Cancellable](https://developer.apple.com/documentation/combine/cancellable)s.
    private var observers = Set<AnyCancellable>()
    
    /// The (Subject)[https://developer.apple.com/documentation/combine/subject] that publishes all received ``WebSocketPublisher/Event``s.
    internal let _subject = CurrentValueSubject<Event, Never>(.publisherCreated)
    
    /// Returns the internal [Publisher](https://developer.apple.com/documentation/combine/publisher) (really a
    /// [CurrentValueSubject](https://developer.apple.com/documentation/combine/currentvaluesubject)) as an
    /// [AnyPublisher](https://developer.apple.com/documentation/combine/anypublisher).
    /// 
    /// Maintains clear and consistent terminology, and removes the possibility of developers sending
    /// values to the subject.
    public var publisher: AnyPublisher<Event, Never> {
        _subject.eraseToAnyPublisher()
    }
    
    /// Returns whether or not there is an active WebSocket connection.
    public var isConnected: Bool {
        get {
            webSocketTask != nil
        }
    }
    
    public override init() {
        super.init()
    }
    
    /// Creates and starts a WebSocket connection.
    /// - Parameter request: The connection data to connect to.
    public func connect(with request: URLRequest, headers: HTTPFields? = nil) {
        var req = request.httpRequest!
        if let headers {
            req.headerFields = headers
        }
        
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        webSocketTask = session.webSocketTask(with: URLRequest(httpRequest: req)!)
        
        webSocketTask?.resume()
        self.urlRequest = request
    }
    
    /// Creates and starts a WebSocket connection.
    /// - Parameter url: The `URL` to connect to.
    public func connect(with url: URL, headers: HTTPFields? = nil) {
        connect(with: URLRequest(url: url), headers: headers)
    }
    
    /// Disconnects from ``WebSocketPublisher/webSocketTask``, if there is an active connection.
    /// - Parameters:
    ///   - closeCode: [URLSessionWebSocketTask.CloseCode](https://developer.apple.com/documentation/foundation/urlsessionwebsockettask/closecode) representation of reason for disconnecting.
    ///   - reason: `String` representation of reason for disconnecting.
    public func disconnect(with closeCode: URLSessionWebSocketTask.CloseCode? = nil, reason: String? = nil) {
        // No need to add a gaurd statement, because if one isn't active, webSocketTask will be nil.
        // If it's nil, calling cancel(with:reason:) using optional chaining will do nothing.
        webSocketTask?.cancel(with: closeCode ?? .normalClosure,
                              reason: (reason ?? "Closing connection").data(using: .utf8))
        clearTaskData()
    }
    
    /// Cleans up properties after closing a connection.
    internal func clearTaskData() {
        webSocketTask = nil
        urlRequest = nil
        observers.forEach { $0.cancel() }
    }
    
    /// Confirms that there is an active connection, unwrapping ``WebSocketPublisher/webSocketTask``.
    /// - Throws: ``WebSocketPublisher/Errors/noActiveConnection`` if there isn't an active connection.
    /// - Returns: An unwrapped ``WebSocketPublisher/webSocketTask``.
    internal func confirmConnection() throws -> URLSessionWebSocketTask {
        guard let task = webSocketTask else { throw Errors.noActiveConnection }
        return task
    }
    
    /// Confirms that there is an active connection, unwrapping ``WebSocketPublisher/webSocketTask``.
    /// - Throws: ``WebSocketPublisher/Errors/noActiveConnection`` if there isn't an active connection.
    /// - Returns: An unwrapped ``WebSocketPublisher/webSocketTask``.
    internal func wsTaskPublisher() -> AnyPublisher<URLSessionWebSocketTask, Error> {
        do {
            return Just(try confirmConnection())
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: Errors.noActiveConnection)
                .eraseToAnyPublisher()
        }
    }
    
//    private var messageBuffer = [URLSessionWebSocketTask.Message]() {
//        didSet {
//            guard let messageToSend = messageBuffer.first else { return }
//            // send messageToSend
//            messageBuffer.removeFirst()
//        }
//    }
//
//    private func buffer(message: URLSessionWebSocketTask.Message) {
//        messageBuffer.append(message)
//    }
    
    /// Private encapsulation for sending a
    /// [URLSessionWebSocketTask.Message](https://developer.apple.com/documentation/foundation/urlsessionwebsockettask/message) to
    /// the connected WebSocket server/host.
    /// - Parameter message: The [URLSessionWebSocketTask.Message](https://developer.apple.com/documentation/foundation/urlsessionwebsockettask/message) to send.
    /// - Throws: ``WebSocketPublisher/Errors/noActiveConnection`` if there isn't an active connection.
    /// - Returns: A [Publisher](https://developer.apple.com/documentation/combine/publisher) without any value, signalling the
    /// message has been sent.
    private func send(_ message: URLSessionWebSocketTask.Message) -> AnyPublisher<Void, Error> {
//        buffer(message: message)
//        Publishers.Debounce(upstream: <#T##_#>, dueTime: <#T##_.SchedulerTimeType.Stride#>, scheduler: <#T##_#>, options: <#T##_.SchedulerOptions?#>)

        return wsTaskPublisher()
            .flatMap { $0.send(message) }
            .delay(
               for: .seconds(1),
               tolerance: .seconds(0.5),
               scheduler: DispatchQueue.main
            )
            .eraseToAnyPublisher()
    }
    
    /// Sends a `String` message to the connected WebSocket server/host.
    /// - Parameter message: The `String` message to send.
    /// - Throws: ``WebSocketPublisher/Errors/noActiveConnection`` if there isn't an active connection.
    /// - Returns: A [Publisher](https://developer.apple.com/documentation/combine/publisher) without any value, signalling the
    /// message has been sent.
    public func send(_ message: String) -> AnyPublisher<Void, Error> {
        return send(.string(message))
    }
    
    /// Sends a `Data` message to the connected WebSocket server/host.
    /// - Parameter message: The `Data` message to send.
    /// - Throws: ``WebSocketPublisher/Errors/noActiveConnection`` if there isn't an active connection.
    /// - Returns: A [Publisher](https://developer.apple.com/documentation/combine/publisher) without any value, signalling the
    /// message has been sent.
    public func send(_ message: Data) -> AnyPublisher<Void, Error> {
        return send(.data(message))
    }
    
    /// Sends a ping to the connected WebSocket server/host.
    /// - Throws: ``WebSocketPublisher/Errors/noActiveConnection`` if there isn't an active connection.
    /// - Returns: A [Publisher](https://developer.apple.com/documentation/combine/publisher) without any value, signalling the
    /// ping has been sent.
    public func ping() -> AnyPublisher<Void, Error> {
        return wsTaskPublisher()
            .flatMap { $0.sendPing() }
            .eraseToAnyPublisher()
    }
    
    /// Starts the recursive listening loop.
    ///
    /// Due to [URLSessionWebSocketTask](https://developer.apple.com/documentation/foundation/urlsessionwebsockettask) stopping its listening after receiving a single message, the listening loop recursively calls itself upon successfully completing. If it completes with a failure, it doesn't call itself again.
    internal func startListening() {
        guard let task = webSocketTask else { return }
        
        task.receiveOnce()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] result in
                switch result {
                case .finished:
                    self?.startListening()
                case .failure(let err):
                    self?._subject.send(.disconnected(.abnormalClosure, err.localizedDescription))
                    self?.clearTaskData()
                }
            }, receiveValue: { [weak self] message in
                switch message {
                case .data(let d):
                    self?._subject.send(.data(d))
                case .string(let str):
                    self?._subject.send(.string(str))
                @unknown default:
                    self?._subject.send(.generic(message))
                }
            })
            .store(in: &observers)
    }
}
