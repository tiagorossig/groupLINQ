//
//  SurveyVC.swift
//  GroupLINQ
//
//  Created by Erika Tan on 7/30/21.
//

import UIKit
import JZCalendarWeekView

class SurveyVC: UIViewController {
    @IBOutlet weak var calendarWeekView: JZLongPressWeekView!
    
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
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    }
}
