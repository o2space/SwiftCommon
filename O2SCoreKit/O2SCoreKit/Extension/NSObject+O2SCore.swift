//
//  NSObject+O2SCore.swift
//  O2SCoreKit
//
//  Created by wkx on 2020/6/22.
//  Copyright © 2020 O2Space. All rights reserved.
//

import Foundation

public extension NSObject {
    
    // MARK: 类名
    
    var o2sc_className : String {
        get {
            let name = NSStringFromClass(type(of: self))
            if name.contains(".") {
                return name.components(separatedBy: ".")[1]
            }else{
                return name
            }
        }
    }
    
    var o2sc_classFullName : String {
        get{
            let name = NSStringFromClass(type(of: self))
            return name
        }
    }
    
    //MARK: 锁
    
    func o2sc_with(mutex:UnsafeMutablePointer<pthread_mutex_t>, f:() -> Void) {
        pthread_mutex_lock(mutex)
        f()
        pthread_mutex_unlock(mutex)
    }
        
    func o2sc_withRead(rwlock:UnsafeMutablePointer<pthread_rwlock_t>, f:() -> Void) {
        pthread_rwlock_rdlock(rwlock)
        f()
        pthread_rwlock_unlock(rwlock)
    }
    func o2sc_withWrite(rwlock:UnsafeMutablePointer<pthread_rwlock_t>, f:() -> Void) {
        pthread_rwlock_wrlock(rwlock)
        f()
        pthread_rwlock_unlock(rwlock)
    }
        
    func o2sc_with(lock:NSLock, f:() -> Void) {
        lock.lock()
        f()
        lock.unlock()
    }
    
    func o2sc_with(spinlock:UnsafeMutablePointer<OSSpinLock>, f:() -> Void) {
        OSSpinLockLock(spinlock)
        f()
        OSSpinLockUnlock(spinlock)
    }
        
    @available(iOS 10, *)
    func o2sc_with(unfairlock:os_unfair_lock_t, f:() -> Void) {
    //        os_unfair_lock_trylock(lock)
        os_unfair_lock_lock(unfairlock)
        f()
        os_unfair_lock_unlock(unfairlock)
    }
        
    func o2sc_with(opQ:OperationQueue, f:@escaping () -> Void) {
        let op = BlockOperation(block: f)
        opQ.addOperation(op)
        op.waitUntilFinished()
    }
    func o2sc_with(queue:DispatchQueue, f:() -> Void) {
        queue.sync {
            f()
        }
    }
        
    func o2sc_withSynchoronized(obj:Any, f:() -> Void) {
        objc_sync_enter(obj)
        defer {
            objc_sync_exit(obj)
        }
        f()
    }
}
