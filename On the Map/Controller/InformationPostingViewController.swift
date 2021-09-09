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
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    var coord = CLLocationCoordinate2D()
    var lat = CLLocationDegrees(0)
    var lon = CLLocationDegrees(0)    
    
    override func viewWillAppear(_ animated: Bool) {
        subscribeToKeyboardNotifications()
        indicator.isHidden = true
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
        indicator.isHidden = false
        indicator.startAnimating()
        if (linkTF.text!).isEmpty == false || (locationTF.text!).isEmpty == false {
            let address = locationTF.text!
            let geoCoder = CLGeocoder()
            geoCoder.geocodeAddressString(address) { (placemarks, error) in
                print(address)
                guard
                    let placemarks = placemarks,
                    let location = placemarks.first?.location
                else {
                    self.indicator.stopAnimating()
                    let alert = UIAlertController(title:"Error", message: error?.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                        NSLog("The \"OK\" alert occured.")
                    }))
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                self.coord = (location.coordinate)
                self.lat = CLLocationDegrees((location.coordinate.latitude))
                self.lon = CLLocationDegrees((location.coordinate.longitude))
                //segue to nextViewController:
                self.indicator.stopAnimating()
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                let nextViewController = (storyBoard.instantiateViewController(withIdentifier: "submit") as! AddLocationLinkViewController)
                nextViewController.modalPresentationStyle = .fullScreen
                nextViewController.mapString = self.locationTF.text!
                nextViewController.lat = self.lat
                nextViewController.lon = self.lon
                nextViewController.mediaURL = self.linkTF.text!
                self.present(nextViewController, animated:true, completion:nil)
            }
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
        self.dismiss(animated: true, completion: nil)
    }
}

