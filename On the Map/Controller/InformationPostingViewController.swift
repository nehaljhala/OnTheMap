//
//  InformationPostingViewController.swift
//  On the Map
//
//  Created by Nehal Jhala on 8/17/21.
//

import UIKit
import CoreLocation

class InformationPostingViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var locationTF: UITextField!
    @IBOutlet weak var linkTF: UITextField!
    @IBOutlet weak var findLocationButton: UIButton!
    
    var coord = CLLocationCoordinate2D()
    var lat = CLLocationDegrees(0)
    var lon = CLLocationDegrees(0)
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        subscribeToKeyboardNotifications()
    }
    
    
    //keyboard settings
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    @objc func keyboardWillShow(_ notification:Notification) {
    }
    @objc func keyboardWillHide(_notification:Notification) {
    }
     // For pressing return on the keyboard to dismiss keyboard:
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        locationTF.resignFirstResponder()
        linkTF.resignFirstResponder()
        return true
    }
    
    
    @IBAction func findLocationTapped(_ sender: Any) {
        locationTF.resignFirstResponder()
        linkTF.resignFirstResponder()
        if (linkTF.text!).isEmpty == false || (locationTF.text!).isEmpty == false {
            let geocoder = CLGeocoder()
            geocoder.geocodeAddressString(locationTF.text!) {
                placemarks, error in
                let placemark = placemarks?.first
                self.coord = (placemark?.location?.coordinate)!
                self.lat = CLLocationDegrees((placemark?.location?.coordinate.latitude)!)
                self.lon = CLLocationDegrees((placemark?.location?.coordinate.longitude)!)
                 //segue to nextViewController:
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                let nextViewController = (storyBoard.instantiateViewController(withIdentifier: "submit") as! AddLocationLinkViewController)
                nextViewController.modalPresentationStyle = .fullScreen
                nextViewController.mapString = self.locationTF.text!
                nextViewController.lat = self.lat
                nextViewController.lon = self.lon
                nextViewController.mediaURL = self.linkTF.text!
                self.present(nextViewController, animated:true, completion:nil)
            }
            return
        }
        else {
            let alert = UIAlertController(title:"Ooops", message: "Incomplete field", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                NSLog("The \"OK\" alert occured.")
            }))
            self.present(alert, animated: true, completion: nil)
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


