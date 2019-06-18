//
//  ViewController.swift
//  Meme v1
//
//  Created by Mohamed Gamal on 6/16/19.
//  Copyright © 2019 Barmagli. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var navbarTop: UIToolbar!
    @IBOutlet weak var toolbarBottom: UIToolbar!
    
    var memedImage = UIImage()
    var meme: Meme!
    let memeTextAttributes: [String: Any] = [
        NSAttributedStringKey.strokeColor.rawValue: UIColor.black,
        NSAttributedStringKey.foregroundColor.rawValue: UIColor.white,
        NSAttributedStringKey.font.rawValue: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSAttributedStringKey.strokeWidth.rawValue: -3
    ]
    
    // save memd image
    func save() {
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, image: imagePickerView.image!, memedImage: memedImage)
        self.meme = meme
    }
    
    // generate memed image with text on top and bottom
    func generateMemedImage() -> UIImage {
        
        navbarTop.isHidden = true
        toolbarBottom.isHidden = true
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        navbarTop.isHidden = false
        toolbarBottom.isHidden = false
        
        return memedImage
    }
    
    // init text field with custom style
    func initializeTextField(textField: UITextField, withText text: String) {
        textField.text = text
        textField.textAlignment = .center
        textField.delegate = self
        textField.defaultTextAttributes = memeTextAttributes
    }
    
    // subscribe to keyboard show and hide notifictions
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
    // unsubscribe from keyboard show and hide notifictions
    func unSubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
    // shift the view to tp when keyboard will show
    @objc func keyboardWillShow(_ notification: Notification)  {
        view.frame.origin.y = -getKeyboardHeight(notification)
    }
    
    // return view to it's origin when keyboard will hide
    @objc func keyboardWillHide(_ notification: Notification)  {
        view.frame.origin.y = 0
    }
    
    // get keyboard height
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // init text field with custom style
        initializeTextField(textField: topTextField, withText: "TOP TEXT")
        initializeTextField(textField: bottomTextField, withText: "BOTTOM TEXT")
        
        // disable share button if no image
        shareButton.isEnabled = false
    }
    
    // set default text field to empty string when tap on it not the user input
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.text == "TOP TEXT" || textField.text == "BOTTOM TEXT" {
            textField.text = ""
        }
    }
    
    // hide keyboard when press retun and focus on textfield
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // disable the camera button if no camera on device
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        
        // add keyboard subscribers
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // remove keyboard subscribers
        unSubscribeFromKeyboardNotifications()
    }
    
    // trigger when press album button
    // choose an image from photo library
    @IBAction func pickAnImageFromAlbum(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self // add delegate
        imagePicker.sourceType = .photoLibrary // choose photo library to be the source
        present(imagePicker, animated: true, completion: nil) // show the image picker
    }
    
    // trigger when press camera button
    // take an image from camera
    @IBAction func pickAnImageFromCamera(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    // trigger when press share button
    // share the memed image
    @IBAction func shareMeme(_ sender: Any) {
        let memedImage = generateMemedImage()
        
        // init an activity controller and add memed image to it
        let activityController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        // save the memed image after activity controller finish with it
        activityController.completionWithItemsHandler = { (activity, success, items, error) in
            if success {
                self.memedImage = memedImage
                self.save()
            }
        }
        present(activityController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // get chosen image and add it to image view
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagePickerView.image = image
        }
        
        // enable the share button after choose image
        shareButton.isEnabled = true
        dismiss(animated: true, completion: nil)
    }
    
    // close the image picker on click cancel
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

