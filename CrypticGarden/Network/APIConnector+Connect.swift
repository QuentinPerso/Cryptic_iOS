////
////  APIConnector+Connect.swift
////  Marks
////
////  Created by Quentin Beaudouin on 02/11/2016.
////  Copyright © 2016 Quentin Beaudouin. All rights reserved.
////
//
////************************************
//// MARK: - Connect
////************************************
//
//import FBSDKCoreKit
//import FBSDKLoginKit
//
//import Alamofire
//
//extension APIConnector {
//
//    static func tryLoginWithFB(controller:UIViewController, completion:@escaping (Bool) -> Void){
//
//        fbLoginManager = FBSDKLoginManager()
//        fbLoginManager?.logOut()
//
//        if serverConfig?.facebookAuthString != nil {
//            let auth = serverConfig!.facebookAuthString.components(separatedBy: ",")
//
//            fbLoginManager!.logIn(withReadPermissions: auth, from: controller, handler: { (result, error) in
//                if error != nil {
//                    completion(false)
//                    fbLoginManager = nil
//                    NSLog("%@", error!.localizedDescription)
//                }
//                else if (result?.isCancelled)! {
//                    NSLog("Login cancelled", "")
//                    fbLoginManager = nil
//                }
//                else {
//                    loginWithFacebookToken(fbToken: result!.token.tokenString, completion: { (userSession) in
//                        if userSession != nil {
//                            NSLog("success login : %@", result!.token.tokenString)
//                            completion(true)
//                            fbLoginManager = nil
//                        }
//                        else {
//                            NSLog("error connection : no user returned")
//                            completion(false)
//                            fbLoginManager = nil
//                        }
//                    })
//                }
//            })
//        }
//        else {
//            NSLog("error connection : bad server conf")
//            completion(false)
//            fbLoginManager = nil
//            getServerConf(completion: { (conf) in
//
// //               self.tryLoginWithFB(controller: controller, completion: completion)
//            })
//        }
//    }
//
//    static func loginWithFacebookToken(fbToken:String, completion:@escaping (MKSUserSession?) -> Void){
//
////        NSLog("fb token : %@", fbToken)
//
//        let queryParams:[String:String] = [ "fb_token":"\(fbToken)",
//                                            "device_uniq_id":(UIDevice.current.identifierForVendor?.uuidString)!]
//
//        UIApplication.shared.isNetworkActivityIndicatorVisible = true
//        sessionManager.request(self.absoluteURLString(path: "auth/fbconnect"), parameters: queryParams).responseJSON { response in
//
//            UIApplication.shared.isNetworkActivityIndicatorVisible = false
//
////            logResponse(note: "login WithFacebookToken", value: response.result.value, meta: false)
//
//            if let jsonDict = response.result.value as? [String: AnyObject]{
//
//                if let error = jsonDict["error"] as? [String: AnyObject] {
//
//                    NSLog("error auth/fbconnect %@", error)
//                    completion(nil)
//                    return
//
//
//                }
//
//                let userSession = MKSUserSession(dictionary: jsonDict)
//
//                // store user archive to NSUserDefaults
//                UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: userSession), forKey: MKSUserSession.kudTokenIdentifier)
//
//                AppGroupSharedData.saveToken(userSession.accessToken)
//
//                self.userSession = userSession
//
//                completion(userSession)
//
//            }
//            else{
//                completion(nil)
//            }
//        }
//
//    }
//
//    static func retrieveLoginUser(){
//        // access possibly stored user/token infos
//
//        if let savedUserData = UserDefaults.standard.data(forKey: MKSUserSession.kudTokenIdentifier) {
//
//            do {
//                if let userSession = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(savedUserData as NSData) as? MKSUserSession {
//
//                    let savedAccessToken = KeychainWrapper.standard.string(forKey: MKSUserSession.keychainAccessTokenIdentifier)
//                    if savedAccessToken != nil {
//                       // NSLog("access token : %@", savedAccessToken!)
//                        userSession.accessToken = savedAccessToken
//                        self.userSession = userSession
//
//                        self.updateUserLoginStatus(completion: {
//                            self.updateUserSession()
//                        })
//
//                    }
//                    else {
//                        NSLog("user access token not found")
//                    }
//                }
//                else {
//                    NSLog("no logged in user")
//                }
//            }
//            catch{
//                NSLog("error unarchive user session")
//            }
//        }
//    }
//
//    static func updateUserLoginStatus(completion:(()->())?){
//
//        if FBSDKAccessToken.current() == nil {
//            return
//        }
//
//        guard let fbToken = FBSDKAccessToken.current().tokenString else {
//            self.disconnect()
//            return
//        }
//
//        let queryParams:[String:String] = [ "access_token" : self.userSession!.accessToken!,
//                                            "fb_token" : fbToken]
//
//        UIApplication.shared.isNetworkActivityIndicatorVisible = true
//        sessionManager.request(self.absoluteURLString(path: "auth/refresh"), parameters: queryParams).responseJSON { response in
//            UIApplication.shared.isNetworkActivityIndicatorVisible = false
//            //            logResponse(note: "updateUserSession", value: response.result.value, meta: false)
//
//            if let jsonDict = response.result.value as? [String: AnyObject]{
//
//                if let errorDict = jsonDict["error"] as? [String:AnyObject] {
//
//                    NSLog("error update User Login Status", errorDict)
//                    self.disconnect()
//                }
//                else {
//                    completion?()
//                }
//            }
//            else {
//                NSLog("network error update User Login Status")
//                //                self.disconnect()
//            }
//        }
//
//    }
//
//    static func updateUserSession(completion:(()->())? = nil){
//
//        let queryParams:[String:String] = [ "access_token" : self.userSession!.accessToken!]
//
//        UIApplication.shared.isNetworkActivityIndicatorVisible = true
//        sessionManager.request(self.absoluteURLString(path: "user/me"), parameters: queryParams).responseJSON { response in
//            UIApplication.shared.isNetworkActivityIndicatorVisible = false
////            logResponse(note: "updateUserSession", value: response.result.value, meta: false)
//
//            if let jsonDict = response.result.value as? [String: AnyObject]{
//
//                if let errorDict = jsonDict["error"] as? [String:AnyObject] {
//
////                    if errorDict["code"] as? Int == 105 {
////                        self.disconnect()
////                        NSLog("session expirée")
////                    }
//                    NSLog("error update user session", errorDict)
//                    self.disconnect()
//                }
//                else if self.userSession != nil {
//                    self.userSession?.update(dictionary: jsonDict)
//
//                    // store user archive to NSUserDefaults
//                    UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: userSession!), forKey: MKSUserSession.kudTokenIdentifier)
//
//                    AppGroupSharedData.saveToken(userSession?.accessToken)
//                }
//            }
//            else {
//                NSLog("network error update user session")
////                self.disconnect()
//            }
//            completion?()
//        }
//    }
//
//    static func disconnect(){
//        NSLog("user disconnected")
//
//        KeychainWrapper.standard.removeObject(forKey:  MKSUserSession.keychainAccessTokenIdentifier)
//        SavedPlacesStore.shared.bookmarkedPlaces = nil
//        SavedPlacesStore.shared.likedPlaces = nil
//
//        if userSession == nil {return}
//
//        fbLoginManager = FBSDKLoginManager()
//        fbLoginManager?.logOut()
//
//        let queryParams:[String:String] = [ "access_token" : self.userSession!.accessToken!,
//                                            "revoke_token" : self.userSession!.accessToken!]
//
//
//        self.userSession = nil
//
//        UIApplication.shared.isNetworkActivityIndicatorVisible = true
//        sessionManager.request(self.absoluteURLString(path: "auth/logout"), parameters: queryParams).responseJSON { response in
//            UIApplication.shared.isNetworkActivityIndicatorVisible = false
//            if let jsonDict = response.result.value as? [String: AnyObject]{
//                if let errorDict = jsonDict["error"] as? [String:AnyObject] {
//                    NSLog("disconnect error : %@", errorDict)
//                }
//            }
//            else {
//                NSLog("network error disconnect")
//            }
//        }
//
//    }
//
//    static func disconnectInstagram(completion:((Bool)->())?){
//        NSLog("user disconnected")
//
//        if userSession == nil {return}
//
//        let instaId = userSession?.user?.instagramId
//
//        userSession?.user?.instagramId = nil
//
//        let queryParams:[String:String] = [ "access_token" : self.userSession!.accessToken!]
//
//        UIApplication.shared.isNetworkActivityIndicatorVisible = true
//        sessionManager.request(self.absoluteURLString(path: "user/me/unlink-instagram"), parameters: queryParams).responseJSON { response in
//            UIApplication.shared.isNetworkActivityIndicatorVisible = false
//            var success = false
//            if let jsonDict = response.result.value as? [String: AnyObject]{
//                if let errorDict = jsonDict["error"] as? [String:AnyObject] {
//                    NSLog("disconnect error : %@", errorDict)
//                }
//                success = true
//            }
//            else {
//                NSLog("network error disconnect")
//            }
//            if !success {
//               userSession?.user?.instagramId = instaId
//            }
//            completion?(success)
//        }
//
//    }
//
//}

