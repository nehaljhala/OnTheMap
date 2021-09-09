//
//  UdacityClient.swift
//  On the Map
//
//  Created by Nehal Jhala on 9/7/21.
//

import Foundation
import CoreLocation

class UdacityClient {
     //make login call:
    public func makeLoginCall(userName: String, password: String, completion: @escaping (_ retResponse: LoginResponse?, _ retError: Error?,_ success: Bool)->Void) {
        
        var request = URLRequest(url: URL(string: "https://onthemap-api.udacity.com/v1/session")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonBody = "{\"udacity\": {\"username\": \"\(userName)\", \"password\": \"\(password)\"}}"
        request.httpBody = jsonBody.data(using: .utf8)
        
        URLSession.shared.dataTask(with: request, completionHandler: {data, response, error in
            do {
                if let error = error {
                    completion(nil, error, false)
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    completion(nil, error, false)
                    return
                }
                let range = 5..<data!.count
                let filteredData = data!.subdata(in: range)
                let resp = try JSONDecoder().decode(LoginResponse.self, from: filteredData)
                completion(resp, nil, true)
                return
                
            }catch let err {
                completion(nil, err, false)
            }
        }).resume()
    }
    
     // get student details to post student location:
    func getStudentDetails (completion: @escaping (_ response: StudentDetails?, _ retError: Error?,_ success: Bool)-> ()){
        var request = URLRequest(url: URL(string: "https://onthemap-api.udacity.com/v1/users/\( globalVars.loginInfo[0].account.key)")!)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            let range = (5..<data!.count)
            let newData = data?.subdata(in: range) /* subset response data! */
            if let data = data {
                do {
                    let resp = try JSONDecoder().decode(StudentDetails.self, from: newData!)
                    completion(resp, nil, true)
                }catch let error {
                    print("api error" + error.localizedDescription)
                    completion(nil, error, false)
                }
            }
        } .resume()
    }

     //posting a student location:
    func postStudentLocation (_ mapString: String, _ mediaURL: String, _ latitude: CLLocationDegrees, _ longitude: CLLocationDegrees, completion: @escaping (_ retError: Error?,_ success: Bool)-> ()){
        var request = URLRequest(url: URL(string: "https://onthemap-api.udacity.com/v1/StudentLocation")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"uniqueKey\": \"\(globalVars.studentDetails[0].key)\", \"firstName\": \"\(globalVars.studentDetails[0].first_name)\", \"lastName\": \"\(globalVars.studentDetails[0].last_name)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaURL)\",\"latitude\": \(latitude), \"longitude\": \(longitude)}".data(using: .utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil {
                completion(error, false)
                return
            }
            completion(nil, true)
        }
        task.resume()
    }
    
     //requesting studentLocation to show annotations:
    func requestLocation(completion: @escaping (_ response: StudentLocation?, _ error: Error?, _ success: Bool)-> ()) {
        let url = URLRequest(url: URL(string: "https://onthemap-api.udacity.com/v1/StudentLocation??limit=100&order=-updatedAt")!)
        URLSession.shared.dataTask(with: url) {data, res, err in
            if let data = data {
                do {
                    let aResponse = try JSONDecoder().decode(StudentLocation.self, from: data)
                    completion(aResponse, nil, true)
                }catch let error {
                    completion(nil, error, false)
                    print("api error" + error.localizedDescription)
                    
                }
            }
        }.resume()
    }                    
                                        
     //log out:
    func logginOut(){
        var request = URLRequest(url: URL(string: "https://onthemap-api.udacity.com/v1/session")!)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil { // Handle error…
                return
            }
            let range = (5..<data!.count)
            let newData = data?.subdata(in: range) /* subset response data! */
            print(String(data: newData!, encoding: .utf8)!)
            DispatchQueue.main.async {
                globalVars.studentDetails.removeAll()
                globalVars.loginInfo.removeAll()
            }
        }
        task.resume()
    }
}

