//
//  PhotoModel.swift
//  TechnicalTest
//
//  Created by Harjeet on 11/03/22.
//

import Foundation

// MARK: - PhotoModel
struct PhotoModel: Codable {
    var id: String?
    var photoModelDescription: String?
    var urls: UrlsModel?
    var user: UserModel?

    enum CodingKeys: String, CodingKey {
        case id
        case photoModelDescription = "description"
        case urls, user
    }
}

// MARK: - Urls
struct UrlsModel: Codable {
    var raw, full, regular, small: String?
    var thumb, smallS3: String?

    enum CodingKeys: String, CodingKey {
        case raw, full, regular, small, thumb
        case smallS3 = "small_s3"
    }
    
    func getAnyOneURL() -> String?{
        return thumb ?? smallS3 ?? small ?? regular ?? full ?? raw
    }
}

// MARK: - User
struct UserModel: Codable {
    var id: String?
    var username, name, firstName, lastName: String?

    enum CodingKeys: String, CodingKey {
        case id
        case username, name
        case firstName = "first_name"
        case lastName = "last_name"
    }
}
