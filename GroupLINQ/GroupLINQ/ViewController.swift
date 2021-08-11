//
//  ViewController.swift
//  GroupLINQ
//
//  Created by Tiago Grimaldi Rossi on 7/8/21.
//

import UIKit
import Firebase

class ViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        // setting dark mode off here since the logo is black
        UserDefaults.standard.set(false, forKey: "darkModeEnabled")
        NotificationCenter.default.post(name: .darkModeDisabled, object: nil)
        overrideUserInterfaceStyle = .light
        
        super.viewDidLoad()
    }

    @IBAction func unwindToFirstViewController(_ sender: UIStoryboardSegue) {
        // No code needed, no need to connect the IBAction explicitly
    }
    
    @IBAction func loginPressed(_ sender: Any) {
        print("here")
        guard let email = emailTextField.text,
              let password = passwordTextField.text,
              email.count > 0,
              password.count > 0
        else {
            let alert = UIAlertController(
                title: "Sign in failed",
                message: "One or more fields were left blank",
                preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title:"OK",style:.default))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) {
            user, error in
            if let error = error, user == nil {
                let alert = UIAlertController(
                  title: "Sign in failed",
                  message: error.localizedDescription,
                  preferredStyle: .alert)

                alert.addAction(UIAlertAction(title:"OK",style:.default))
                self.present(alert, animated: true, completion: nil)
            }
            if error == nil {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let mainTabBarController = storyboard.instantiateViewController(identifier: "MainTabBarController")

                // This is to get the SceneDelegate object from your view controller
                // then call the change root view controller function to change to main tab bar
                (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTabBarController)
            }
        }
    }
    
    func textFieldShouldReturn(textField:UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
        }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
