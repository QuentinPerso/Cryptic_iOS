//
//  CGLocation.swift
//  CrypticGarden
//
//  Created by admin on 11/01/2018.
//  Copyright © 2018 Marks. All rights reserved.
//

import UIKit
import CoreLocation

class CGLocation: NSObject, NSCoding {
    
    var uniqueId: String!
    var googlePlaceId: String!
    var messages: [CGMessage]?
    var lastModificationDate: Int?
    var coordinate: CLLocationCoordinate2D!
    var googleAddress:String?
    var mainTags:[String]?
    
    override func isEqual(_ object: Any?) -> Bool {
        if let object = object as? CGLocation { return self.uniqueId == object.uniqueId }
        return false
    }
    
    override init() {
        super.init()
    }
    
    init(dictionary:[String : AnyObject]) {

        self.uniqueId = dictionary["id"] as? String
        self.googlePlaceId = dictionary["googlePlaceId"] as? String
        self.googleAddress = dictionary["googleAddress"] as? String
        
        if let messDicts = dictionary["messages"] as? [[String : AnyObject]] {
            self.messages = []
            for dict in messDicts {
                messages?.append(CGMessage(dictionary: dict))
            }
        }
        
        if self.messages != nil {
            mainTags = []
            for mess in messages! {
                mainTags?.append(mess.tag)
            }
            
        }
        
        self.lastModificationDate = dictionary["lastModificationDate"] as? Int ?? 0
        
        if let location = dictionary["location"] as? [String : AnyObject] {
            if let coordArray = location["coordinates"] as? [Double] {
                let latitude = coordArray[0]
                let longitude = coordArray[1]
                self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            }
            
        }
        
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

