//
//  SettingsVC.swift
//  GroupLINQ
//
//  Created by Erika Tan on 7/26/21.
//

import UIKit
import Firebase
import AVFoundation

extension Notification.Name {
    static let darkModeEnabled = Notification.Name("darkModeEnabled")
    static let darkModeDisabled = Notification.Name("darkModeDisabled")
}

class SettingsVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var darkModeSwitch: UISwitch!
    @IBOutlet weak var imageView: UIImageView!
    
    let picker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(darkModeEnabled(_:)), name: .darkModeEnabled, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(darkModeDisabled(_:)), name: .darkModeDisabled, object: nil)
        picker.delegate = self
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let chosenImage = info[.originalImage] as! UIImage
        
        imageView.contentMode = .scaleAspectFit
        imageView.image = chosenImage
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
        print("User cancelled")

    }
    
    @IBAction func profilePicturePressed(_ sender: Any) {
        
        if UIImagePickerController.availableCaptureModes(for: .rear) != nil {
            
            // there is a rear camera!
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) {
                    accessGranted in
                    guard accessGranted == true else { return }
                }
            case .authorized:
                break
            default:
                print("Access denied")
                return
            }
            
            // We are authorized to use the camera
            
            picker.allowsEditing = false
            picker.sourceType = .camera
            picker.cameraCaptureMode = .photo
            
            present(picker, animated: true, completion: nil)
            
        } else {
        
            // if no camera is available, pop up an alert
            
            let alertVC = UIAlertController(
                title: "No camera",
                message: "Sorry, this device has no camera",
                preferredStyle: .alert
            )
            
            let okAction = UIAlertAction(
                title: "OK",
                style:.default,
                handler: nil
            )
            alertVC.addAction(okAction)
            present(alertVC, animated:true, completion:nil)
        }
    
    }
    
}
