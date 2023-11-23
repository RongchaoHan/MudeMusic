//
//  User.swift
//  final_application
//
//  Created by Rongchao Han on 14/5/2022.
//

import UIKit
import FirebaseFirestoreSwift

class User: NSObject, Codable {
    @DocumentID var id: String?
    var name: String?
    var email: String?
    var uid: String?
    var root: String?
    
    enum CodingKeys: String, CodingKey{
        case id
        case uid
        case email
        case name
        case root
    }
    
    func printUser(){
        print(
            "///////////////////////////////////////////// \n" +
            "Document ID: \(String(describing: id)) \n" +
            "Username:  \(String(describing: name)) \n" +
            "Email:  \(String(describing: email)) \n" +
            "UserID: \(String(describing: uid)) \n" +
            "Root PackageID: \(String(describing: root)) \n"
        )
    }
}
