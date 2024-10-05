//
//  AuthService.swift
//  Based Reviews
//
//  Created by Bob Moriasi on 10/3/24.
//

import Foundation
import Moya
import SwiftUI
import Factory

class AuthService {
    private let provider = MoyaProvider<AuthServiceApi>()
    
    // Track errors
    var error: String = ""
    
    func signIn(email: String, password: String) {
        provider.request(.login(email: email, password: password)) { result in
            switch result {
            case .success(let response):
                if let decodedResponse = try? JSONDecoder().decode(LoginResponse.self, from: response.data) {
                    self.error = ""
                    
                    // Decode token, set user to local storage
                    if let decodedToken = try? decode(jwtToken: decodedResponse.access) {
                        let user = User(id: decodedToken["user_id"] as! Int, email: decodedToken["email"] as! String, username: decodedToken["username"] as! String, access: decodedResponse.access, refresh: decodedResponse.refresh )
                        
                        // Save
                        saveToUserDefaults(user, forKey: "user")
                        UserDefaults.standard.set(true, forKey: "isLoggedIn")
                    }
                } else {
                    if response.statusCode == 401 {
                        self.error = "Invalid credentials"
                    }
                }
            case .failure(let error):
                print("Login failed: \(error.localizedDescription)")
            }
        }
    }
}

// Add auth service to factory
extension Container {
    var authService: Factory<AuthService> {
        Factory(self) { AuthService() }
    }
}

enum AuthServiceApi {
    case login(email: String, password: String)
    case fetchDepartments(token: String)
}

extension AuthServiceApi: TargetType {
    var baseURL: URL { .init(string: "https://layup-dc04e13572eb.herokuapp.com")! }
    
    var path: String {
        switch self {
        case .login:
            return "/auth/jwt/create/"
        case .fetchDepartments:
            return "/api/departments/"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .login:
            return .post
        case .fetchDepartments:
            return .get
        }
    }
    
    var task: Moya.Task {
        switch self {
        case let .login(email, password):
            return .requestParameters(parameters: ["email": email, "password": password], encoding: JSONEncoding.default)
        case let .fetchDepartments(token):
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .login:
            return ["Content-Type": "application/json"]
        case let .fetchDepartments(token):
            return ["Authorization": "JWT \(token)"]
        }
    }
}

struct LoginResponse: Codable {
    let access: String
    let refresh: String
}
