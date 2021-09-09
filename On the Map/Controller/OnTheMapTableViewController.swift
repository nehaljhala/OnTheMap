//
//  OnTheMapTableViewController.swift
//  On the Map
//
//  Created by Nehal Jhala on 4/19/21.
//
import Foundation
import UIKit

class OnTheMapTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    let client = UdacityClient()
    
    //setting tableView:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return globalVars.studentLoc[0].results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! Cell
        let result = globalVars.studentLoc[0].results[(indexPath as NSIndexPath).row]
        cell.label1?.text = "\(result.firstName) \(result.lastName)"
        cell.label2?.text = "\(result.mediaURL)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var result = globalVars.studentLoc[0].results[(indexPath as NSIndexPath).row]
        if !result.mediaURL.starts(with: "http"){
            result.mediaURL = "http://" + result.mediaURL
        }
        UIApplication.shared.open(URL(string: result.mediaURL)!, options: [:], completionHandler: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.tabBar.isHidden = false
    }
    
    func fetchLocStudents(){
        client.requestLocation() { (_ response: StudentLocation?, _ error: Error?, _ success: Bool) in
            DispatchQueue.main.async {
                if success == true{
                    globalVars.studentLoc.removeAll()
                    globalVars.studentLoc.append(response!)
                    self.tableView.reloadData()
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
    
    @IBAction func refreshTapped(_ sender: Any) {
        fetchLocStudents()
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
    
}


