//
//  O2SCSelfAware.swift
//  O2SCoreKit
//
//  Created by wkx on 2020/6/22.
//  Copyright © 2020 O2Space. All rights reserved.
//

import UIKit

public protocol O2SCSelfAware: class {
    static func awake()
}

class O2SCNothingToAwakeFunc {
    static func harmlessFunction() {
        let expectedClassCount = Int(objc_getClassList(nil, 0))
        let allClasses = UnsafeMutablePointer<AnyClass>.allocate(capacity: expectedClassCount)
        let autoreleasingAllClasses = AutoreleasingUnsafeMutablePointer<AnyClass>(allClasses)
        let actualClassCount = objc_getClassList(autoreleasingAllClasses, Int32(Int(expectedClassCount)))
//        debugPrint(Date())
        for index in 0 ..< actualClassCount {
            (allClasses[Int(index)] as? O2SCSelfAware.Type)?.awake()
        }
//        debugPrint(Date())
        allClasses.deallocate()
    }
}

extension UIApplication {
    internal static let o2sc_runOnce:Void = {
        O2SCNothingToAwakeFunc.harmlessFunction()
    }()
    
    override open var next: UIResponder?{
        UIApplication.o2sc_runOnce
        return super.next
    }
}
