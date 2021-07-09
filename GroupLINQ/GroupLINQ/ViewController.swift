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
    
    var className = ""
    
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
                self.performSegue(withIdentifier: "HomeSegueIdentifier", sender: self)
            }
        }
    }
    
    @IBAction func createClassPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Class Name", message: "", preferredStyle: .alert)
                alert.addTextField { (textField) in
                    textField.text = ""
                }
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    self.className = alert.textFields![0].text!
                    self.performSegue(withIdentifier: "createClassSegue", sender: self)
               
                }))

                self.present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "createClassSegue" ,
                let nextVC = segue.destination as? ClassOverviewVC {
                nextVC.delegate = self
                nextVC.className = className
            }
        }
    
}

