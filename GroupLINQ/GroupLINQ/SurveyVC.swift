//
//  SurveyVC.swift
//  GroupLINQ
//
//  Created by Erika Tan on 7/30/21.
//

import UIKit

class SurveyVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
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
