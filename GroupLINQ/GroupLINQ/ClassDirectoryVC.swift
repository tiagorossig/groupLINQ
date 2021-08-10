//
//  ClassDirectoryVC.swift
//  GroupLINQ
//
//  Created by Tiago Grimaldi Rossi on 7/26/21.
//

import UIKit
import Firebase

var classList : [String] = []

class ClassDirectoryVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let db = Firestore.firestore()
    var className = ""
    @IBOutlet weak var tableView: UITableView!
    let tcID = "classTVC"

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        self.db.collection("classes").whereField("students", arrayContains: Auth.auth().currentUser?.uid)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        classList.append(document.documentID)
                    }
                    self.tableView.reloadData()
                }
        }
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return classList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: tcID, for: indexPath as IndexPath)
        let row = indexPath.row
        cell.textLabel?.text = "Class \(row): \(classList[row])"
        return cell
    }
    
    /*func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        print(classList[row])
        self.db.collection("groups").whereField("class", isEqualTo: classList[row]).whereField("members", arrayContains: Auth.auth().currentUser?.uid)
                .getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        self.performSegue(withIdentifier: "waitingSegue", sender: self)
                    } else {
                        for document in querySnapshot!.documents {
                            classList.append(document.documentID)
                        }
                        self.tableView.reloadData()
                    }
            }
    }*/
    
    @IBAction func unwindToFirstViewController(_ sender: UIStoryboardSegue) {
        // No code needed, no need to connect the IBAction explicitly
    }
    
    func generateClassCode(length: Int) -> String {
      let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    @IBAction func createClassPressed(_ sender: Any) {
        print("createClass pressed")
        let alert = UIAlertController(title: "Class Name", message: "", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.text = ""
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            print("createClass OK pressed")
            self.className = alert.textFields![0].text!
            
            self.db.collection("classes").document(self.className).setData([
                "students": [],
                "code": self.generateClassCode(length: 6),
                "owner": "" // TODO: initialize with current user's name
            ]) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    self.performSegue(withIdentifier: "createClassSegue", sender: self)
                }
            }
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func joinClassPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Class Code", message: "", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.text = ""
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            self.db.collection("classes").whereField("code", isEqualTo: alert.textFields![0].text!)
                .getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else {
                        guard querySnapshot?.count == 1 else {
                            let invalidAlert = UIAlertController(title: "Invalid class code.", message: "", preferredStyle: .alert)
                            invalidAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(invalidAlert, animated: true, completion: nil)
                            return
                        }
                        let id = querySnapshot!.documents[0].documentID
                        self.db.collection("classes").document(id).updateData([
                            "students": FieldValue.arrayUnion([Auth.auth().currentUser?.uid])
                        ])
                        self.performSegue(withIdentifier: "joinClassSegue", sender: self)
                    }
            }
        }))
    
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "createClassSegue" ,
            let nextVC = segue.destination as? ClassOverviewVC {
            nextVC.delegate = self
            nextVC.className = self.className
        }
    }
}
