//
//  SettingsVC.swift
//  GroupLINQ
//
//  Created by Erika Tan on 7/26/21.
//

import UIKit
import Firebase

class SettingsVC: UIViewController {
    @IBOutlet weak var darkModeSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let userDefaults = UserDefaults.standard
        darkModeSwitch.isOn = userDefaults.bool(forKey: "darkModeEnabled")
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
    
    @IBAction func darkModeChanged(_ sender: Any) {
        let userDefaults = UserDefaults.standard
        if darkModeSwitch.isOn {
            userDefaults.set(true, forKey: "darkModeEnabled")
            overrideUserInterfaceStyle = .dark
        }
        else {
            userDefaults.set(false, forKey: "darkModeEnabled")
            overrideUserInterfaceStyle = .light
        }
    }
    
    @IBAction func logoutPressed(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            let alert = UIAlertController(
                title: "Sign out failed",
                message: signOutError.localizedDescription,
                preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title:"OK",style:.default))
            self.present(alert, animated: true, completion: nil)
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginNavController = storyboard.instantiateViewController(identifier: "LoginNavigationController")

        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(loginNavController)
    }
}
