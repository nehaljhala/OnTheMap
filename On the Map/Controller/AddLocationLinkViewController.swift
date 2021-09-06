//
//  AddLocationLinkViewController.swift
//  On the Map
//
//  Created by Nehal Jhala on 8/17/21.
//

import UIKit
import MapKit

class AddLocationLinkViewController: UIViewController,  MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!    
    @IBOutlet weak var finishButton: UIButton!
    
    struct Response: Codable{
        var first_name: String
        var last_name: String
        var key: String
    }
    
    var lat = CLLocationDegrees()
    var lon = CLLocationDegrees()
    var mediaURL = String()
    var mapString = String()
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.isUserInteractionEnabled = true
        mapView.isScrollEnabled = true
        mapView.isZoomEnabled = true
        mapView.delegate = self
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = mediaURL
        self.mapView.addAnnotations([annotation])
    }
   
    
    //MapViewDelegate:
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
   
    
    //posting a student location:
    func postStudentLocation (_ resp: Response, completion: @escaping ()-> ()){
        var request = URLRequest(url: URL(string: "https://onthemap-api.udacity.com/v1/StudentLocation")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"uniqueKey\": \"\(resp.key)\", \"firstName\": \"\(resp.first_name)\", \"lastName\": \"\(resp.last_name)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaURL)\",\"latitude\": \(lat), \"longitude\": \(lon)}".data(using: .utf8)
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil {
                return
            }
            completion()
        }
        task.resume()
    }
    
    //get student details:
    func getStudentDetails (completion: @escaping (Response)-> ()){
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        
        var request = URLRequest(url: URL(string: "https://onthemap-api.udacity.com/v1/users/\( appDelegate.loginInfo[0].account.key)")!)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            let range = (5..<data!.count)
            let newData = data?.subdata(in: range) /* subset response data! */
            if let data = data {
                do {
                    let resp = try JSONDecoder().decode(Response.self, from: newData!)
                    completion(resp)
                }catch let error {
                    print("api error" + error.localizedDescription)
                }
            }
        } .resume()
    }

    
    @IBAction func finishTapped(_ sender: Any) {
        //update the info and than segue
        getStudentDetails(){ (resp) in
            self.postStudentLocation(resp) { () in
                DispatchQueue.main.async {
                    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                    let nextViewController = storyBoard.instantiateViewController(withIdentifier: "tabView") as! UITabBarController
                    nextViewController.modalPresentationStyle = .fullScreen
                    self.present(nextViewController, animated:true, completion:nil)
                    return
                }
            }
        }
    }
  
    
    @IBAction func cancelTheView(_ sender: Any) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "tabView") as! UITabBarController
        nextViewController.modalPresentationStyle = .fullScreen
        self.present(nextViewController, animated:true, completion:nil)
        return
    }
    
  
    
}

