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
    var instagramId: String?
    var firstName: String?
    var lastName: String?
    var pictureUrlString: String?
    var pictureUrl: URL?{
        return (pictureUrlString != nil) ? URL(string: pictureUrlString!) : nil
    }
    
    var followerCount = 0
    var followingCount = 0
    var placeCount = 0
    
    var instagramUrl:URL?
    
    var lastCheckingString:String?
    
    override func isEqual(_ object: Any?) -> Bool {
        if let object = object as? CGUser { return self.uniqueId == object.uniqueId }
        return false 
    }
    
    var fullName:String? {
        get {
            return firstName! + " " + lastName!
        }
    }
  
    init(dictionary:[String : AnyObject]) {
        // these properties can't be changed after this init.
        self.uniqueId = dictionary["id"] as? String
        self.firstName = dictionary["first_name"] as? String
        self.lastName = dictionary["last_name"] as? String
        
        self.followerCount = dictionary["followers_count"] as? Int ?? 0
        self.followingCount = dictionary["followings_count"] as? Int ?? 0
        self.placeCount = dictionary["likedplaces_count"] as? Int ?? 0
        
        self.instagramId = dictionary["ig_id"] as? String
        
        if let picture = dictionary["picture"] as? [String : AnyObject] {

//            pictureUrlString = MKSPlacesHelper.pictUrlFromMd5(pictDict: picture)
            pictureUrlString = picture["path"] as? String
            
        }
        
        if let urlString = dictionary["redirect_instagram_url"] as? String {
            instagramUrl = URL(string: urlString)
        }
        
        super.init()
        
        exctractLastChecking(dictionary)
        
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
        
        self.followerCount = dictionary["followers_count"] as? Int ?? 0
        self.followingCount = dictionary["followings_count"] as? Int ?? 0
        self.placeCount = dictionary["likedplaces_count"] as? Int ?? 0
        
        self.instagramId = dictionary["ig_id"] as? String
        
        if let picture = dictionary["picture"] as? [String : AnyObject] {
            
//            pictureUrlString = MKSPlacesHelper.pictUrlFromMd5(pictDict: picture)
            pictureUrlString = picture["path"] as? String
            
        }
        
        if let urlString = dictionary["redirect_instagram_url"] as? String {
            instagramUrl = URL(string: urlString)
        }
    }
    
    func exctractLastChecking(_ dictionary:[String : AnyObject]) {
        
        if let payload = dictionary["payload"] as? [String : AnyObject], let timestamp = payload["timestamp"] as? Int  {
            
            let date = Date()
            let timeInterval = Int(date.timeIntervalSince1970) - timestamp
            
            if timeInterval/604800 > 1 {
                lastCheckingString = String(format: "WEEK_AGO".localized, arguments: [timeInterval/604800])
            }
            else if timeInterval/86400 > 1 {
                lastCheckingString = String(format: "DAY_AGO".localized, arguments: [timeInterval/86400])
            }
            else if timeInterval/3600 > 1 {
                lastCheckingString = String(format: "HOUR_AGO".localized, arguments: [timeInterval/3600])
            }
            else if timeInterval/60 > 1 {
                lastCheckingString = String(format: "MIN_AGO".localized, arguments: [timeInterval/60])
            }
            else {
                lastCheckingString = String(format: "SEC_AGO".localized, arguments: [timeInterval])
            }
            
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
