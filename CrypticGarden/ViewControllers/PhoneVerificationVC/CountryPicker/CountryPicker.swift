//
//  CountryPicker.swift
//  Hyber
//
//  Created by Taras on 12/1/16.
//  Copyright © 2016 Taras Markevych. All rights reserved.
//

import UIKit
import CoreTelephony
/// CountryPickerDelegate
///
/// - Parameters:
///   - picker: UIPickerVIew
///   - name: Name of selected element
///   - countryCode: Country code shortcut
///   - phoneCode: Phone digit code of country
///   - flag: Flag of country
@objc public protocol CountryPickerDelegate {
    func countryPhoneCodePicker(_ picker: CountryPicker, didSelectCountryWithName name: String, countryCode: String, phoneCode: String, flagEmoji: String)
}

/// Structure of country code picker
public struct Country {
    public let code: String?
    public let name: String?
    public let phoneCode: String?
    public let flagEmoji: String
    
    /// Country code initialization
    ///
    /// - Parameters:
    ///   - code: String
    ///   - name: String
    ///   - phoneCode: String
    ///   - flagName: String
    init(code: String?, name: String?, phoneCode: String?, flagEmoji: String) {
        self.code = code
        self.name = name
        self.phoneCode = phoneCode
        self.flagEmoji = flagEmoji
    }
}

open class CountryPicker: UIPickerView, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var countries: [Country]!
    open weak var countryPickerDelegate: CountryPickerDelegate?
    open var showPhoneNumbers: Bool = true
    
    /// init
    ///
    /// - Parameter frame: initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    /// Setup country code picker
    func setup() {
        countries = CountryPicker.countryNamesByCode()
        
        super.dataSource = self
        super.delegate = self
    }
    
    // MARK: - Country Methods
    
    /// setCountry
    ///
    /// - Parameter code: selected country
    open func setCountry(_ code: String) {
        
        var row = 0
        for index in 0..<countries.count {
            if countries[index].code == code {
                row = index
                break
            }
        }
        
        self.selectRow(row, inComponent: 0, animated: true)
        let country = countries[row]
        if let countryPickerDelegate = countryPickerDelegate {
            
            countryPickerDelegate.countryPhoneCodePicker(self, didSelectCountryWithName: country.name!, countryCode: country.code!, phoneCode: country.phoneCode!, flagEmoji: country.flagEmoji)
        }
    }
    
    /// setCountryByPhoneCode
    /// Init with phone code
    /// - Parameter phoneCode: String
    open func setCountryByPhoneCode(_ phoneCode: String) {
        var row = 0
        for index in 0..<countries.count {
            if countries[index].phoneCode == phoneCode {
                row = index
                break
            }
        }
        
        self.selectRow(row, inComponent: 0, animated: true)
        let country = countries[row]
        if let countryPickerDelegate = countryPickerDelegate {
            countryPickerDelegate.countryPhoneCodePicker(self, didSelectCountryWithName: country.name!, countryCode: country.code!, phoneCode: country.phoneCode!, flagEmoji: country.flagEmoji)
        }
    }
    
    // Populates the metadata from the included json file resource
    
    /// sorted array with data
    ///
    /// - Returns: sorted array with all information phone, flag, name
    open static func countryNamesByCode() -> [Country] {
        var countries = [Country]()

        
        guard let path = Bundle.main.path(forResource: "countryCodes2", ofType: "json"), let jsonData = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
            fatalError("cannot load json file")
        }
        
        do {
            if let jsonObjects = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? NSArray {
                
                for jsonObject in jsonObjects {
                    
                    guard let countryObj = jsonObject as? NSDictionary else {
                        fatalError("invalid country subdict")
                    }
                    
                    guard let code = countryObj["code"] as? String,
                        let phoneCode = countryObj["dial_code"] as? String,
                        let name = countryObj["name"] as? String,
                        let emoji = countryObj["emoji"] as? String
                        else {
                        fatalError("invalid country object : \(countryObj)")
                    }
                    
                    
                    let country = Country(code: code, name: name, phoneCode: phoneCode, flagEmoji: emoji)
                    countries.append(country)
                }
                
            }
        } catch {
            fatalError("countries deserialisation failed")
        }
        
//        createJsonprint(countries)

        return countries
    }
    
//    open static func createJsonprint(_ countries:[Country]) {
//        guard let path = Bundle.main.path(forResource: "countryCodesEmoji", ofType: "json"), let jsonData = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
//            fatalError("cannot load json file")
//        }
//
//        do {
//            if let jsonObjects = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String:AnyObject] {
//
//                var newCoutriesDictsArray:[[String:String]] = []
//
//                for country in countries {
//                    if let code = country.code, let coutryDict = jsonObjects[code] as? [String:AnyObject], let emoji = coutryDict["emoji"] as? String {
//                        let dict = [
//                            "name": country.name!,
//                            "dial_code": country.phoneCode!,
//                            "code": country.code!,
//                            "emoji": emoji
//                        ]
//                        newCoutriesDictsArray.append(dict)
//                    }
//                }
//
//                guard let data = try? JSONSerialization.data(withJSONObject: newCoutriesDictsArray, options: JSONSerialization.WritingOptions.prettyPrinted) else {
//                    return
//                }
//                let json = String(data: data, encoding: String.Encoding.utf8)
//
//
//                print(json!)
//
//            }
//        } catch {
//            fatalError("countries deserialisation failed")
//        }
//    }
    
    // MARK: - Picker Methods
    
    open func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    /// pickerView
    ///
    /// - Parameters:
    ///   - pickerView: CountryPicker
    ///   - component: Int
    /// - Returns: counts of array's elements
    open func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return countries.count
    }
    
    /// PickerView
    /// Initialization of Country pockerView
    /// - Parameters:
    ///   - pickerView: UIPickerView
    ///   - row: row
    ///   - component: count of countries
    ///   - view: UIView
    /// - Returns: UIView
    open func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var resultView: CountryView
        
        if view == nil {
            resultView = CountryView()
        } else {
            resultView = view as! CountryView
        }
        
        resultView.setup(countries[row])
        if !showPhoneNumbers {
            resultView.countryCodeLabel.isHidden = true
        }
        return resultView
    }
    
    /// Function for handing data from UIPickerView
    ///
    /// - Parameters:
    ///   - pickerView: CountryPickerView
    ///   - row: selectedRow
    ///   - component: description
    open func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let country = countries[row]
        if let countryPickerDelegate = countryPickerDelegate {
            countryPickerDelegate.countryPhoneCodePicker(self, didSelectCountryWithName: country.name!, countryCode: country.code!, phoneCode: country.phoneCode!, flagEmoji: country.flagEmoji)
        }
    }
}
