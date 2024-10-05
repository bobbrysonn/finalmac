//
//  CourseService.swift
//  Based Reviews
//
//  Created by Bob Moriasi on 10/4/24.
//

import Foundation
import Factory
import Moya
import Alamofire

class CourseService {
    // Get provider
    private var provider: MoyaProvider<CourseServiceApi> {
        // Caching
        let cache = URLCache(memoryCapacity: 4*1024*1024, diskCapacity: 20*1024*1024, diskPath: "moya_cache")
        
        // Configure URLSessionConfiguration
        let configuration = URLSessionConfiguration.default
        configuration.urlCache = cache
        configuration.requestCachePolicy = .useProtocolCachePolicy

        // Initialize Alamofire's Session with the configuration
        let session = Session(configuration: configuration)
        
        // Return provider
        return MoyaProvider<CourseServiceApi>(session: session)
    }
    
    // Fetch courses by title
    func fetchCoursesByTitle(query: String, completion: @escaping (Result<[Course], Error>) -> ()) {
        request(target: .fetchCoursesByTitle(title: query), completion: completion)
    }
}

// Add course service to container
extension Container {
    var courseService: Factory<CourseService> {
        Factory(self) { CourseService() }
    }
}

extension CourseService {
    private func request<T: Decodable>(target: CourseServiceApi, completion: @escaping (Result<T, Error>) -> ()) {
        provider.request(target) { result in
            switch result {
            case let .success(response):
                do {
                    let results = try JSONDecoder().decode(T.self, from: response.data)
                    completion(.success(results))
                } catch let error {
                    completion(.failure(error))
                }
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}

enum CourseServiceApi {
    case fetchCoursesByTitle(title: String)
}

extension CourseServiceApi: TargetType {
    var baseURL: URL {
        .init(string: "https://layup-dc04e13572eb.herokuapp.com")!
    }
    
    var path: String {
        switch self {
        case let .fetchCoursesByTitle(name):
            return "/api/findcourse/\(name)/"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .fetchCoursesByTitle:
            return .get
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .fetchCoursesByTitle:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        // Retrieve user from userdefaults
        if let user: User = retrieveFromUserDefaults(forKey: "user") {
            return [
                "Authorization": "JWT \(user.access)",
                "Content-Type": "application/json"
            ]
        } else {
            return [
                "Content-Type": "application/json"
            ]
        }
    }
}
