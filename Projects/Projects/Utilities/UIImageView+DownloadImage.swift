//
//  UIImageView+DownloadImage.swift
//  Trophy Hunter
//
//  Created by Dario on 10/14/16.
//  Copyright © 2016 Dario. All rights reserved.
//
import UIKit
import Foundation

extension UIImageView {
    func loadImageWith(url: URL, session: URLSession) -> URLSessionDownloadTask {
        let downloadTask = session.downloadTask(with: url) {
            [weak self] url, response, error in
            if error == nil, url != nil {
                do {
                    let data = try Data(contentsOf: url!)
                    if let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            if let strongSelf = self {
                                strongSelf.image = image
                            }
                        }
                    }
                } catch {
                    logMessage(.Info, "error: \(error.localizedDescription)")
                }
            }
        }
        downloadTask.resume()
        return downloadTask
    }
}
