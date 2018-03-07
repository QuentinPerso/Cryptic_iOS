//
//  ViewController+Connect.swift
//  CrypticGarden
//
//  Created by Quentin Beaudouin on 24/02/2018.
//  Copyright © 2018 Marks. All rights reserved.
//

import UIKit
import Firebase

extension UIViewController: PhoneVerificationDelegate {
    
    func firebasePhoneConnect() {
        let configuration = Configuration(headerBackground: nil, requestCode: { phoneNumber, completion in
            PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (verificationID, error) in
                if let error = error {
                   print("verify Phone Number error", error)
                    return
                }
                completion(verificationID, nil)
            }
        }, signIn: { verificationID, verificationCode, completion in
            let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: verificationCode)
            Auth.auth().signIn(with: credential) { (user, error) in
                if let error = error {
                    print("sign in error",error)
                    completion(error)
                    return
                }
                print("log in success - user :", user?.uid ?? "no user :(")
                
                completion(nil)

            }
        })
        
        let vc = PhoneVerificationController(configuration: configuration)
        present(vc, animated: true)
    }
    
    private func callAPISignIn(fireBaseId:String) {
        
    }
    
    public func cancelled(controller: PhoneVerificationController) {
        controller.dismiss(animated: true)
    }
    
    public func verified(phoneNumber: String, controller: PhoneVerificationController) {
        controller.dismiss(animated: true)
    }

}
