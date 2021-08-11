//
//  YourTeamVC.swift
//  GroupLINQ
//
//  Created by Bagaria on 8/9/21.
//

import UIKit
import Firebase
var teammates : [String] = []

class YourTeamVC: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    let db = Firestore.firestore()
    @IBOutlet weak var tableView: UITableView!
    let tcID = "teamMemberCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        self.db.collection("groups").whereField("members", arrayContains: Auth.auth().currentUser?.uid)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        teammates.append(document.documentID)
                    }
                    self.tableView.reloadData()
                }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return teammates.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: tcID, for: indexPath as IndexPath)
        let row = indexPath.row
        cell.textLabel?.text = teammates[row]
        return cell
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let userDefaults = UserDefaults.standard
        if userDefaults.bool(forKey: "darkModeEnabled") {
            overrideUserInterfaceStyle = .dark
        }
        else {
            overrideUserInterfaceStyle = .light
        }
    }
}
