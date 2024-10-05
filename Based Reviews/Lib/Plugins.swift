//
//  Plugins.swift
//  Based Reviews
//
//  Created by Bob Moriasi on 10/5/24.
//

import Foundation
import Moya
import Cache

// Define type aliases for clarity
typealias CacheKey = String
typealias CacheValue = Data

final class CachePlugin: PluginType {
    private let cache: Storage<CacheKey, CacheValue>
    
    init(cache: Storage<CacheKey, CacheValue>) {
        self.cache = cache
    }
    
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        return request
    }
    
    func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        switch result {
        case .success(let response):
            // Create cache key
            let key = cacheKey(for: target)
            
            // Attempt to cache
            do {
                try cache.setObject(response.data, forKey: key)
                print("Cached response for key: \(key)")
            } catch {
                print("Failed to cache response: \(error)")
            }
        case .failure:
            print("Request failed for target: \(target)")
        }
    }
    
    private func cacheKey(for target: TargetType) -> CacheKey {
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
}



