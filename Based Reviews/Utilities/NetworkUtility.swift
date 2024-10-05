//
//  NetworkUtility.swift
//  Based Reviews
//
//  Created by Bob Moriasi on 10/4/24.
//

import Foundation

/// Decodes a jwt token
///
/// - Parameter jwtToken: The jwt string to decode
///
/// - Returns: The decoded jwt in dictionary form
func decode(jwtToken jwt: String) throws -> [String: Any] {

    enum DecodeErrors: Error {
        case badToken
        case other
    }

    func base64Decode(_ base64: String) throws -> Data {
        let base64 = base64
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        let padded = base64.padding(toLength: ((base64.count + 3) / 4) * 4, withPad: "=", startingAt: 0)
        guard let decoded = Data(base64Encoded: padded) else {
            throw DecodeErrors.badToken
        }
        return decoded
    }

    func decodeJWTPart(_ value: String) throws -> [String: Any] {
        let bodyData = try base64Decode(value)
        let json = try JSONSerialization.jsonObject(with: bodyData, options: [])
        guard let payload = json as? [String: Any] else {
            throw DecodeErrors.other
        }
        return payload
    }

    let segments = jwt.components(separatedBy: ".")
    return try decodeJWTPart(segments[1])
}

/// Saves provided object to user defaults
///
/// - Parameters:
///   - value: The object to save
///   - forKey: The key to save object with
func saveToUserDefaults<T: Codable>(_ value: T, forKey key: String) {
    if let encoded = try? JSONEncoder().encode(value) {
        UserDefaults.standard.set(encoded, forKey: key)
    }
}

/// Retrieves provided object to user defaults
///
/// - Parameters:
///   - forKey: The key to retrieve object with
func retrieveFromUserDefaults<T: Codable>(forKey key: String) -> T? {
    if let encoded = UserDefaults.standard.data(forKey: key) {
        if let decoded = try? JSONDecoder().decode(T.self, from: encoded) {
            return decoded
        }
    }
    return nil
}
