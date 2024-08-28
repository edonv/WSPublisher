//
//  URLSessionWebSocketTaskCloseCode+StringConvertible.swift
//
//
//  Created by Edon Valdman on 6/21/24.
//

import Foundation

extension URLSessionWebSocketTask.CloseCode: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        return "\(_caseName) (\(rawValue))"
    }
    
    private var _caseName: String {
        switch self {
        case .invalid:
            return "invalid"
        case .normalClosure:
            return "normalClosure"
        case .goingAway:
            return "goingAway"
        case .protocolError:
            return "protocolError"
        case .unsupportedData:
            return "unsupportedData"
        case .noStatusReceived:
            return "noStatusReceived"
        case .abnormalClosure:
            return "abnormalClosure"
        case .invalidFramePayloadData:
            return "invalidFramePayloadData"
        case .policyViolation:
            return "policyViolation"
        case .messageTooBig:
            return "messageTooBig"
        case .mandatoryExtensionMissing:
            return "mandatoryExtensionMissing"
        case .internalServerError:
            return "internalServerError"
        case .tlsHandshakeFailure:
            return "tlsHandshakeFailure"
        @unknown default:
            return "Unknown close code"
        }
    }
    
    public var debugDescription: String {
        return "\(_caseName)/\(rawValue) (\(_detail))"
    }
    
    private var _detail: String {
        switch self {
        case .abnormalClosure:
            return "The connection closed without a close control frame."
        case .goingAway:
            return "An endpoint went away."
        case .internalServerError:
            return "The server terminated the connection because it encountered an unexpected condition."
        case .invalid:
            return "The connection is still open."
        case .invalidFramePayloadData:
            return "The server terminated the connection because it received data inconsistent with the message's type."
        case .mandatoryExtensionMissing:
            return "The client terminated the connection because the server didn't negotiate a required extension."
        case .messageTooBig:
            return "An endpoint terminated the connection because it received a message too big for it to process."
        case .noStatusReceived:
            return "An endpoint expected a status code and didn't receive one."
        case .normalClosure:
            return "Normal connection closure."
        case .policyViolation:
            return "An endpoint terminated the connection because it received a message that violates its policy."
        case .protocolError:
            return "An endpoint terminated the connection due to a protocol error."
        case .tlsHandshakeFailure:
            return "The connection failed to perform a TLS handshake."
        case .unsupportedData:
            return "An endpoint terminated the connection after receiving a type of data it can't accept."
        @unknown default:
            return "Unknown close code."
        }
    }
}
