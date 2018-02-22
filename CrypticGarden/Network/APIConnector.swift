//
//  APIConnector.swift
//  Busity
//
//  Created by Quentin Beaudouin on 10/09/2016.
//  Copyright © 2016 Instama. All rights reserved.
//

import Foundation
import Alamofire
//import FBSDKLoginKit
//import OneSignal


class APIConnector: NSObject{
    
    
    static var apiBaseURL = URL(string: "https://cryptic-garden-16026.herokuapp.com/api/")
    
    static var kGooglePlacesApi = "AIzaSyAdHCHmiKVw1_66qaq6zK4P9_IItBcu37c"
//    static var serverConfig:MKSServerConfiguration?
//
    static var userSession:CGUserSession?
//
//    static var fbLoginManager:FBSDKLoginManager?
    
    static var userAgent:String {
        
        let appName:String = Bundle.main.infoDictionary?[kCFBundleExecutableKey as String] as! String
        
        let appVersion:String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
       
        let osVersion:String = UIDevice.current.systemVersion

        let deviceType:String = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad) ? "Tablet": "Mobile"

        let locale:String = Locale.current.languageCode!

        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let device = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8 , value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }

        let ua = appName + "/" + appVersion + " (iOS;" + osVersion + ";" + deviceType + ";" + locale + ") " + device
        
        return ua

    }
    
    static var sessionManager:Alamofire.SessionManager {
        let manager = Alamofire.SessionManager.default
        manager.adapter = MashapeHeadersAdapter()
        return manager
    }
    
    static func dropDataBase(completion:@escaping (_ success:Bool) -> Void){
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        _ = sessionManager.request(self.absoluteURLString(path: "clear")).responseJSON { response in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            if succededRequest(response: response) {
                completion(true)
            }
            else{
                completion(false)
            }
        }
        
        
    }

//    static func getServerConf(completion:((MKSServerConfiguration?) -> Void)?){
//
//        UIApplication.shared.isNetworkActivityIndicatorVisible = true
//        sessionManager.request(self.absoluteURLString(path: "conf")).responseJSON { response in
//            UIApplication.shared.isNetworkActivityIndicatorVisible = false
//
////           logResponse(note: "server conf", value: response.result.value, meta: false)
//            if let jsonDict = response.result.value as? [String: AnyObject]{
//
//                let serveurConf = MKSServerConfiguration(dictionnary: jsonDict)
//
//                self.serverConfig = serveurConf
//
//                completion?(self.serverConfig)
//            }
//            else{
//                completion?(nil)
//
//            }
//        }
//    }
    
//    static func registerUserDevice(){
//
//        if UserDefaults.standard.object(forKey: "deviceRegistered") != nil {
//            return
//        }
//
//        let url = self.absoluteURLString(path: "device/register")
//
//        let formParams:[String:String] = [ "uniq_id" : (UIDevice.current.identifierForVendor?.uuidString)!]
//
//        UIApplication.shared.isNetworkActivityIndicatorVisible = true
//        sessionManager.request(url, method: .post, parameters: formParams, encoding: JSONEncoding.default).responseJSON(completionHandler: { response in
//            UIApplication.shared.isNetworkActivityIndicatorVisible = false
//
//            if let jsonDict = response.result.value as? [String: AnyObject]{
//
//                if let error = jsonDict["error"] as? [String : AnyObject]{
//                    _ = error
//                    return
//                }
//                UserDefaults.standard.set(true, forKey: "deviceRegistered")
//                UserDefaults.standard.synchronize()
//            }
//
//        })
//
//    }
    
//    static func openNotificationSettings(){
//
//        OneSignal.promptForPushNotifications(userResponse: { granted in
//
//            APIConnector.updateUserPushNotifsIdentifiers()
//
//        })
//        if UserDefaults.standard.bool(forKey: "option.1rstNotifEnabled") == true {
//            UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
//        }
//
//        UserDefaults.standard.set(true, forKey: "option.1rstNotifEnabled")
//        UserDefaults.standard.synchronize()
//
//    }
    
//    static func updateUserPushNotifsIdentifiers(){
//
//        let status: OSPermissionSubscriptionState = OneSignal.getPermissionSubscriptionState()
//        guard let oneSignalID = status.subscriptionStatus.userId else { return }
//        guard let deviceToken = status.subscriptionStatus.pushToken else { return }
//
//        guard let accessT =  userSession?.accessToken else { return }
//        guard let deviceUniqId = UIDevice.current.identifierForVendor?.uuidString else { return }
//
//
//
//        let url = self.absoluteURLString(path: "device/update")
//        let urlRequest = URLRequest(url: url)
//
//        let queryParams:[String:String] = [ "access_token" : accessT]
//
//        do {
//            let encodedURLRequest = try URLEncoding.queryString.encode(urlRequest, with: queryParams)
//
//
//            let formParams:[String:String] = [ "uniq_id" : deviceUniqId,
//                                               "apple_push_token" : deviceToken,
//                                               "onesignal_user_id" : oneSignalID]
//
//            NSLog("update UserPush Notifs Identifiers %@ %@", accessT, formParams)
//
//            UIApplication.shared.isNetworkActivityIndicatorVisible = true
//            sessionManager.request((encodedURLRequest.url?.absoluteString)!, method: .post, parameters: formParams, encoding: JSONEncoding.default).responseJSON(completionHandler: { response in
//                UIApplication.shared.isNetworkActivityIndicatorVisible = false
//
//                if let jsonDict = response.result.value as? [String: AnyObject]{
//
//                    if let error = jsonDict["error"] as? [String : AnyObject]{
//                        _ = error
//                        return
//                    }
//                }
//
//            })
//        }
//        catch{
//
//        }
//
//    }
    
}


//************************************
// MARK: - Private
//************************************

extension APIConnector {
    
    static func succededRequest(response:DataResponse<Any>) -> Bool {
        
        if let value = response.result.value as? [String:AnyObject] {
            if let success = value["success"] as? Bool, success == true { return true }
            else if value["error"] != nil { print(value) }
        }
        return false
    }
    
     static func absoluteURLString(path:String) -> URL{
        let url = URL(string: path.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlPathAllowed)!, relativeTo: apiBaseURL)!
        
        return url
        
    }

}

//************************************
// MARK: - URLRequest header formater
//************************************

class MashapeHeadersAdapter: RequestAdapter {
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        
        var urlRequest = urlRequest
        
        urlRequest.setValue(APIConnector.userAgent, forHTTPHeaderField: "User-Agent")
        
        if let lat  = LocationManager.shared.lastKnownCoord?.latitude,
            let lon  = LocationManager.shared.lastKnownCoord?.longitude {
            urlRequest.setValue("\(lat),\(lon)", forHTTPHeaderField: "X-Mks-Location")
        }
        
//        if let accessT = APIConnector.userSession?.accessToken {
//            urlRequest.setValue("\(accessT)", forHTTPHeaderField: "X-Mks-AccessToken")
//        }
        
        if let uuid = UIDevice.current.identifierForVendor?.uuidString {
            urlRequest.setValue(uuid, forHTTPHeaderField: "X-Mks-DeviceId")
        }
        
        
        let timeOffset = TimeZone.current.secondsFromGMT()
        urlRequest.setValue("\(timeOffset)", forHTTPHeaderField: "X-Mks-GMTOffset")

//        urlRequest.setValue("\(CityManager.shared.currentCity?.cityID ?? "NULL")", forHTTPHeaderField: "X-Mks-CurrentCity")
        
        print(urlRequest)
        
        return urlRequest
    }
}














