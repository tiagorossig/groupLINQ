//
//  SettingsVC.swift
//  GroupLINQ
//
//  Created by Erika Tan on 7/26/21.
//

import UIKit
import Firebase

extension Notification.Name {
    static let darkModeEnabled = Notification.Name("darkModeEnabled")
    static let darkModeDisabled = Notification.Name("darkModeDisabled")
}

class SettingsVC: UIViewController {
    @IBOutlet weak var darkModeSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(darkModeEnabled(_:)), name: .darkModeEnabled, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(darkModeDisabled(_:)), name: .darkModeDisabled, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .darkModeEnabled, object: nil)
        NotificationCenter.default.removeObserver(self, name: .darkModeDisabled, object: nil)
    }
    
    @IBAction func darkModeChanged(_ sender: Any) {
        if darkModeSwitch.isOn {
            
//            userDefaults.set(true, forKey: "darkModeEnabled")

            // Post the notification to let all current view controllers that the app has changed to dark mode, and they should theme themselves to reflect this change.
            NotificationCenter.default.post(name: .darkModeEnabled, object: nil)
        }
        else {
//            userDefaults.set(false, forKey: "darkModeEnabled")

            // Post the notification to let all current view controllers that the app has changed to non-dark mode, and they should theme themselves to reflect this change.
            NotificationCenter.default.post(name: .darkModeDisabled, object: nil)
        }
    }
    
    @objc private func darkModeEnabled(_ notification: Notification) {
        overrideUserInterfaceStyle = .dark
    }

    @objc private func darkModeDisabled(_ notification: Notification) {
        overrideUserInterfaceStyle = .light
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
