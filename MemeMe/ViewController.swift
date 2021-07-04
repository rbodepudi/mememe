//
//  ViewController.swift
//  MemeMe
//
//  Created by Bodepudi, Roopkishan on 7/2/21.
//

import UIKit

class ViewController: UIViewController {

    // MARK: Properties
    let defaultTextAttributes: [NSAttributedString.Key: Any] = [
        .strokeColor: UIColor.black,
        .foregroundColor: UIColor.white,
        .strokeWidth: -4.0,
        .font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!
    ]
    var memedImage: UIImage?
    // MARK: Outlets

    @IBOutlet weak var cameraButtonItem: UIBarButtonItem!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var pickedImageView: UIImageView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var shareButtonItem: UIBarButtonItem!
    
    // MARK: Actions

    @IBAction func pickAnImageFromLibrary(_ sender: Any) {
        pickupController(source: .photoLibrary)
    }
    
    @IBAction func pickAnImageUsingCamera(_ sender: Any) {
        pickupController(source: .camera)
    }
    
    func pickupController(source: UIImagePickerController.SourceType) {
        topTextField.endEditing(true)
        bottomTextField.endEditing(true)
        let controller = UIImagePickerController()
        controller.sourceType = source
        controller.delegate = self
        present(controller, animated: true, completion: nil)
    }
    
    @IBAction func clearImage(_ sender: Any) {
        pickedImageView.image = nil
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
        self.shareButtonItem.isEnabled = false
    }
    
    @IBAction func shareImage(_ sender: Any) {
        UIGraphicsBeginImageContext(self.view.frame.size)
        self.view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        memedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        if let newImage = memedImage {
            let controller = UIActivityViewController(activityItems: [newImage], applicationActivities: nil)
            controller.popoverPresentationController?.barButtonItem = sender as? UIBarButtonItem
            controller.completionWithItemsHandler = { [weak self]
                (activity, completed, items, error) in
                if completed {
                    self?.save()
                }
            }
            present(controller, animated: true, completion: nil)
        }
    }
    
    func save() {
        
        _ = Meme(topText: topTextField.text ?? "", bottomText: bottomTextField.text ?? "", originalImage: pickedImageView.image!, memedImage: memedImage!)
      
    }
    
    // MARK: view controller life cycle methods

    override func viewDidLoad() {
        super.viewDidLoad()
        cameraButtonItem.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        shareButtonItem.isEnabled = false

        setupTextField(texField: topTextField)
        setupTextField(texField: bottomTextField)
    }
    
    func setupTextField(texField: UITextField) {
        texField.defaultTextAttributes = defaultTextAttributes
        texField.textAlignment = .center
        texField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotification()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeToKeyboardNotification()
    }
}

// MARK: Keyboard methonds

extension ViewController {
    func subscribeToKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeToKeyboardNotification() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        for subView in self.view.subviews {
            if let textField = subView as? UITextField, textField.isEditing, textField == topTextField{
                return
            }
        }
        view.frame.origin.y -= getKeyboardHeight(notification)
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        if let userInfo = notification.userInfo {
            let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
            return keyboardSize.cgRectValue.height
        }
        return 0
    }
}

// MARK: Textfield Delegate methods

extension ViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
        print("editing")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
}

// MARK: ImagePickupController Delegate methods

extension ViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            self.pickedImageView.image = image
            self.shareButtonItem.isEnabled = true
        }
        dismiss(animated: true, completion: nil)
    }
}
