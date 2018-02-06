//
//  String+Functions.swift
//  Marks
//
//  Created by Quentin Beaudouin on 02/11/2016.
//  Copyright © 2016 Quentin Beaudouin. All rights reserved.
//

import Foundation
import UIKit

extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
    

    subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        let start = index(startIndex, offsetBy: r.lowerBound)
        let end = index(startIndex, offsetBy: r.upperBound)
        return String(self[Range(start ..< end)])
    }
    
}


extension Int {
    func format(f: String) -> String {
        return String(format: "%\(f)d", self)
    }
}

extension Double {
    func format(f: String) -> String {
        return String(format: "%\(f)f", self)
    }
}

enum FontWeight:String {
    case light = "Light"
    case regular = "Regular"
    case medium = "Medium"
    case bold = "Bold"
    case black = "Black"
    
}

enum FontFamily:String {
    case gotham = "Gotham-"
    case mtSerra = "Montserrat-"
    
}

extension NSAttributedString {
    
//    convenience init(_ text:String?,
//                     family:FontFamily = .mtSerra,
//                     weight:FontWeight = .regular,
//                     size:CGFloat,
//                     color:UIColor = UIColor.black,
//                     shadowColor:UIColor = UIColor.clear,
//                     shadowOffset:CGSize = CGSize(width: 0, height: -1),
//                     shadowBlur:CGFloat = 1.0,
//                     underlined:Bool = false) {
//
//        let weightString = (weight == .black || weight == .bold ||  weight == .medium || weight == .regular) ? "Regular" : "Light"
//
//        let fontName = (family == .gotham) ? "Gotham-Book" : "Montserrat-\(weightString)"
//
//        let titleAttributes = [
//            NSFontAttributeName : UIFont(name: fontName, size: size)!,
//            NSForegroundColorAttributeName: color,
//            NSBackgroundColorAttributeName: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0),
//            NSShadowAttributeName: NSShadow(color: shadowColor, offset: shadowOffset, blur: shadowBlur),
//            NSParagraphStyleAttributeName: NSParagraphStyle.justified(),
//            NSUnderlineStyleAttributeName: underlined ? NSUnderlineStyle.styleSingle.rawValue : NSUnderlineStyle.styleNone.rawValue
//            ] as [String : Any]
//
//        self.init(string: text ?? "", attributes: titleAttributes)
//    }
    
}


extension NSShadow {
    
    convenience init(color:UIColor, offset:CGSize, blur:CGFloat) {
        self.init()
        self.shadowColor = color
        self.shadowOffset = offset
        self.shadowBlurRadius = blur
    }
    
    static func placeTitle() -> NSShadow {
        let shadow = NSShadow()
        shadow.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.6643300514)
        shadow.shadowOffset = CGSize(width: 0, height: -1)
        shadow.shadowBlurRadius = 1.0
        
        return shadow
    }
    
    static func placeInfos() -> NSShadow {
        let shadow = NSShadow()
        shadow.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.3472816781)
        shadow.shadowOffset = CGSize(width: 0, height: -1)
        shadow.shadowBlurRadius = 1.0
        
        return shadow
    }
    
    
}

extension NSParagraphStyle {
    
    static func justified() -> NSParagraphStyle {
        let paragraphStlye = NSMutableParagraphStyle()
        paragraphStlye.alignment = .justified
        return paragraphStlye
    }
}


extension UIFont {
    func sizeOfString (string: String, constrainedToWidth width: Double) -> CGSize {
        
        
        return NSString(string: string).boundingRect(with: CGSize(width: width, height: Double.greatestFiniteMagnitude),
                                                             options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                                             attributes: [NSAttributedStringKey.font: self],
                                                             context: nil).size
    }
    
//    static func mksFont(family: FontFamily = .mtSerra, size:CGFloat, weight:FontWeight = .regular) -> UIFont {
//        
//        var weightString =  "Regular"
//        switch weight {
//        case .black:
//            weightString = "Black"
//        case .bold:
//            weightString = "Bold"
//        case .regular:
//            weightString = "Regular"
//        case .light:
//            weightString = "Light"
//        default:
//            weightString = "Regular"
//        }
//        
//        let fontName = (family == .gotham) ? "Gotham-Book" : "Montserrat-\(weightString)"
//        
//        return UIFont(name: fontName, size: size)!
//        
//    }
}

