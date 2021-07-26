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
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func loginPressed(_ sender: Any) {
        print("here")
        guard let email = emailTextField.text,
              let password = passwordTextField.text,
              email.count > 0,
              password.count > 0
        else {
          return
        }
        
////        COMMENTING OUT AUTH FOR FASTER TESTING
//        Auth.auth().signIn(withEmail: email, password: password) {
//          user, error in
//          if let error = error, user == nil {
//            let alert = UIAlertController(
//              title: "Sign in failed",
//              message: error.localizedDescription,
//              preferredStyle: .alert)
//
//            alert.addAction(UIAlertAction(title:"OK",style:.default))
//            self.present(alert, animated: true, completion: nil)
//          }
//            if error == nil {
//                self.performSegue(withIdentifier: "HomeSegueIdentifier", sender: self)
//            }
//        }
        self.performSegue(withIdentifier: "HomeSegueIdentifier", sender: self)
    }
    
    
   
    
}
