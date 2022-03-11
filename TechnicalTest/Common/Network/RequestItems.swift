//
//  RequestItems.swift
//  TechnicalTest
//
//  Created by Harjeet on 11/03/22.
//

import Foundation
import Alamofire

public enum RequestItemsType {
    case fetchPhotos
}

//MARK: - Extension
extension RequestItemsType: EndPointType {
    public var baseURL: String {
        switch RequestManager.networkEnvironment {
        case .dev: return "https://api.unsplash.com"
        case .production: return "https://api.unsplash.com"
        case .stage: return "https://api.unsplash.com"
        }
    }
    
    public var folderPath: String {
        return ""
    }
    
    public var version: String {
        return ""
    }
    
    public var path: String {
        switch self {
        
        case .fetchPhotos:
            return "/photos"
        }
    }
    // if your api is having httpMethod type get then return .get else .post
    public var httpMethod: HTTPMethod {
        switch self {
        
        case .fetchPhotos:
            return .get
        }
    }
    
    public var headers: HTTPHeaders? {
        switch self {
        default:
            return ["Content-Type": "application/json",
                    "X-Requested-With": "XMLHttpRequest"]
        }
    }
    
    public var url: URL {
        switch self {
        default:
            return URL(string: self.baseURL + self.folderPath + self.version + self.path)!
        }
    }
    
    public var encoding: ParameterEncoding {
        switch self {
        default:
            return JSONEncoding.default
        }
    }
}
