//
//  ClassDirectoryVC.swift
//  GroupLINQ
//
//  Created by Tiago Grimaldi Rossi on 7/26/21.
//

import UIKit

var classList : [String] = ["iOS"]

class ClassDirectoryVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
    var className = ""
    @IBOutlet weak var tableView: UITableView!
    let tcID = "classTVC"

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
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
        return classList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: tcID, for: indexPath as IndexPath)
        let row = indexPath.row
        cell.textLabel?.text = "Class \(row): \(classList[row])"
        return cell
    }
    
    @IBAction func unwindToFirstViewController(_ sender: UIStoryboardSegue) {
         // No code needed, no need to connect the IBAction explicitly
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
