//
//  ISBN.swift
//  CiteCam
//
//  This file handles the ISBN object.
//  A String containing numbers is required to create a ISBN object.
//  This file also contains the methods for storing files.
//  It will encode and decode the files for use in other class files.
//
//  Created by Jason Yue on 2016-12-05.
//

import UIKit

class ISBN: NSObject, NSCoding {
    
    // Variables of the ISBN class.
    var isbn: String
    
    // Locations and initialization for storing files.
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("isbn")
    
    // For encoding an decoding files.
    struct PropertyKey {
        static let isbnKey = "isbn"
    }
    
    // Initializes this class.
    init?(isbn: String) {
        
        // Initialize stored properties.
        self.isbn = isbn
        
        super.init()
        
        // Initialization should fail if there is no isbn.
        if(isbn.isEmpty) {
            return nil
        }
    }
    
    // Encoding for files.
    func encode(with aCoder: NSCoder) {
        aCoder.encode(isbn, forKey: PropertyKey.isbnKey)
    }
    
    // Decoding for files and reinitialization of the ISBN Object.
    required convenience init?(coder aDecoder: NSCoder) {
        let isbn = aDecoder.decodeObject(forKey: PropertyKey.isbnKey) as! String
        
        // Must call designated initializer.
        self.init(isbn: isbn)
    }
    
}
