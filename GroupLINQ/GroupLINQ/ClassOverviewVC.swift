//
//  ClassOverviewVC.swift
//  GroupLINQ
//
//  Created by Tiago Grimaldi Rossi on 7/8/21.
//

import UIKit

public let data = ["Tiago", "Anisha", "Erika", "Bulko"]

let memberCellIdentifier = "MemberCell"

class ClassOverviewVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var classNameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var className = ""
    var delegate: UIViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        classNameLabel.text = className
        tableView.delegate = self
        tableView.dataSource = self
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
}
