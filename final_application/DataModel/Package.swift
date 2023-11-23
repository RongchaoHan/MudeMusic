//
//  Package.swift
//  final_application
//
//  Created by Rongchao Han on 14/5/2022.
//

import UIKit
import FirebaseFirestoreSwift


class Package: NSObject, Codable{
    @DocumentID var id: String?
    var name: String?
    var uid: String?
    var previousPackageID: String? = ""
    var files: [File] = []
    var packages:[Package] = []
    
    enum CodingKeys: String, CodingKey{
        case id
        case name
        case files
        case previousPackageID
        case packages
    }
    
    func printPackage(){
        print(
            "///////////////////////////////////////////// \n" +
            "Document ID: \(String(describing: id)) \n" +
            "Package Name:  \(String(describing: name)) \n" +
            "Previous Package ID:  \(String(describing: previousPackageID)) \n" +
            "UserID: \(String(describing: uid)) \n" +
            "Packages List: \(String(describing: packages)) \n" +
            "Files List \(String(describing: files)) \n"
        )
    }
}
