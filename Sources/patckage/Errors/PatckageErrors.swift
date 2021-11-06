//
//  File.swift
//  
//
//  Created by John Patrick Teruel on 11/3/21.
//

import Foundation
public enum PatckageError: Error, LocalizedError {
    case empty
    case serialization
    
    public var errorDescription: String? {
        switch self {
        case .empty:
            return "Empty result"
        case .serialization:
            return "Unable to serialize object."
        }
    }
}
