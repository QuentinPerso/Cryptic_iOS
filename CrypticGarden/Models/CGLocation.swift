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
    
    static var kGoogleId = "googlePlaceId"
    static var kGoogleName = "googleName"
    static var kGoogleAdress = "googleAddress"
    static var kMessages = "messages"
    static var kPosition = "location"
    static var kCoordInPosition = "coordinates"
    
    var uniqueId: String!
    var googlePlaceId: String!
    var messages: [CGMessage]?
    var lastModificationDate: Int?
    var coordinate: CLLocationCoordinate2D!
    var googleName:String?
    var googleAddress:String?
    var mainTags:[String]?
    
    override func isEqual(_ object: Any?) -> Bool {
        if let object = object as? CGLocation { return self.googlePlaceId == object.googlePlaceId }
        return false
    }
    
    override init() {
        super.init()
    }
    
    init(dictionary:[String : AnyObject]) {

        self.uniqueId = dictionary["id"] as? String
        self.googlePlaceId = dictionary[CGLocation.kGoogleId] as? String
        self.googleAddress = dictionary[CGLocation.kGoogleAdress] as? String
        self.googleName = dictionary[CGLocation.kGoogleName] as? String
        
        if let messDicts = dictionary[CGLocation.kMessages] as? [[String : AnyObject]] {
            self.messages = []
            for dict in messDicts {
                messages?.append(CGMessage(dictionary: dict))
            }
            messages = messages?.reversed()
        }
        
        if self.messages != nil {
            mainTags = []
            for mess in messages! {
                mainTags?.append(mess.tag)
            }
            
        }
        
        self.lastModificationDate = dictionary["lastModificationDate"] as? Int ?? 0
        
        if let location = dictionary[CGLocation.kPosition] as? [String : AnyObject] {
            if let coordArray = location[CGLocation.kCoordInPosition] as? [Double] {
                let latitude = coordArray[1]
                let longitude = coordArray[0]
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

