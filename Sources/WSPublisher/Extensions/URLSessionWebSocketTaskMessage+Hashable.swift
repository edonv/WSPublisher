//
//  URLSessionWebSocketTaskMessage+Hashable.swift
//
//
//  Created by Edon Valdman on 6/21/24.
//

import Foundation

extension URLSessionWebSocketTask.Message: Hashable {
    private var comparisonValue: AnyHashable {
        switch self {
        case .data(let d):
            return d as AnyHashable
        case .string(let s):
            return s as AnyHashable
            
        @unknown default:
            return self as AnyHashable
        }
    }
    
    public static func == (lhs: URLSessionWebSocketTask.Message, rhs: URLSessionWebSocketTask.Message) -> Bool {
        lhs.comparisonValue == rhs.comparisonValue
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.comparisonValue)
    }
}
