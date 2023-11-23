//
//  Music+CoreDataClass.swift
//  final_application
//
//  Created by Michael Choi on 14/6/22.
//
//

import Foundation
import CoreData

@objc(Music)
public class Music: NSManagedObject {
    enum CodingKeys: String, CodingKey{
        case name
        case image
        case artist
        case url
        case duration
        case isSubscribed
    }
    
    func print(){
        Swift.print(
            "Music Name: \(String(describing: name)) ,\n" +
            "Music Image: \(String(describing: image)) ,\n" +
            "Music Artist: \(String(describing:artist)) ,\n" +
            "Music FileName: \(String(describing:url)) "
        )
    }
}
