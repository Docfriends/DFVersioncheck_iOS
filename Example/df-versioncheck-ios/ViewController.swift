//
//  ViewController.swift
//  df-versioncheck-ios
//
//  Created by pikachu987 on 01/07/2019.
//  Copyright (c) 2019 pikachu987. All rights reserved.
//

import UIKit
import df_versioncheck_ios

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        AppStore.versionCheck("") { (version) in
            print(version)
        }

        AppStore.versionCheck { (version) in
            print(version)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}


