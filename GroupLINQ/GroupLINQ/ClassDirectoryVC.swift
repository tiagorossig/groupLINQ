//
//  ClassDirectoryVC.swift
//  GroupLINQ
//
//  Created by Tiago Grimaldi Rossi on 7/26/21.
//

import UIKit
import Firebase

var classList : [String] = []
var statusList: [String] = []

class ClassDirectoryVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let db = Firestore.firestore()
    var className = ""
    @IBOutlet weak var tableView: UITableView!
    let tcID = "classTVC"

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let userDefaults = UserDefaults.standard
        if userDefaults.bool(forKey: "darkModeEnabled") {
            overrideUserInterfaceStyle = .dark
        }
        else {
            overrideUserInterfaceStyle = .light
        }
        
        getClasses()
        tableView.reloadData()
    }
    
    func getClasses() {
        classList = []
        statusList = []
        
        self.db.collection("classes").whereField("students", arrayContains: Auth.auth().currentUser?.uid)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        classList.append(document.documentID)
                        statusList.append("Member")
                        self.tableView.reloadData()
                    }
                    
                    
                    self.db.collection("classes").whereField("owner", isEqualTo: Auth.auth().currentUser?.uid)
                        .getDocuments() { (querySnapshot, err) in
                            if let err = err {
                                print("Error getting documents: \(err)")
                            } else {
                                for document in querySnapshot!.documents {
                                    classList.append(document.documentID)
                                    statusList.append("Owner")
                                    self.tableView.reloadData()
                                }
                                self.tableView.reloadData()
                            }
                    }
                }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return classList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: tcID, for: indexPath as IndexPath)
        let row = indexPath.row
        cell.textLabel?.text = "Class \(row): \(classList[row])\n\(statusList[row])"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        
        self.db.collection("classes").document(classList[row]).getDocument {
            (document, error) in
            if let document = document {
                if document.data()?["owner"] as! String == Auth.auth().currentUser?.uid {
                    self.className = classList[row]
                    self.performSegue(withIdentifier: "createClassSegue", sender: self)
                } else {
                    let group = self.db.collection("groups").whereField("class", isEqualTo: classList[row]).whereField("members", arrayContains: Auth.auth().currentUser?.uid)
                        .getDocuments() { (querySnapshot, err) in
                                if let err = err {
                                    print("Error getting documents: \(err)")
                                } else {
                                    if querySnapshot!.isEmpty {
                                        self.performSegue(withIdentifier: "waitingSegue", sender: self)
                                    }else{
                                        self.performSegue(withIdentifier: "teamResultsSegue", sender: self)
                                    }
                                }
                        }
                }
            }
        }
    }
    
    @IBAction func unwindToFirstViewController(_ sender: UIStoryboardSegue) {
        // No code needed, no need to connect the IBAction explicitly
    }
    
    func generateClassCode(length: Int) -> String {
      let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    @IBAction func createClassPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Class Name", message: "", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.text = ""
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            self.className = alert.textFields![0].text!
            
            // check if this class already exists first
            let docRef = self.db.collection("classes").document(self.className)
            docRef.getDocument { (document, error) in
                if let document = document {
                    if document.exists {
                        let existsAlert = UIAlertController(title: "Class name already exists.", message: "", preferredStyle: .alert)
                        existsAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(existsAlert, animated: true, completion: nil)
                        // it exists so fast fail
                        return
                    } else {
                        self.db.collection("classes").document(self.className).setData([
                            "students": [],
                            "code": self.generateClassCode(length: 6),
                            "owner": Auth.auth().currentUser?.uid
                        ]) { err in
                            if let err = err {
                                print("Error adding document: \(err)")
                            } else {
                                self.getClasses()
                                self.performSegue(withIdentifier: "createClassSegue", sender: self)
                            }
                        }
                    }
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
                        self.performSegue(withIdentifier: "waitingSegue", sender: self)
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
