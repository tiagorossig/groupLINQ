//
//  ClassOverviewVC.swift
//  GroupLINQ
//
//  Created by Tiago Grimaldi Rossi on 7/8/21.
//

import UIKit

class ClassOverviewVC: UIViewController {
    @IBOutlet weak var classNameLabel: UILabel!
    var className = ""
    var delegate: UIViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        classNameLabel.text = className
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
