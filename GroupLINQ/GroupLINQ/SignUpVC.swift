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
        // setting dark mode off here since the logo is black
        UserDefaults.standard.set(false, forKey: "darkModeEnabled")
        NotificationCenter.default.post(name: .darkModeDisabled, object: nil)
        overrideUserInterfaceStyle = .light
        
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
        self.performSegue(withIdentifier: "surveySegue", sender: self)
    }
    
    func textFieldShouldReturn(textField:UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
        }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "surveySegue",
            let nextVC = segue.destination as? SurveyVC {
            nextVC.name = nameTextField.text!
            nextVC.phone = phoneNumberTextField.text!
            nextVC.email = emailTextField.text!
            nextVC.password = passwordTextField.text!
        }
    }
}
