//
//  TeamworkMediator.swift
//  Projects
//
//  Created by Dario on 2/27/18.
//  Copyright © 2018 Dario. All rights reserved.
//

import Foundation

protocol TeamworkMediatorDelegate: class {
    func projectsDataReceived(projects: [Project])
    func errorReceived(_ error: NSError)
}

struct TeamworkConstants {
    static let apiKey = "twp_IevR8gn9v7YPtoR9pvSMawLJjyHX"
    static let projectsURL = "https://pablinludico.teamwork.com/projects.json"
    
}

/// This singleton class is the middle man between an application and  Teamwork's API. The main functionality it should provides is:
/// - get user proyects
/// - get list of tasks per project
/// - add new tasks
final class TeamworkMediator {
    
    //MARK: - PUBLIC SECTION -
    static let shared = TeamworkMediator()
    weak var delegate: TeamworkMediatorDelegate?
    
    func retrieveProjects() {
        logMessage(.Info, "-----------------")
        httpGetRequest(urlString: TeamworkConstants.projectsURL) { (error, response, json) in
            if let nsError = error as NSError? {
                DispatchQueue.main.async {
                    self.delegate?.errorReceived(nsError)
                }
                return
            }
            
            guard let httpResponse = response, let jsonDictionary = json else { return }
            
            //TODO: add error status code handling: 500, 4xx, etc.
            if httpResponse.statusCode == 200 {
                //Return the list of projects to the delegate
                guard let projects = Project.retrieveProjects(from: jsonDictionary) else { return }

                DispatchQueue.main.async {
                    self.delegate?.projectsDataReceived(projects: projects)
                }
            }
        }
    }
    
    
    //MARK: - PRIVATE SECTION -
    
    typealias JSONDictionary = [String: AnyObject]
    private func httpGetRequest(urlString: String, completionHandler: @escaping (Error?, HTTPURLResponse?, JSONDictionary?)->Void) {
        logMessage(.Info, "////////////////////////////////////")
        
        guard let url = URL(string: urlString), let base64APIKey = TeamworkConstants.apiKey.data(using: .utf8)?.base64EncodedString() else  { return }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("Basic \(base64APIKey)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: urlRequest) {
            data, response, error in
            guard error == nil  else {
                logMessage(.Info, "error: \(String(describing: error)) !!!!!!!!!!")
                completionHandler(error, nil, nil)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.mimeType == "application/json", let jsonData = data {
                logMessage(.Info, " http response status code: \(httpResponse.statusCode)")
                logMessage(.Info, " http response mime type: \(String(describing: httpResponse.mimeType))")
                
                if let jsonDictionary = self.parseJSONFrom(data: jsonData) {
                    completionHandler(nil, httpResponse, jsonDictionary)
                } else {
                    //TODO: Could not parse JSON Dictionary from answer, what to do?
                }
            }
        }
        
        task.resume()
    }
    
    private func parseJSONFrom(data: Data) -> [String: AnyObject]? {
        do {
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject]
        } catch  {
            logMessage(.Info, "parse json error: \(error.localizedDescription)")
            return nil
        }
    }
    
}
