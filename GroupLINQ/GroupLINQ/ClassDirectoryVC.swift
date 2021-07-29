//
//  ClassDirectoryVC.swift
//  GroupLINQ
//
//  Created by Tiago Grimaldi Rossi on 7/26/21.
//

import UIKit

class ClassDirectoryVC: UIViewController {
    
    var className = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(darkModeEnabled(_:)), name: .darkModeEnabled, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(darkModeDisabled(_:)), name: .darkModeDisabled, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .darkModeEnabled, object: nil)
        NotificationCenter.default.removeObserver(self, name: .darkModeDisabled, object: nil)
    }
    
    @objc private func darkModeEnabled(_ notification: Notification) {
        overrideUserInterfaceStyle = .dark
    }

    @objc private func darkModeDisabled(_ notification: Notification) {
        overrideUserInterfaceStyle = .light
    }
    
    @IBAction func createClassPressed(_ sender: Any) {
        print("createClass pressed")
        let alert = UIAlertController(title: "Class Name", message: "", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.text = ""
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            print("createClass OK pressed")
            self.className = alert.textFields![0].text!
            self.performSegue(withIdentifier: "createClassSegue", sender: self)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "createClassSegue" ,
            let nextVC = segue.destination as? ClassOverviewVC {
            nextVC.delegate = self
            nextVC.className = self.className
        }
    }
}
