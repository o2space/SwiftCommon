//
//  O2SCRuntime.swift
//  O2SCoreKit
//
//  Created by wkx on 2020/6/22.
//  Copyright © 2020 O2Space. All rights reserved.
//

import Foundation

// NSObject无参方法运行时调用 其他使用时自定义
// sendMessage()
public class O2SCRuntime {
    
//    //模板
//    public class func to_返回值类型(instance:AnyObject, selector:Selector, 参数...) {
//        if instance.responds(to: selector) {
//            if let selectorMethod = class_getInstanceMethod(type(of: instance), selector) {
//                let selectorImp = method_getImplementation(selectorMethod)
//                typealias selectorImpType = @convention(c)(UnsafeRawPointer, Selector, 参数类型...) -> 返回值类型
//                let instancePoint = unsafeBitCast(instance, to: UnsafeRawPointer.self)
//                let 返回值 = unsafeBitCast(selectorImp, to: selectorImpType.self)(instancePoint, selector, 参数...)
//                return 返回值
//            }
//        }
//    }
    
    
    public class func to_v(instance:AnyObject, selector:Selector) {
        if instance.responds(to: selector) {
            if let selectorMethod = class_getInstanceMethod(type(of: instance), selector) {
                let selectorImp = method_getImplementation(selectorMethod)
                typealias selectorImpType = @convention(c)(UnsafeRawPointer, Selector) -> Void
                let instancePoint = unsafeBitCast(instance, to: UnsafeRawPointer.self)
                unsafeBitCast(selectorImp, to: selectorImpType.self)(instancePoint, selector)
            }
        }
    }
    
    public class func to_v(cls:AnyClass, selector:Selector) {
        if cls.responds(to: selector) {
            if let selectorMethod = class_getClassMethod(cls, selector) {
                let selectorImp = method_getImplementation(selectorMethod)
                typealias selectorImpType = @convention(c)(UnsafeRawPointer, Selector) -> Void
                let instancePoint = unsafeBitCast(cls, to: UnsafeRawPointer.self)
                unsafeBitCast(selectorImp, to: selectorImpType.self)(instancePoint, selector)
            }
        }
    }
    
    public class func to_s(instance:AnyObject, selector:Selector) -> String? {
        if instance.responds(to: selector) {
            if let selectorMethod = class_getInstanceMethod(type(of: instance), selector) {
                let selectorImp = method_getImplementation(selectorMethod)
                typealias selectorImpType = @convention(c)(UnsafeRawPointer, Selector) -> String?
                let instancePoint = unsafeBitCast(instance, to: UnsafeRawPointer.self)
                let result = unsafeBitCast(selectorImp, to: selectorImpType.self)(instancePoint, selector)
                return result
            }
        }
        return nil
    }
    
    public class func to_s(cls:AnyClass, selector:Selector) -> String? {
        if cls.responds(to: selector) {
            if let selectorMethod = class_getClassMethod(cls, selector) {
                let selectorImp = method_getImplementation(selectorMethod)
                typealias selectorImpType = @convention(c)(UnsafeRawPointer, Selector) -> String?
                let instancePoint = unsafeBitCast(cls, to: UnsafeRawPointer.self)
                let result = unsafeBitCast(selectorImp, to: selectorImpType.self)(instancePoint, selector)
                return result
            }
        }
        return nil
    }
    
    public class func to_b(instance:AnyObject, selector:Selector) -> Bool? {
        if instance.responds(to: selector) {
            if let selectorMethod = class_getInstanceMethod(type(of: instance), selector) {
                let selectorImp = method_getImplementation(selectorMethod)
                typealias selectorImpType = @convention(c)(UnsafeRawPointer, Selector) -> Bool
                let instancePoint = unsafeBitCast(instance, to: UnsafeRawPointer.self)
                let result = unsafeBitCast(selectorImp, to: selectorImpType.self)(instancePoint, selector)
                return result
            }
        }
        return nil
    }
    
    public class func to_b(cls:AnyClass, selector:Selector) -> Bool? {
        if cls.responds(to: selector) {
            if let selectorMethod = class_getClassMethod(cls, selector) {
                let selectorImp = method_getImplementation(selectorMethod)
                typealias selectorImpType = @convention(c)(UnsafeRawPointer, Selector) -> Bool
                let instancePoint = unsafeBitCast(cls, to: UnsafeRawPointer.self)
                let result = unsafeBitCast(selectorImp, to: selectorImpType.self)(instancePoint, selector)
                return result
            }
        }
        return nil
    }
    
    public class func to_i(instance:AnyObject, selector:Selector) -> Int? {
        if instance.responds(to: selector) {
            if let selectorMethod = class_getInstanceMethod(type(of: instance), selector) {
                let selectorImp = method_getImplementation(selectorMethod)
                typealias selectorImpType = @convention(c)(UnsafeRawPointer, Selector) -> Int
                let instancePoint = unsafeBitCast(instance, to: UnsafeRawPointer.self)
                let result = unsafeBitCast(selectorImp, to: selectorImpType.self)(instancePoint, selector)
                return result
            }
        }
        return nil
    }
    
    public class func to_i(cls:AnyClass, selector:Selector) -> Int? {
        if cls.responds(to: selector) {
            if let selectorMethod = class_getClassMethod(cls, selector) {
                let selectorImp = method_getImplementation(selectorMethod)
                typealias selectorImpType = @convention(c)(UnsafeRawPointer, Selector) -> Int
                let instancePoint = unsafeBitCast(cls, to: UnsafeRawPointer.self)
                let result = unsafeBitCast(selectorImp, to: selectorImpType.self)(instancePoint, selector)
                return result
            }
        }
        return nil
    }
    
    public class func to_d(instance:AnyObject, selector:Selector) -> Double? {
        if instance.responds(to: selector) {
            if let selectorMethod = class_getInstanceMethod(type(of: instance), selector) {
                let selectorImp = method_getImplementation(selectorMethod)
                typealias selectorImpType = @convention(c)(UnsafeRawPointer, Selector) -> Double
                let instancePoint = unsafeBitCast(instance, to: UnsafeRawPointer.self)
                let result = unsafeBitCast(selectorImp, to: selectorImpType.self)(instancePoint, selector)
                return result
            }
        }
        return nil
    }
    
    public class func to_d(cls:AnyClass, selector:Selector) -> Double? {
        if cls.responds(to: selector) {
            if let selectorMethod = class_getClassMethod(cls, selector) {
                let selectorImp = method_getImplementation(selectorMethod)
                typealias selectorImpType = @convention(c)(UnsafeRawPointer, Selector) -> Double
                let instancePoint = unsafeBitCast(cls, to: UnsafeRawPointer.self)
                let result = unsafeBitCast(selectorImp, to: selectorImpType.self)(instancePoint, selector)
                return result
            }
        }
        return nil
    }
    
    public class func to_date(instance:AnyObject, selector:Selector) -> Date? {
        
        if instance.responds(to: selector) {
            if let selectorMethod = class_getInstanceMethod(type(of: instance), selector) {
                let selectorImp = method_getImplementation(selectorMethod)
                typealias selectorImpType = @convention(c)(UnsafeRawPointer, Selector) -> Date?
                let instancePoint = unsafeBitCast(instance, to: UnsafeRawPointer.self)
                let result = unsafeBitCast(selectorImp, to: selectorImpType.self)(instancePoint, selector)
                return result
            }
        }
        return nil
    }
    
    public class func to_date(cls:AnyClass, selector:Selector) -> Date? {
        if cls.responds(to: selector) {
            if let selectorMethod = class_getClassMethod(cls, selector) {
                let selectorImp = method_getImplementation(selectorMethod)
                typealias selectorImpType = @convention(c)(UnsafeRawPointer, Selector) -> Date?
                let instancePoint = unsafeBitCast(cls, to: UnsafeRawPointer.self)
                let result = unsafeBitCast(selectorImp, to: selectorImpType.self)(instancePoint, selector)
                return result
            }
        }
        return nil
    }
    
    public class func to_obj(instance:AnyObject, selector:Selector) -> AnyObject? {
        
        if instance.responds(to: selector) {
            if let selectorMethod = class_getInstanceMethod(type(of: instance), selector) {
                let selectorImp = method_getImplementation(selectorMethod)
                typealias selectorImpType = @convention(c)(UnsafeRawPointer, Selector) -> AnyObject?
                let instancePoint = unsafeBitCast(instance, to: UnsafeRawPointer.self)
                let result = unsafeBitCast(selectorImp, to: selectorImpType.self)(instancePoint, selector)
                return result
            }
        }
        return nil
    }
    
    public class func to_obj(cls:AnyClass, selector:Selector) -> AnyObject? {
        if cls.responds(to: selector) {
            if let selectorMethod = class_getClassMethod(cls, selector) {
                let selectorImp = method_getImplementation(selectorMethod)
                typealias selectorImpType = @convention(c)(UnsafeRawPointer, Selector) -> AnyObject?
                let instancePoint = unsafeBitCast(cls, to: UnsafeRawPointer.self)
                let result = unsafeBitCast(selectorImp, to: selectorImpType.self)(instancePoint, selector)
                return result
            }
        }
        return nil
    }
}
