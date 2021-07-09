//
//  ViewController.swift
//  GroupLINQ
//
//  Created by Tiago Grimaldi Rossi on 7/8/21.
//

import UIKit

class ViewController: UIViewController {
    
    var className = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func createClassPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Class Name", message: "", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = ""
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            self.className = alert.textFields![0].text!
            self.performSegue(withIdentifier: "createClassSegue", sender: self)
       
//            let vc = self.storyboard?.instantiateViewController(identifier: "classOverview")
//            self.navigationController?.pushViewController(vc!, animated: true)
//
        }))

        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "createClassSegue" ,
            let nextVC = segue.destination as? ClassOverviewVC {
            nextVC.delegate = self
            nextVC.className = className
        }
    }
    
}

