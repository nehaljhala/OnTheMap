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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
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
        makeLoginCall() { (resp) in
            DispatchQueue.main.async {
                let object = UIApplication.shared.delegate
                let appDelegate = object as! AppDelegate
                appDelegate.loginInfo.removeAll()
                appDelegate.loginInfo.append(resp)
                self.performLogin(resp)
            }
        }
    }
    
    
    func makeLoginCall(completion: @escaping (LoginResponse)-> ()) {
        var request = URLRequest(url: URL(string: "https://onthemap-api.udacity.com/v1/session")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
        let jsonBody = "{\"udacity\": {\"username\": \"\(emailTextfield.text!)\", \"password\": \"\(passwordTextfield.text!)\"}}"
        request.httpBody = jsonBody.data(using: .utf8)
        
        URLSession.shared.dataTask(with: request, completionHandler: {data, response, error in
            do {
                
                if let error = error {
                    print("aha:" + error.localizedDescription)
                    let alert = UIAlertController(title:"", message: "Unknown error occured.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Try again", comment: "Default action"), style: .default, handler: { _ in
                        NSLog("The \"OK\" alert occured.")
                    }))
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    print("Error with the response, unexpected status code: \(String(describing: response))")
                    return
                }
                let range = 5..<data!.count
                let filteredData = data!.subdata(in: range)
                print("from loginviewcontroller \(String(data: filteredData, encoding: .utf8)!)")
                let resp = try JSONDecoder().decode(LoginResponse.self, from: filteredData)
                completion(resp)
                
            }catch let err {
                print("api error: "  + err.localizedDescription + " Response: " + String(decoding: data!, as: UTF8.self))
                let alert = UIAlertController(title:"", message: "Unknown error occured.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("Try again", comment: "Default action"), style: .default, handler: { _ in
                    NSLog("The \"OK\" alert occured.")
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }).resume()
    }
    
    func performLogin(_ response: LoginResponse) {
        var loginSuccessful = Bool ()
        do {
            loginSuccessful = false
            if response != nil && response.session != nil && response.session.id != nil {
                loginSuccessful = true
            }
        }
        catch {
            print("login Error")
            loginSuccessful = false
        }
        
        if  loginSuccessful == true {
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "tabView") as! UITabBarController
            nextViewController.modalPresentationStyle = .fullScreen
            self.present(nextViewController, animated:true, completion:nil)
            return
        }
        
        if loginSuccessful == false {  //throw error:
            let alert = UIAlertController(title:"Ooops", message: "Incorrect user name or password", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                NSLog("The \"OK\" alert occured.")
            }))
            self.present(alert, animated: true, completion: nil)
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





