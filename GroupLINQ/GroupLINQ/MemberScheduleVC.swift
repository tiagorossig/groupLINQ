//
//  MemberScheduleVC.swift
//  GroupLINQ
//
//  Created by Bagaria on 8/9/21.
//

import UIKit

class MemberScheduleVC: UIViewController {
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
        
        let userDefaults = UserDefaults.standard
        if userDefaults.bool(forKey: "darkModeEnabled") {
            overrideUserInterfaceStyle = .dark
        }
        else {
            overrideUserInterfaceStyle = .light
        }
    }

}
