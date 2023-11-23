//
//  AddNewItemTableViewCell.swift
//  final_application
//
//  Created by Michael Choi on 19/5/22.
//

import UIKit

protocol AddNewItemDelegate:AnyObject{
    func didTapButtonMenuItem(withTag: String, itemName: String)
}
class AddNewItemTableViewCell: UITableViewCell{
    
    
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var newItemNameTextField: UITextField!
    weak var delegate: AddNewItemDelegate?
    
    var newItemName:String = ""
    let ADD_IMAGE = "ADD_IMAGE"
    let ADD_PACKAGE = "ADD_PACKAGE"
    let ADD_MUSIC = "ADD_MUSIC"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        newItemNameTextField.awakeFromNib()
        let addNewImageItem = UIAction(title: "Add new Image", image: UIImage(systemName: "doc.badge.plus")){
            [self]action in
            
            delegate?.didTapButtonMenuItem(withTag: ADD_IMAGE,
                                           itemName: self.newItemNameTextField.text!)
        }
        let addNewMusicItem = UIAction(title: "Add new Music", image: UIImage(systemName: "music.note")){
            [self]action in
            
            delegate?.didTapButtonMenuItem(withTag: ADD_MUSIC,
                                           itemName: self.newItemNameTextField.text!)
        }
                
        let addNewPackageItem = UIAction(title: "Add new Package", image: UIImage(systemName: "folder.badge.plus")){
            [self]action in
            
            delegate?.didTapButtonMenuItem(withTag: ADD_PACKAGE,
                                           itemName: self.newItemNameTextField.text!)
        }
                
        let addItemMenu = UIMenu(title: "", options: .displayInline, children: [addNewPackageItem, addNewImageItem, addNewMusicItem])
        submitButton.menu = addItemMenu
        
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
