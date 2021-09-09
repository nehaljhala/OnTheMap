//
//  LoginViewController.swift
//  On the Map
//
//  Created by Nehal Jhala on 4/19/21.
//
import Foundation
import UIKit
import SafariServices

class LoginViewController: UIViewController, UITextFieldDelegate, SFSafariViewControllerDelegate {
    
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        subscribeToKeyboardNotifications()
    }
    
    //keyboard settings:
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
        emailTextfield.resignFirstResponder()
        passwordTextfield.resignFirstResponder()
        return true
    }
    
    @IBAction func loginTapped(_ sender: Any) {
        emailTextfield.resignFirstResponder()
        passwordTextfield.resignFirstResponder()
        let client = UdacityClient()
        client.makeLoginCall(userName: emailTextfield.text!, password: passwordTextfield.text!) {
            (retResponse:LoginResponse?, retError:Error?, success:Bool) in
            DispatchQueue.main.async {
                self.performLogin(retResponse, retError, success)
            }
        }
    }
    
    func performLogin(_ resp: LoginResponse?, _ error: Error?, _ success: Bool ) {
        if success == true{
            globalVars.loginInfo.removeAll()
            globalVars.loginInfo.append(resp!)
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "tabView") as! UITabBarController
            nextViewController.modalPresentationStyle = .fullScreen
            self.present(nextViewController, animated:true, completion:nil)
            return
        }
        else{
            if let error = error {
                let alert = UIAlertController(title:"Unexpected Error", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                }))
                self.present(alert, animated: true, completion: nil)
            }
            else{
                let alert = UIAlertController(title:"Ooops", message: "Incorrect user name or password", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
        
    }
    
    @IBAction func signUpTapped(_ sender: Any) {
        guard let url = URL(string:"https://www.udacity.com/account/auth#!/signup" ) else {
            return
        }
        let safariVC = SFSafariViewController(url: url)
        present(safariVC, animated: true, completion: nil)
        safariVC.delegate = self
    }    
}



