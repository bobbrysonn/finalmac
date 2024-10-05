//
//  Definitions.swift
//  Based Reviews
//
//  Created by Bob Moriasi on 10/4/24.
//

import Foundation

/// Describes the shape of the course object
struct Course: Codable {
    let id: Int
    let code: String
    let distribs: String?
    let description: String?
    let title: String?
    let layup: Double
    let rating: Double
    let url: String?
}

/// Describes the shape of the token received from /auth/jwt/create
struct JWTToken: Codable {
    let token_type: String
    let exp: Int
    let jti: String
    let email: String
    let username: String
    let iat: Int
    let user_id: Int
}

/// Describes the shape of the user in the app
struct User: Codable {
    let id: Int
    let email: String
    let username: String
    let access: String
    let refresh: String
}
