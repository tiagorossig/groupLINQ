//
//  ClassOverviewVC.swift
//  GroupLINQ
//
//  Created by Tiago Grimaldi Rossi on 7/8/21.
//

import UIKit
import FirebaseFirestore

let memberCellIdentifier = "MemberCell"

class ClassOverviewVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var classNameLabel: UILabel!
    @IBOutlet weak var studentsLabel: UILabel!
    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var groupSizeField: UITextField!
    
    var data: [String] = []
    let db = Firestore.firestore()
    var className = ""
    var delegate: UIViewController!
    var owner: String?
    var students: [String]?
    var code: String?
    var users: [String: [Date]] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set outlets
        classNameLabel.text = className
        tableView.delegate = self
        tableView.dataSource = self
        
        // get classes
        let docRef = db.collection("classes").document(className)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let documentData = document.data()
                self.owner = documentData?["owner"] as? String
                self.students = documentData?["students"] as? [String]
                self.code = documentData?["code"] as? String
                
                self.codeLabel.text = self.code
                
                if let students = self.students {
                    if students.count == 0 {
                        self.studentsLabel.text = "No students signed up for your class yet"
                        return
                    }
                    for studentId in students {
                        self.db.collection("users").document(studentId).getDocument {
                            (document, error) in
                            if error == nil {
                                self.data.append(document!.data()!["name"] as! String)
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
            } else {
                print("Document does not exist")
            }
        }
        
        // get users
        let collectionRef = db.collection("users")
        collectionRef.getDocuments(completion: { snapshot, error in
            if let err = error {
                print(err.localizedDescription)
                return
            }
            
            guard let docs = snapshot?.documents else {
                return
            }
            
            for doc in docs {
                let documentData = doc.data()
                let documentID = doc.documentID
                
                guard let stamps = documentData["availableTimes"] as? [Timestamp] else {
                    return
                }
                
                for stamp in stamps {
                    let date = stamp.dateValue()
                    
                    if self.users[documentID] == nil {
                        self.users[documentID] = []
                    }
                    self.users[documentID]?.append(date)
                }
                
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let userDefaults = UserDefaults.standard
        overrideUserInterfaceStyle = userDefaults.bool(forKey: "darkModeEnabled") ? .dark : .light
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: memberCellIdentifier, for: indexPath as IndexPath)
        cell.textLabel?.text = data[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func makeGroupPressed(_ sender: Any) {
        print("makeGroup pressed")
        
        let groupSize = Int(groupSizeField.text!) ?? 1
        let numStudents = students?.count ?? 0
        let numGroups = numStudents / groupSize
        var frequenciesDict: [Date: Int] = [:]
        
        for (_, userTimes) in users {
            for time in userTimes {
                if frequenciesDict[time] == nil {
                    frequenciesDict[time] = 1
                } else {
                    frequenciesDict[time]! += 1
                }
            }
        }
        
//        for (date, freq) in frequenciesDict {
//            if freq >= groupSize {
//                self.db.collection("groups").addDocument(data: [
//                    "class": code ?? "none",
//                    "times": [String](),
//                    "members": members // TODO: initialize with current user's name
//                ]) { err in
//                    if let err = err {
//                        print("Error adding document: \(err)")
//                    } else {
//                        self.performSegue(withIdentifier: "createClassSegue", sender: self)
//                    }
//                }
//            }
//        }
        
        for _ in 0...numGroups {
            var members = [String]()
            for j in 0...groupSize {
                members.append(students?[j] ?? "none")
            }
            self.db.collection("groups").addDocument(data: [
                "class": code ?? "none",
                "times": [String](),
                "members": members // TODO: initialize with current user's name
            ]) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    self.performSegue(withIdentifier: "createClassSegue", sender: self)
                }
            }
        }
        
    }
    
//    func textFieldShouldReturn(textField: UITextField) -> Bool {
//        textField.resignFirstResponder()
//        return true
//    }
//
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        self.view.endEditing(true)
//    }
}
