//
//  SignUpViewController.swift
//  GroupLINQ
//
//  Created by Erika Tan on 7/8/21.
//

import UIKit
import Firebase

class SignUpVC: UIViewController {
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func signupPressed(_ sender: Any) {
        guard let email = emailTextField.text,
              let password = passwordTextField.text,
              email.count > 0,
              password.count > 0
        else {
          return
        }
        Auth.auth().createUser(withEmail: email, password: password, completion: { user, error in
            let currentUser = Auth.auth().currentUser
            if let currentUser = currentUser {
                let uid = currentUser.uid
                self.db.collection("users").document(uid).setData([
                    "name": self.nameTextField.text!,
                    "email": email,
                    "phoneNumber": self.phoneNumberTextField.text!,
                    "availableTimes": []
                ]) { err in
                    if let err = err {
                        print("Error adding document: \(err)")
                    } else {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let mainTabBarController = storyboard.instantiateViewController(identifier: "MainTabBarController")

                        // This is to get the SceneDelegate object from your view controller
                        // then call the change root view controller function to change to main tab bar
                        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTabBarController)
                    }
                }
            }
        })
    }

}
