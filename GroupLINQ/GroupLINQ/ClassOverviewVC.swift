//
//  ClassOverviewVC.swift
//  GroupLINQ
//
//  Created by Tiago Grimaldi Rossi on 7/8/21.
//

import UIKit
import FirebaseFirestore

let memberCellIdentifier = "MemberCell"

class ClassOverviewVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var classNameLabel: UILabel!
    @IBOutlet weak var studentsLabel: UILabel!
    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var groupSizePicker: UIPickerView!
    
    var data: [String] = []
    let db = Firestore.firestore()
    var className = ""
    var delegate: UIViewController!
    var owner: String?
    var students: [String]?
    var code: String?
    var users: [String: [Date]] = [:]
    var timesDict: [Date: [String]] = [:]
    var pickerData: [Int] = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set outlets
        classNameLabel.text = className
        tableView.delegate = self
        tableView.dataSource = self
        groupSizePicker.delegate = self
        groupSizePicker.dataSource = self
        
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
                    
                    // only allow group sizes < # students to be formed
                    self.pickerData = Array(1...students.count)
                    self.groupSizePicker.reloadAllComponents()
                    
                    for studentId in students {
                        self.db.collection("users").document(studentId).getDocument {
                            (document, error) in
                            if error == nil {
                                self.data.append(document!.data()!["name"] as! String)
                                self.tableView.reloadData()
                            }
                        }
                    }
                    
                    // get student times for grouping algorithm
                    for studentId in students {
                        self.db.collection("users").document(studentId).getDocument {
                            (document, error) in
                            if error == nil {
                                let studentTimes = (document!.data()!["availableTimes"] as! [Timestamp])
                                for t in studentTimes {
                                    let date = t.dateValue()
                                    if self.timesDict[date] == nil {
                                        self.timesDict[date] = [studentId]
                                    }
                                    else {
                                        var studentsForThisTime = self.timesDict[date]
                                        studentsForThisTime?.append(studentId)
                                        self.timesDict[date] = studentsForThisTime
                                    }
                                }
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
    
    override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }

    // Number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    // The data to return fopr the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(pickerData[row])
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
        // no students in class
        if students == nil || students?.count == 0 {
            let alert = UIAlertController(title: "Cannot make groups", message: "Wait for students to join your class to make groups.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        // class is closed
        self.db.collection("classes").document(className).getDocument {
            (document, error) in
            if error == nil {
                let open = (document!.data()!["open"] as! Bool)
                if !open {
                    let alert = UIAlertController(title: "Cannot make groups", message: "The class is now closed and groups have already been made.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                else {
                    self.makeGroups()
                }
            }
        }
    }
    
    func makeGroups() {
        let groupSize = Int(pickerData[groupSizePicker.selectedRow(inComponent: 0)]) ?? 1
        let numStudents = students?.count ?? 0

        var groupedStudents: [String] = []
        for (time, studentsFreeAtThisTime) in timesDict {
            let ungroupedStudentsFreeAtThisTime =  studentsFreeAtThisTime.filter { !groupedStudents.contains($0) }
            if ungroupedStudentsFreeAtThisTime.count >= groupSize {
                var groupMembers: [String] = []
                for i in 0..<groupSize {
                    groupMembers.append(ungroupedStudentsFreeAtThisTime[i])
                    groupedStudents.append(ungroupedStudentsFreeAtThisTime[i])
                }
                self.db.collection("groups").addDocument(data: [
                                "class": className ?? "none",
                                "time": time,
                                "members": groupMembers
                            ]) { err in
                                if let err = err {
                                    print("Error adding document: \(err)")
                                } else {
                                    print("group added with time \(time)")
                                }
                            }
                }
        }

        // randomly group the leftover students who did not have compatible enough schedules
        let leftoverStudents = (self.students ?? []).filter { !groupedStudents.contains($0) }
        let chunkedLeftovers = leftoverStudents.chunked(into: groupSize)
        for chunk in chunkedLeftovers {
            self.db.collection("groups").addDocument(data: [
                            "class": className ?? "none",
                "time": NSNull(),
                "members": chunk
                        ]) { err in
                            if let err = err {
                                print("Error adding document: \(err)")
                            } else {
                                print("group added from leftovers")
                            }
                        }
            }
        
        
        // mark this class as closed
        self.db.collection("classes").document(className).updateData([
            "open": false
        ])
    
        let groupsMadeAlert = UIAlertController(title: "Groups made", message: "All groups have been made and the class cannot be joined by more students.", preferredStyle: .alert)


        groupsMadeAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

        self.present(groupsMadeAlert, animated: true, completion: nil)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
