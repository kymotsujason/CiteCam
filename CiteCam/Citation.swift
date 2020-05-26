//
//  Citation.swift
//  CiteCam
//
//  This file handles the Citation object.
//  A string and image are required to create a Citation object.
//  This file also contains the methods for storing files.
//  It will encode and decode the files for use in other class files.
//
//  Main Functions:
//  Converting ISBN into a citation with a photo.
//  Encoding and decoding files.
//
//  Created by Jason Yue 11/17/16
//

import UIKit

class Citation: NSObject, NSCoding {
    
    // Variables of the Citation class.
    var name: String
    var photo: UIImage?
    
    // Locations and initialization for storing files.
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("citations")
    
    // For encoding an decoding files.
    struct PropertyKey {
        static let nameKey = "name"
        static let photoKey = "photo"
    }
    
    // Initializes this class.
    init?(name: String, photo: UIImage?) {
        
        // Initialize stored properties.
        self.name = name
        self.photo = photo
        
        super.init()
        
        // Initialization should fail if there is no citation (name).
        if(name.isEmpty) {
            return nil
        }
    }
    
    // Encoding for files.
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: PropertyKey.nameKey)
        aCoder.encode(photo, forKey: PropertyKey.photoKey)
    }
    
    // Decoding for files and reinitialization of the Citation Object.
    required convenience init?(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObject(forKey: PropertyKey.nameKey) as! String
        
        // Because photo is an optional property of Citation, use conditional cast.
        let photo = aDecoder.decodeObject(forKey: PropertyKey.photoKey) as? UIImage
        
        // Must call designated initializer.
        self.init(name: name, photo: photo)
    }
    
}
