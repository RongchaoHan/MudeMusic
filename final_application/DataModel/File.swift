//
//  File.swift
//  final_application
//
//  Created by Rongchao Han on 12/5/2022.
//

import UIKit
import FirebaseFirestoreSwift

enum FileType:Int{
    case image = 0
    case music = 1
    case video = 2
}

class File: NSObject, Codable{
    @DocumentID var id: String?
    var name: String?
    var uid: String?
    var packageID: String?
    var fileType: Int?
    var fileName: String?
    var details: String? = ""
    

    enum CodingKeys: String, CodingKey{
        case id
        case uid
        case name
        case packageID
        case fileType
        case fileName
        case details
    }
    func printFile(){
        print(
            "///////////////////////////////////////////// \n" +
            "Document ID: \(String(describing: id))" +
            "File Name:  \(String(describing: name)) \n" +
            "Package ID:  \(String(describing: packageID)) \n" +
            "UserID: \(String(describing: uid)) \n" +
            "File Type: \(String(describing: fileType)) \n" +
            "File Name: \(String(describing: fileName)) \n" +
            "File Details: \(String(describing: details))"
        )
    }
}

extension File{
    var fileTypeSelection: FileType{
        get{
            return FileType(rawValue: self.fileType!)!
        }
        set{
            self.fileType = newValue.rawValue
        }
    }
}
