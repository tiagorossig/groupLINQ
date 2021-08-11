//
//  SettingsVC.swift
//  GroupLINQ
//
//  Created by Erika Tan on 7/26/21.
//

import UIKit
import Firebase
import AVFoundation
import FirebaseStorage

class SettingsVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var darkModeSwitch: UISwitch!
    @IBOutlet weak var imageView: UIImageView!
    
    let storage = Storage.storage().reference()
    let picker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // dark mode
        NotificationCenter.default.addObserver(self, selector: #selector(darkModeEnabled(_:)), name: .darkModeEnabled, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(darkModeDisabled(_:)), name: .darkModeDisabled, object: nil)
        overrideUserInterfaceStyle = darkModeSwitch.isOn ? .dark : .light
        
        // picture
//        imageView.layer.borderWidth = 1.0
        imageView.layer.masksToBounds = false
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.cornerRadius = 25
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        
        picker.delegate = self
        guard let urlString = UserDefaults.standard.value(forKey: "image/\(Auth.auth().currentUser!.uid)") as? String,
              let url = URL(string: urlString) else {
                    return
        }
        
        let task = URLSession.shared.dataTask(with: url, completionHandler: { data, _, error in
            guard let data = data, error ==  nil else {
                return
            }
            
            DispatchQueue.main.async {
                let image = UIImage(data: data)
                self.imageView.image = image
            }
        })
        
        task.resume()
    }
    
    
    //    DARK MODE    \\
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .darkModeEnabled, object: nil)
        NotificationCenter.default.removeObserver(self, name: .darkModeDisabled, object: nil)
    }
    
    @IBAction func darkModeChanged(_ sender: Any) {
        let userDefaults = UserDefaults.standard
        if darkModeSwitch.isOn {
            userDefaults.set(true, forKey: "darkModeEnabled")
            NotificationCenter.default.post(name: .darkModeEnabled, object: nil)
        }
        else {
            userDefaults.set(false, forKey: "darkModeEnabled")
            NotificationCenter.default.post(name: .darkModeDisabled, object: nil)
        }
    }
    
    @objc private func darkModeEnabled(_ notification: Notification) {
        overrideUserInterfaceStyle = .dark
    }

    @objc private func darkModeDisabled(_ notification: Notification) {
        overrideUserInterfaceStyle = .light
    }
    
    
    //    AUTH    \\
    
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
    
    
    //    PICTURE   \\
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true, completion: nil)
        guard let chosenImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        imageView.image = chosenImage
        
        guard let imageData = chosenImage.pngData() else {
            return
        }
        
        storage.child("images/\(Auth.auth().currentUser!.uid)").putData(imageData, metadata: nil, completion: {_, error in
            guard error == nil else {
                print("Failed to upload")
                return
            }
            
            self.storage.child("images/\(Auth.auth().currentUser!.uid)").downloadURL(completion: { url, error in
                guard let url = url, error == nil else {
                    return
                }
                
                let urlString = url.absoluteString
                
                DispatchQueue.main.async {
                    self.imageView.image = chosenImage
                }
                
                print("Download URL: \(urlString)")
                UserDefaults.standard.setValue(urlString, forKey: "image/\(Auth.auth().currentUser!.uid)")
            })
        })
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
        print("User cancelled")
    }
    
    @IBAction func profilePicturePressed(_ sender: Any) {
        let controller = UIAlertController(
            title: "Select picture",
            message: nil,
            preferredStyle: .alert
        )
        let library = UIAlertAction(
            title: "Library",
            style: .default,
            handler: {(action) in self.librarySelected(self)}
        )
        let camera = UIAlertAction(
            title: "Camera",
            style: .default,
            handler: {(action) in self.cameraSelected(self)}
        )
        
        controller.addAction(library)
        controller.addAction(camera)
        
        present(controller, animated: true) {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissAlertController))
            controller.view.superview?.subviews[0].addGestureRecognizer(tapGesture)
        }
    }
    
    // dismiss alert when tapping outside of it
    @objc func dismissAlertController(){
        self.dismiss(animated: true, completion: nil)
    }
    
    func librarySelected(_ sender: Any) {
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        
        present(picker, animated: true, completion: nil)
    }
    
    func cameraSelected(_ sender: Any) {
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
            
            present(alertVC, animated: true, completion: nil)
        }
    }
}
