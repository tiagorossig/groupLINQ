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
    @IBOutlet weak var suggestedTime: UILabel!
    let tcID = "teamMemberCell"
    let segID = "memberSegue"
    var delegate : UIViewController!
    var className : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        // reset every time so the teammates don't appear more than once
        teammates = []
        
        self.db.collection("groups").whereField("class", isEqualTo: className).whereField("members", arrayContains: Auth.auth().currentUser?.uid)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        for member in document["members"] as? Array ?? [""] {
                            let docRef = self.db.collection("users").document(member)
                            docRef.getDocument {(document, error) in
                                if let document = document, document.exists {
                                    let name = document.get("name") as! String
                                    teammates.append(name)
                                    let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                                    self.tableView.reloadData()
                                } else {
                                    print("Document does not exist")
                                }
                            }
                        }
                        
                        // display suggested time
                        guard let date = document.get("time") as? Timestamp else {
                            self.suggestedTime.text = "No matching times found"
                            return
                        }
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "EEEE"
                        let weekDay = dateFormatter.string(from: date.dateValue())
                        let formatter = DateFormatter()
                        formatter.timeStyle = .short
                        let timeString = formatter.string(from: date.dateValue())
                        self.suggestedTime.text = "\(weekDay) \(timeString)"
                    }
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segID,
            let destination = segue.destination as? MemberScheduleVC,
            let memberIdx = tableView.indexPathForSelectedRow?.row {
            destination.delegate = self
            destination.mName = teammates[memberIdx]
        }
    }
}
