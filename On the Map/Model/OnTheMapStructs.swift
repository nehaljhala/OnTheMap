//
//  LoginResponse.swift
//  On the Map
//
//  Created by Nehal Jhala on 9/7/21.
//

import Foundation

//JSON Parsing structs for Login Service
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

//JSON Parsing structs for getStudentDetails
struct StudentDetails: Codable{
    var first_name: String
    var last_name: String
    var key: String
}

//JSON Parsing structs for Student Locations
struct StudentLocation: Codable {
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

struct GlobalVars{
    var studentDetails = [StudentDetails]()
    var loginInfo = [LoginResponse]()
    var studentLoc = [StudentLocation]()
}
var globalVars = GlobalVars()

