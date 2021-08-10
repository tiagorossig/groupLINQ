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
        guard let name = nameTextField.text,
              let phone = phoneNumberTextField.text,
              let email = emailTextField.text,
              let password = passwordTextField.text,
              name.count > 0,
              phone.count > 0,
              email.count > 0,
              password.count > 0
        else {
            let alert = UIAlertController(
                title: "Sign up failed",
                message: "One or more fields were left blank",
                preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title:"OK",style:.default))
            self.present(alert, animated: true, completion: nil)
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
                        self.performSegue(withIdentifier: "surveySegue", sender: self)
                    }
                }
            }
        })
    }

}
