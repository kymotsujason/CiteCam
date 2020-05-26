//
//  CitationViewController.swift
//  CiteCam
//
//  This file handles editing a citation cell.
//  This file can also export the single citation.
//
//  Main Functions:
//  Manipulate citation text.
//  Discord or save changes.
//  Replace image/photo.
//  Export singular citation.
//
//  Created by Jason Yue 11/17/16
//

import UIKit
import MessageUI
import SCLAlertView

class CitationViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MFMailComposeViewControllerDelegate {
    
    // Connections from UI to code.
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    
    // This value is either passed by `CitationTableViewController` in `prepareForSegue(_:sender:)`
    // or constructed as part of adding a new citation.
    var citation: Citation?
    
    // On load.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Handle the text field’s user input through delegate callbacks.
        nameTextField.delegate = self
        
        // Set up views if editing an existing Citation.
        if let citation = citation {
            navigationItem.title = citation.name
            nameTextField.text   = citation.name
            photoImageView.image = citation.photo
        }
        
        // Enable the Save button only if the text field has a valid Citation name.
        checkValidCitationName()
    }
    
    // Following functions handle the textfield.
    
    // Hide keyboard.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Check if the name is valid when not typing.
    func textFieldDidEndEditing(_ textField: UITextField) {
        checkValidCitationName()
        navigationItem.title = textField.text
    }
    
    // Disable save button during typing to prevent issues with name/citation.
    func textFieldDidBeginEditing(_ textField: UITextField) {
        saveButton.isEnabled = false
    }
    
    // Checks for valid text, meaning not empty.
    func checkValidCitationName() {
        
        // Disable the Save button if the text field is empty.
        let text = nameTextField.text ?? ""
        saveButton.isEnabled = !text.isEmpty
    }
    
    // Following functions handle image replacement.
    
    // Dismiss the picker if the user canceled.
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Opens up a library of images for user to choose.
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        // The info dictionary contains multiple representations of the image, and this uses the original.
        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        // Set photoImageView to display the selected image.
        photoImageView.image = selectedImage
        
        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }
    
    // Following functions handle moving back to the main view.
    
    // If user presses cancel button, return to the main screen and discord changes.
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        navigationController!.popViewController(animated: true)
    }
    
    // Set up updated information to return to the main screen.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // On pressing the save button.
        if (saveButton != nil) {
            let name = nameTextField.text ?? ""
            let photo = photoImageView.image
            
            // Set the citation to be passed to CitationListTableViewController after the unwind segue.
            citation = Citation(name: name, photo: photo)
        }
    }
    
    // Handles interaction with the image.
    @IBAction func selectImageFromPhotoLibrary(_ sender: UITapGestureRecognizer) {
        
        // Hide the keyboard.
        nameTextField.resignFirstResponder()
        
        let imagePickerController = UIImagePickerController()
        
        // Only allow photos to be picked, not taken.
        imagePickerController.sourceType = .photoLibrary
        
        // Make sure ViewController is notified when the user picks an image.
        imagePickerController.delegate = self
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    // Handles singular email exporting.
    @IBAction func exportButton(_ sender: UIButton) {
        
        // Check if device can send Email.
        if(MFMailComposeViewController.canSendMail()) {
            
            let mailComposer = MFMailComposeViewController()
            mailComposer.mailComposeDelegate = self
            
            // Set subject and email destination.
            mailComposer.setToRecipients(["youremail@something.com"])
            mailComposer.setSubject("CiteCam citation delivered!")
            
            // This will set the message body to the citation text within the text field.
            mailComposer.setMessageBody("\(nameTextField.text!)", isHTML: true)
            
            present(mailComposer, animated: true, completion: nil)
            
        } else {
            
            // If there is no email functionality, display message.
            // Usually occurs if there really is no email function or that it is not set up.
            SCLAlertView().showError("Unable to Email!", subTitle: "We could not open the email client! Do you have the email client setup?")
        }
        
    }
    
    // Delegate to catch mail interactions.
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true, completion: nil)
    }
    
}

