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
    
    var lat = CLLocationDegrees()
    var lon = CLLocationDegrees()
    var mediaURL = String()
    var mapString = String()
    let client = UdacityClient()
    
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
        //setRegion
        setZoomOnMap(coordinate,  map: mapView)
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
    
    //zoom on region:
    func setZoomOnMap(_ location: CLLocationCoordinate2D, map mapName: MKMapView) {
        var region = MKCoordinateRegion()
        var span1 = MKCoordinateSpan()
        span1.latitudeDelta = 0.002
        span1.longitudeDelta = 0.005
        region.span = span1
        region.center = location
        mapName.setRegion(region, animated: true)
        mapName.regionThatFits(region)
        mapName.isZoomEnabled = true
    }
    
    func postStuLoc(){
        client.postStudentLocation(self.mapString, self.mediaURL, self.lat, self.lon) { (_ retError: Error?,_ success: Bool) in
            DispatchQueue.main.async {
                if success == true{
                    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                    let nextViewController = storyBoard.instantiateViewController(withIdentifier: "tabView") as! UITabBarController
                    nextViewController.modalPresentationStyle = .fullScreen
                    self.present(nextViewController, animated:true, completion:nil)
                    return
                }
                else{
                        let alert = UIAlertController(title:"Unexpected Error", message: retError?.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func finishTapped(_ sender: Any) {
        client.getStudentDetails(){ (_ response: StudentDetails?, _ retError: Error?,_ success: Bool) in
            DispatchQueue.main.async {
                if success == true{
                    globalVars.studentDetails.append(response!)
                    self.postStuLoc()
                }
                else{
                    let alert = UIAlertController(title:"Unexpected Error", message: retError?.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }    
    
    @IBAction func cancelTheView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}


