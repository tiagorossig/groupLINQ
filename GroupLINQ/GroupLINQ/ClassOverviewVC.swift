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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        overrideUserInterfaceStyle = .light // temp
        
        classNameLabel.text = className
        tableView.delegate = self
        tableView.dataSource = self
        
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

//        let leftOver = students?.count ?? 0 % Int(groupSizeField.text)
        let numGroups = Int(groupSizeField.text!) ?? 1
        let numStudentsPerGroup = (students?.count ?? 0) / numGroups

        for _ in 0...numGroups {
            var members = [String]()
            for j in 0...numStudentsPerGroup {
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
