//
//  OnTheMapTableViewController.swift
//  On the Map
//
//  Created by Nehal Jhala on 4/19/21.
//

import UIKit

class OnTheMapTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    var pins: [AnnotationResponse]! {
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        return appDelegate.pins
    }
    
    //setting tableView:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if pins[0].results.count <= 100{
            return pins[0].results.count
        }
        else {
            return 100
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! cell
        let result = self.pins[0].results[(indexPath as NSIndexPath).row]
        cell.label1?.text = "\(result.firstName) \(result.lastName)"
        cell.label2?.text = "\(result.mediaURL)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var result = self.pins[0].results[(indexPath as NSIndexPath).row]
        if !result.mediaURL.starts(with: "http"){
            result.mediaURL = "http://" + result.mediaURL
        }
        UIApplication.shared.open(URL(string: result.mediaURL)!, options: [:], completionHandler: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.tabBar.isHidden = false
    }
    
    
    func requestLocation(completion: @escaping (AnnotationResponse)-> ()) {
        let url = URLRequest(url: URL(string: "https://onthemap-api.udacity.com/v1/StudentLocation?order=-updatedAt")!)
        URLSession.shared.dataTask(with: url) {data, res, err in
            if let data = data {
                do {
                    let aResponse = try JSONDecoder().decode(AnnotationResponse.self, from: data)
                    completion(aResponse)
                }catch let error {
                    print("api error" + error.localizedDescription)
                }
            }
        }.resume()
    }
    
    @IBAction func refreshTapped(_ sender: Any) {
        requestLocation(){ (aResponse) in
            DispatchQueue.main.async {
                let object = UIApplication.shared.delegate
                let appDelegate = object as! AppDelegate
                appDelegate.pins.removeAll()
                appDelegate.pins.append(aResponse)
            }
        }
        self.tableView.reloadData()
    }
    
    
    @IBAction func addButtonTapped(_ sender: Any) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "addloclink") as! InformationPostingViewController
        nextViewController.modalPresentationStyle = .fullScreen
        self.present(nextViewController, animated:true, completion:nil)
        return
    }
    
    
    @IBAction func logoutTapped(_ sender: Any) {
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
        }
        task.resume()
        
        //segue to loginViewController.
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "loginView") as! LoginViewController
        nextViewController.modalPresentationStyle = .fullScreen
        self.present(nextViewController, animated:true, completion:nil)
        return
    }
    
    
}
