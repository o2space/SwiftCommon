//
//  O2SCColor.swift
//  O2SCoreKit
//
//  Created by wkx on 2020/6/22.
//  Copyright © 2020 O2Space. All rights reserved.
//

import Foundation
import UIKit

public class O2SCColor {
    
    public class func colorWithRGB(_ rgb: UInt64, alpha: CGFloat = 1) -> UIColor {
        let redValue = CGFloat((rgb & 0xFF0000) >> 16)/255.0
        let greenValue = CGFloat((rgb & 0xFF00) >> 8)/255.0
        let blueValue = CGFloat(rgb & 0xFF)/255.0
        return UIColor(red: redValue, green: greenValue, blue: blueValue, alpha: alpha)
    }
    
    public class func colorWithARGB(_ argb: UInt64) -> UIColor {
        let alpha = CGFloat((argb & 0xFF000000) >> 24)/255.0
        let redValue = CGFloat((argb & 0xFF0000) >> 16)/255.0
        let greenValue = CGFloat((argb & 0xFF00) >> 8)/255.0
        let blueValue = CGFloat(argb & 0xFF)/255.0
        return UIColor(red: redValue, green: greenValue, blue: blueValue, alpha: alpha)
    }
    
    public class func colorWithRGB(_ rgb: String, alpha: CGFloat = 1) -> UIColor {
        if rgb.isEmpty {
            return UIColor.clear
        }
        
        var cString = rgb.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        
        if cString.count == 0 {
            return UIColor.clear
        }
        
        if cString.hasPrefix("#") {
            cString.remove(at: cString.startIndex)
        }
        
        if cString.count < 6 && cString.count != 6 {
            
            return UIColor.clear
        }
        
        let value = "0x\(cString)"
        
        let scanner = Scanner(string:value)
        
        var hexValue : UInt64 = 0
        //查找16进制是否存在
        if scanner.scanHexInt64(&hexValue) {
            print(hexValue)
            let redValue = CGFloat((hexValue & 0xFF0000) >> 16)/255.0
              let greenValue = CGFloat((hexValue & 0xFF00) >> 8)/255.0
              let blueValue = CGFloat(hexValue & 0xFF)/255.0
              return UIColor(red: redValue, green: greenValue, blue: blueValue, alpha: alpha)
        }else{
            return UIColor.clear
        }
    }
}
