//
//  Music+CoreDataProperties.swift
//  final_application
//
//  Created by Michael Choi on 14/6/22.
//
//

import Foundation
import CoreData


extension Music {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Music> {
        return NSFetchRequest<Music>(entityName: "Music")
    }

    @NSManaged public var name: String?
    @NSManaged public var image: String?
    @NSManaged public var url: String?
    @NSManaged public var artist: String?
    @NSManaged public var duration: Int64
    @NSManaged public var isSubscribed: Bool

}

extension Music : Identifiable {

}
