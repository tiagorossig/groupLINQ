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
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func signupPressed(_ sender: Any) {
        guard let email = emailTextField.text,
              let password = passwordTextField.text,
              email.count > 0,
              password.count > 0
        else {
          return
        }
        Auth.auth().createUser(withEmail: email, password: password, completion: { user, error in  self.performSegue(withIdentifier: "HomeSegueIdentifier", sender: self)})
    }

}
