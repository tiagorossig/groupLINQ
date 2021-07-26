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
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
