//
//  ViewController.swift
//  O2SCoreKitTest
//
//  Created by wkx on 2020/6/22.
//  Copyright © 2020 O2Space. All rights reserved.
//

import UIKit
import O2SCoreKit

class ViewController: UIViewController {

    private let base64Mask:Data = {
        let bytes:[UInt8] = [0x01,0x02,0x03,0x04,0x50,0x10,0x20,0x30,0x40,0x50]
        let data = Data(bytes: bytes, count: bytes.count)
        return data
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }


}

