//
//  CGLocation.swift
//  CrypticGarden
//
//  Created by admin on 11/01/2018.
//  Copyright © 2018 Marks. All rights reserved.
//

import UIKit
import CoreLocation

class CGMessage: NSObject, NSCoding {
    
    var uniqueId: String!
    var ownerId:String!
    var text: String!
    var tag: String!
    var postDate: Int?

    
    override init() {
        super.init()
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        if let object = object as? CGLocation { return self.uniqueId == object.uniqueId }
        return false
    }
    
    init(dictionary:[String : AnyObject]) {

        self.uniqueId = dictionary["id"] as? String
        self.ownerId = dictionary["ownerId"] as? String
        self.text = dictionary["text"] as? String
        self.tag = dictionary["tag"] as? String
        self.postDate = dictionary["postDate"] as? Int
        
        
        super.init()

    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(uniqueId, forKey: "uniqueId")
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        self.uniqueId = aDecoder.decodeObject(forKey: "uniqueId") as? String
        super.init()
    }

}

