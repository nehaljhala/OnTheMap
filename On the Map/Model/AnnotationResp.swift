//
//  AnnotationResp.swift
//  On the Map
//
//  Created by Nehal Jhala on 9/3/21.
//

import Foundation



struct AnnotationResponse: Codable {
    var results: [Pin]
}
struct Pin: Codable {
    var firstName: String
    var lastName: String
    var latitude: Double
    var longitude: Double
    var mapString: String
    var mediaURL: String
    var uniqueKey: String
    var objectId: String
    var createdAt: String
    var updatedAt: String
    
}


struct LoginResponse: Codable {
    var session: Session
    var account: Account
}
struct Session: Codable {
    var id: String
    var expiration: String
}
struct Account: Codable{
    var key: String
    var registered: Bool
}
