//
//  ViewController.swift
//  Projects
//
//  Created by Dario on 2/27/18.
//  Copyright © 2018 Dario. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        TeamworkMediator.shared.retrieveProjects()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

