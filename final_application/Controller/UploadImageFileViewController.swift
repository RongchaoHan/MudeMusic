//
//  UploadImageFileViewController.swift
//  final_application
//
//  Created by Rongchao Han on 29/5/2022.
//

import UIKit


protocol UploadImageFileDelegate:AnyObject{
    func didTapSubmitButton(size: String, createdDate: String, description: String)
}

class UploadImageFileViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate, UITextViewDelegate {

    @IBOutlet weak var uploadImageMenuButton: UIBarButtonItem!
    @IBOutlet weak var imageVisualizer: UIImageView!
    
    @IBOutlet weak var fileNameTextField: UILabel!
    @IBOutlet weak var fileSizeTextField: UILabel!
    @IBOutlet weak var createdDateTextField: UILabel!
    @IBOutlet weak var usernameTextField: UILabel!
    
    @IBOutlet weak var descriptionTextView: UITextView!
    
    weak var delegate: UploadImageFileDelegate?
    
    var username = String()
    var filename = String()
    var imageData = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let previewTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        imageVisualizer.isUserInteractionEnabled = true
        imageVisualizer.addGestureRecognizer(previewTapRecognizer)
        
        let uploadImageFromGaralleryItem = UIAction(title: "From Garallery", image: UIImage(systemName: "square.and.arrow.up")) { (action) in

                print("Users action was tapped")
                self.uploadFromGaralleryDidTapped()
            }
 
        let uploadImageUsingCameraItem = UIAction(title: "Using Camera", image: UIImage(systemName: "camera")) { (action) in

                print("Add User action was tapped")
        }
        let uploadImageMenu = UIMenu(title: "Upload Image Menu", options: .displayInline, children: [uploadImageFromGaralleryItem , uploadImageUsingCameraItem])
        uploadImageMenuButton.menu = uploadImageMenu
        
        descriptionTextView.delegate = self
        
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer){
        
        
    }
    
    func uploadFromGaralleryDidTapped(){
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        let imageData = NSData(data: image!.jpegData(compressionQuality: 1)!)
        let imageString = imageData.base64EncodedString()
        
        self.imageData = imageString
        
        self.imageVisualizer.image = image
        self.dismiss(animated: true, completion: nil)
        
        self.usernameTextField.text = username
        self.fileNameTextField.text = filename
        self.fileSizeTextField.text = String(Double(imageData.count)/1000.0) + " KB"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
        self.createdDateTextField.text = dateFormatter.string(from: Date())
        
        descriptionTextView.text = "Enter some description for the file"
        descriptionTextView.textColor = UIColor.lightGray
        
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if descriptionTextView.textColor == UIColor.lightGray{
            descriptionTextView.text = nil
            descriptionTextView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if descriptionTextView.text.isEmpty{
            descriptionTextView.text = "Enter some description"
            descriptionTextView.textColor = UIColor.lightGray
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func submitDidTapped(_ sender: Any) {
        delegate?.didTapSubmitButton(size: fileSizeTextField.text!, createdDate: createdDateTextField.text!, description: descriptionTextView.text!)
        dismiss(animated: true, completion: nil)
    }

}
