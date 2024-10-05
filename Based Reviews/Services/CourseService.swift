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
import Cache

class CourseService {
    // Provider and cache
    private let provider: MoyaProvider<CourseServiceApi>
    private let cache: Storage<CacheKey, CacheValue>
    
    init() {
        let diskConfig = DiskConfig(
            name: "MoyaCache",
            expiry: .seconds(432000),
            maxSize: 10_000_000 // 10 MB
        )
        let memoryConfig = MemoryConfig(
            expiry: .seconds(300),
            countLimit: 100,
            totalCostLimit: 10_000_000
        )
        do {
            self.cache = try Storage<CacheKey, CacheValue>(
                diskConfig: diskConfig,
                memoryConfig: memoryConfig,
                fileManager: .default,
                transformer: TransformerFactory.forData()
            )
        } catch {
            fatalError("Failed to initialize cache: \(error)")
        }
        
        self.provider = MoyaProvider<CourseServiceApi>(plugins: [CachePlugin(cache: cache)])
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
        let key = cacheKey(for: target)
        
        if let cachedData = try? cache.object(forKey: key) {
            do {
                let results = try JSONDecoder().decode(T.self, from: cachedData)
                print("Returning cached data")
                completion(.success(results))
                return
            } catch let error {
                completion(.failure(error))
            }
        }
        
        print("Did not find cached data, requesting data")
        
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
    
    private func cacheKey(for target: CourseServiceApi) -> CacheKey {
        var key = "\(target.method.rawValue)-\(target.path)"
        
        switch target.task {
        case .requestParameters(let parameters, _):
            let sortedParameters = parameters.sorted { $0.key < $1.key }
            let paramsString = sortedParameters.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
            key += "?\(paramsString)"
        default:
            break
        }
        
        return key
    }
    
    func clearCache() {
        do {
            try cache.removeAll()
        } catch {
            print("Failed to clear cache: \(error)")
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
