//
//  MKSUser.swift
//  Marksapp
//
//  Created by Aurélien Hugelé on 19/04/16.
//  Copyright © 2016 Marks. All rights reserved.
//

import UIKit

class CGUserSession : NSObject, NSCoding {
    
    var accessToken: String?
    static let keychainAccessTokenIdentifier: String = "com.marks.marksapp.accessToken"
    static let kudTokenIdentifier: String = "kSUDSavedUserSession"
    
    
    
    var user:CGUser?
    
    init(dictionary:[String:AnyObject]){
        
        let authDict = dictionary["authData"] as! [String:AnyObject]
        
        self.accessToken = authDict["access_token"]  as? String
        
        let userDict = dictionary["user"] as! [String:AnyObject]

        self.user = CGUser(dictionary: userDict)
        
        // these properties can't be changed after this init.
        
        super.init()
        
        update(dictionary: userDict);
        
//        let saveSuccessful: Bool = KeychainWrapper.standard.set(self.accessToken!, forKey: MKSUserSession.keychainAccessTokenIdentifier)
//        if !saveSuccessful {
//            NSLog("Could'nt store the user accessToken to Keychain. have to relogin")
//        }
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        
        // do not archive accessToken!
        self.user = aDecoder.decodeObject(forKey: "user") as? CGUser
        
        super.init()
    }
    
    public func encode(with aCoder: NSCoder) {
        
        aCoder.encode(user, forKey: "user")
    }
    
    func update(dictionary: [String : AnyObject]) {
        
        // do NOT update uniqueId and accessToken, they are immutable!
        

        self.user?.update(dictionary: dictionary)
        
    }

}
