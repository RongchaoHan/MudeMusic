//
//  Track.swift
//  final_application
//
//  Created by Michael Choi on 14/6/22.
//

import UIKit

class Track: NSObject{
    var name: String?
    var image: String?
    var imageData: UIImage?
    var url: String?
    var artist: String?
    var duration: Int64?
    var isSubscribed:Bool = false
    
    override init() {
        super.init()
    }
}
