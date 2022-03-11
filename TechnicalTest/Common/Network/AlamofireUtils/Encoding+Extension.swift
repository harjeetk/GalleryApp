//
//  Encoding+Extension.swift
//  TechnicalTest
//
//  Created by Harjeet on 11/03/22.
//

import Foundation
import Alamofire

extension String: ParameterEncoding {
    
    // MARK: - Public Methods
    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var request = try urlRequest.asURLRequest()
        request.httpBody = data(using: .utf8, allowLossyConversion: false)
        return request
    }
    
}
