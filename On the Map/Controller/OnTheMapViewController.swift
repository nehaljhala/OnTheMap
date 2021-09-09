//
//  OnTheMapViewController.swift
//  On the Map
//
//  Created by Nehal Jhala on 4/19/21.
//

import UIKit
import MapKit

class OnTheMapViewController: UIViewController,  MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    var annotations = [MKPointAnnotation]()
    let client = UdacityClient()
    
    override func viewDidLoad() {
        tabBarController?.tabBar.isHidden = false
        mapView.isUserInteractionEnabled = true
        mapView.isScrollEnabled = true
        mapView.isZoomEnabled = true
        mapView.delegate = self
        pinchToZoom()
        fetchLocStudents()
    }
    
    //Pinch Gesture for Mapview:
    func pinchToZoom(){
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(didPinch))
        mapView.addGestureRecognizer(pinchGesture)
    }
    @objc func didPinch(_ gesture: UIPinchGestureRecognizer){
        if gesture.state == .changed{
            let scale = gesture.scale
        }
    }
    
    //annotations:
    func showAnnotations(_ response: StudentLocation?){
        for dictionary in response!.results {
            let lat = CLLocationDegrees(dictionary.latitude)
            let long = CLLocationDegrees(dictionary.longitude)
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            let first = dictionary.firstName
            let last = dictionary.lastName
            let mediaURL = dictionary.mediaURL
            // Here we create the annotation and set its coordiate, title, and subtitle properties:
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(first) \(last)"
            annotation.subtitle = mediaURL
            annotations.append(annotation)
        }
        self.mapView.addAnnotations(annotations)
    }
    
    func fetchLocStudents(){
        client.requestLocation() { (_ response: StudentLocation?, _ error: Error?, _ success: Bool) in
            DispatchQueue.main.async {
                if success == true{
                    globalVars.studentLoc.removeAll()
                    globalVars.studentLoc.append(response!)
                    self.showAnnotations(response)
                }
                else{
                    let alert = UIAlertController(title:"Unexpected Error", message: error?.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    func verifyUrl (urlString: String?) -> Bool {
        if let urlString = urlString {
            if let url = URL(string: urlString) {
                return UIApplication.shared.canOpenURL(url as URL)
            }
        }
        return false
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
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        print("at no 1")
        if control == view.rightCalloutAccessoryView {
            print("at no 2")
            if !verifyUrl(urlString: view.annotation?.subtitle!) {
                print("at no 3")
                return
            }
            print("at no 4")
            if var toOpen = view.annotation?.subtitle! {
                print("at no 5")
                if !toOpen.starts(with: "http"){
                    toOpen = "http://" + toOpen
                }
                print(URL(string: toOpen)!)
                print("at no 7")
                UIApplication.shared.open(URL(string: toOpen)!, options: [:], completionHandler: nil)
            }
        }
    }
    
    @IBAction func addButtonTapped(_ sender: Any) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "addloclink") as! InformationPostingViewController
        nextViewController.modalPresentationStyle = .fullScreen
        self.present(nextViewController, animated:true, completion:nil)
        return
    }
    
    @IBAction func logoutTapped(_ sender: Any) {
        client.logginOut()
        //segue to loginViewController.
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func refreshTapped(_ sender: Any) {
        fetchLocStudents()
    }
    
    @IBAction func addLink(_ sender: Any) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "addloclink") as! InformationPostingViewController
        nextViewController.modalPresentationStyle = .fullScreen
        self.present(nextViewController, animated:true, completion:nil)
        return
    }
    
}


