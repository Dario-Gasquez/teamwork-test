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

        TeamworkMediator.shared.delegate = self
        TeamworkMediator.shared.retrieveProjects()
    }
}


extension ViewController: TeamworkMediatorDelegate {
    func errorReceived(_ error: NSError) {
        logMessage(.Info, error.debugDescription)
    }

    func projectsDataReceived(projects: [Project]) {
        logMessage(.Info, projects.debugDescription)
    }
}
