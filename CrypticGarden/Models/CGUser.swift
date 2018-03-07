//
//  CGUser.swift
//  CrypticGarden
//
//  Created by admin on 11/01/2018.
//  Copyright © 2018 Marks. All rights reserved.
//

import UIKit

class CGUser: NSObject, NSCoding {
    
    var uniqueId: String?
    var firebaseId: String?
    var firstName: String?
    var lastName: String?
    var pictureUrlString: String?
    var pictureUrl: URL?{
        return (pictureUrlString != nil) ? URL(string: pictureUrlString!) : nil
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        if let object = object as? CGUser { return self.uniqueId == object.uniqueId }
        return false 
    }
    
  
    init(dictionary:[String : AnyObject]) {
        // these properties can't be changed after this init.
        self.uniqueId = dictionary["id"] as? String
        self.firstName = dictionary["first_name"] as? String
        self.lastName = dictionary["last_name"] as? String
        
        self.firebaseId = dictionary["firebaseId"] as? String
        
        if let picture = dictionary["picture"] as? [String : AnyObject] {
            pictureUrlString = picture["path"] as? String
        }

        super.init()
        
        
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(uniqueId, forKey: "uniqueId")
        aCoder.encode(firstName, forKey: "firstName")
        aCoder.encode(lastName, forKey: "lastName")
        aCoder.encode(pictureUrlString, forKey: "pictureUrl")
    }
    
    func update(dictionary:[String : AnyObject]) {
        
        self.firstName = dictionary["first_name"] as? String
        self.lastName = dictionary["last_name"] as? String
        
        self.firebaseId = dictionary["firebaseId"] as? String
        
        if let picture = dictionary["picture"] as? [String : AnyObject] {
            
//            pictureUrlString = MKSPlacesHelper.pictUrlFromMd5(pictDict: picture)
            pictureUrlString = picture["path"] as? String
            
        }
        
    }
    
    
    init(dictionaryTest:[String : AnyObject]) {
    
        
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.uniqueId = aDecoder.decodeObject(forKey: "uniqueId") as? String
        self.firstName = aDecoder.decodeObject(forKey: "firstName") as? String
        self.lastName  = aDecoder.decodeObject(forKey: "lastName") as? String
        self.pictureUrlString = aDecoder.decodeObject(forKey: "pictureUrl") as? String
        
        super.init()
    }
    
    
    
}
