//
//  EditProfileViewController.swift
//  xBeacon
//
//  Created by Leandro on 5/27/16.
//  Copyright © 2016 BaDaSS. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class EditProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //Constants
    var rootRef = FIRDatabase.database().reference()
    let storageRef = FIRStorage.storage().reference()
    
    //Outlets
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var profilePicButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Retrieve profile info from Firebase and set the text fields to the appropriate value
        if let user = FIRAuth.auth()?.currentUser {
            
            
            
            self.rootRef.child("profile").child(user.uid).observeSingleEventOfType(.Value, withBlock: { (info) in
            
                let name = info.value!["Name"] as! String
                let phone = info.value!["Phone"] as! String
                let email = info.value!["E-mail"] as! String
            
                self.nameField.text = name
                self.phoneField.text = phone
                self.emailField.text = email
                
                let imagePath = self.getDocumentsURL().URLByAppendingPathComponent("cool-pix").URLByAppendingPathComponent("itsmemario").path!
                if let profileImage = self.loadImageFromPath(imagePath) {
                    self.profilePicButton.setImage(profileImage, forState: .Normal)
                }
            
            }) { (error) in
                print(error.localizedDescription)
                print("Could not import contact info")
            }
        } else {
            print("userid is nil, unable to import contact info")
        }
    }
    
    // Helper functions to retrieve images and set as the profile picture
    func getDocumentsURL() -> NSURL {
        let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        return documentsURL
    }
    
    func fileInDocumentsDirectory(filename: String) -> String {
        let fileURL = getDocumentsURL().URLByAppendingPathComponent(filename)
        return fileURL.path!
    }
    
    func loadImageFromPath(path: String) -> UIImage? {
        let image = UIImage.init(contentsOfFile: path)
        if image == nil {
            print("no image found")
        } else {
            print("image found")
        }
        
        return image
    }
    // -------------------
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            print("Info did not have the required UIImage for the Original Image")
            dismissViewControllerAnimated(true, completion: nil)
            return
        }
        
        self.profilePicButton.setImage(image, forState: .Normal)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //Actions
    @IBAction func dismissKeyboard(sender: AnyObject) {
        view.endEditing(true)
    }
    
    @IBAction func chooseImagePressed(sender: UIButton) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        picker.sourceType = .PhotoLibrary
        picker.modalPresentationStyle = .FullScreen
        
        
        presentViewController(picker, animated: true, completion: nil)

    }
    
    @IBAction func saveProfile(sender: AnyObject) {
        
        print("Saving Profile...")
        
        // Update the profile info simultaneously and check for errors
        let updatedInfo = ["Name" : self.nameField.text!,
                           "Phone" : self.phoneField.text!,
                           "E-mail" : self.emailField.text!]
        if let user = FIRAuth.auth()?.currentUser {
            rootRef.child("profile").child(user.uid).updateChildValues(updatedInfo, withCompletionBlock: { (error, ref) in
                if error == nil {
                    print("save success")
                    //self.performSegueWithIdentifier("SaveProfile", sender: self)
                } else {
                    print("error saving")
                }
            })
        } else {
            print("failed to save profile")
        }
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
