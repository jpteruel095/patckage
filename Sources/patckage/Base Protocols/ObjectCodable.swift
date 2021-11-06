//
//  File.swift
//  
//
//  Created by John Patrick Teruel on 11/3/21.
//

import Foundation

public protocol ObjectCodable: Codable {
}

extension ObjectCodable {
    public init(from dictionary: [String: Any]) throws {
        let json = try JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted)
        
        let decoder = JSONDecoder()
        self = try decoder.decode(Self.self, from: json)
    }
    public func toDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            throw PatckageError.serialization
        }
        return dictionary
    }
    
    public func toJson() throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(self)
        guard let string = String(data: data, encoding: .utf8) else {
            throw PatckageError.serialization
        }
        return string
    }
}
