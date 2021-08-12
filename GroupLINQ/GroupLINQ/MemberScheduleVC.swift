//
//  MemberScheduleVC.swift
//  GroupLINQ
//
//  Created by Bagaria on 8/9/21.
//

import UIKit
import Firebase

class MemberScheduleVC: UIViewController {
    let db = Firestore.firestore()
    @IBOutlet weak var memberName: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var phoneNumber: UILabel!
    var delegate : UIViewController!
    var mName : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        memberName.text = "Member Name: \(mName ?? "")"
        self.db.collection("users").whereField("name", isEqualTo: mName)
        .getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    self.email.text = "Email: \(document.get("email") as! String)"
                    self.phoneNumber.text = "Phone Number: \(document.get("phoneNumber") as! String)"
                }
            }
        }
        
        let userDefaults = UserDefaults.standard
        if userDefaults.bool(forKey: "darkModeEnabled") {
            overrideUserInterfaceStyle = .dark
        }
        else {
            overrideUserInterfaceStyle = .light
        }
    }

}
