//
//  Network.swift
//  Trophy Hunter
//
//  Created by Dario on 1/24/18.
//  Copyright © 2018 Dario. All rights reserved.
//

import Foundation
import UIKit

func showAlertError(_ error: NSError, in viewController: UIViewController, completion: (() -> ())? = nil ) {
    let alert = UIAlertController(
        title: NSLocalizedString("Network error", comment: "Localized Network: network error title"),
        message: NSLocalizedString(error.localizedDescription, comment: "Localized Network: network error message"),
        preferredStyle: .alert
    )
    
    let alertButtonTitle = NSLocalizedString("Ok", comment: "Localized Network: network error alert action button title")
    let action = UIAlertAction(title: alertButtonTitle, style: .default, handler: {
        _ in
        completion?()
    })
    alert.addAction(action)
    viewController.present(alert, animated: true, completion: nil)
}
