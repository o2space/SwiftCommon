//
//  DispatchQueue+O2SCore.swift
//  O2SCoreKit
//
//  Created by wkx on 2020/6/22.
//  Copyright © 2020 O2Space. All rights reserved.
//

import Foundation

public extension DispatchQueue {
    
    //MARK: exce task in main queue
    private static var o2sc_token : DispatchSpecificKey<()> = {
        // 初始化一个 key
        let key = DispatchSpecificKey<()>()
        DispatchQueue.main.setSpecific(key: key, value: ())
        return key
    }()
    
    static var o2sc_isMainQueue: Bool {
        // 通过队列上是否有绑定 token 对应的值来判断是否为主队列
        return DispatchQueue.getSpecific(key: o2sc_token) != nil
    }
    
    static func o2sc_main_async_safe(_ f:@escaping () -> Void) {
        if DispatchQueue.o2sc_isMainQueue  {
            f()
        } else {
            DispatchQueue.main.async {
                f()
            }
        }
    }
    
    //MARK: dispatch_once
    private static var _o2sc_onceTracker = [String]()
    static func o2sc_once(file: String = #file, function: String = #function, line: Int = #line, f:()->Void) {
        let token = file + ":" + function + ":" + String(line)
        o2sc_once(token: token, f: f)
    }
       
    static func o2sc_once(token: String, f:()->Void) {
        objc_sync_enter(self)
        defer {
            objc_sync_exit(self)
        }
        if _o2sc_onceTracker.contains(token) {
            return
        }
        _o2sc_onceTracker.append(token)
        f()
    }
    
    //MARK: delay
    typealias O2SCDelayTask = (_ cancel : Bool) -> Void
    
    @discardableResult
    static func o2sc_delay(time: TimeInterval, task: @escaping ()-> ()) -> O2SCDelayTask? {
        func dispatch_later(block : @escaping () -> ()) {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + time , execute: block)
        }
        
        var closure : (() -> ())? = task
        var result : O2SCDelayTask?
        let delayedClosure : O2SCDelayTask = { cancel in
            if let internalClosure = closure {
                if cancel == false {
                    DispatchQueue.main.async(execute: internalClosure)
                }
            }
            closure = nil
            result = nil
        }
        
        result = delayedClosure
        dispatch_later { () -> () in
            if let delayedClosure = result {
                delayedClosure(false)
            }
         }
         return result
    }
    
    static func o2sc_delayCancel(task: O2SCDelayTask?) {
        task?(true)
    }
}
