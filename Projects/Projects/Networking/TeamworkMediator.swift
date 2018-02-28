//
//  TeamworkMediator.swift
//  Projects
//
//  Created by Dario on 2/27/18.
//  Copyright © 2018 Dario. All rights reserved.
//

import Foundation

protocol TeamworkMediatorDelegate: class {
    func errorReceived(_ error: NSError)
    func projectsDataReceived(projects: [Project])
    func projectTasklistsReceived()
    func tasksForAllTasklistReceived()
}

// an extension that provides dummy defaults implementations to make the methods in the protocol optional to classes conforming to PSNMediatorDelegate
extension TeamworkMediatorDelegate {
    func errorReceived(_ error: NSError) {}
    func projectsDataReceived(projects: [Project]) {}
    func projectTasklistsReceived() {}
    func tasksForAllTasklistReceived() {}
}

struct TeamworkConstants {
    //static let apiKey = "twp_TEbBXGCnvl2HfvXWfkLUlzx92e3T" // Cat (yat@triplespin.com)
    static let apiKey = "twp_IevR8gn9v7YPtoR9pvSMawLJjyHX" //pablin.ludico@gmail.com

    //static let projectsURL = "https://yat.teamwork.com/projects.json"
    static let projectsURL = "https://pablinludico.teamwork.com/projects.json"
    
    //static let tasklistsURL = "https://yat.teamwork.com/projects/{projectid}/tasklists.json"
    static let tasklistsURL = "https://pablinludico.teamwork.com/projects/{projectid}/tasklists.json"
    
    //static let tasksInTasklistURL = "https://yat.teamwork.com/tasklists/{tasklistid}/tasks.json"
    static let tasksInTasklistURL = "https://pablinludico.teamwork.com/tasklists/{tasklistid}/tasks.json"
}

/// This singleton class is the middle man between an application and Teamwork's API. The main functionality it provides is:
/// - get user proyects
/// - get list of tasklists and task per project
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
    
    
    func retrieveTasklists(for project: Project) {
        guard let projectID = project.id else { return }
        
        logMessage(.Info, "-------------------------")
        let urlStringWithProjectID = TeamworkConstants.tasklistsURL.replacingOccurrences(of: "{projectid}", with: projectID)
        
        httpGetRequest(urlString: urlStringWithProjectID) { (error, response, json) in
            if let nsError = error as NSError? {
                DispatchQueue.main.async {
                    self.delegate?.errorReceived(nsError)
                }
                return
            }
            
            guard let httpResponse = response, let jsonDictionary = json else { return }

            //TODO: add error status code handling: 500, 4xx, etc.
            if httpResponse.statusCode == 200 {
                project.taskLists = TaskList.retrieveTasklists(from: jsonDictionary)
                DispatchQueue.main.async {
                    self.delegate?.projectTasklistsReceived()
                }
            }
        }
    }
    
    
    func retrieveTasksForTasklists(in project: Project) {
        guard let tasklists = project.taskLists else { return }
        
        project.tasklistRequestCounter = 0
        for tasklist in tasklists {
            project.tasklistRequestCounter += 1
            retrieveTasks(for: tasklist, in: project)
        }
    }
    
    
    //MARK: - PRIVATE SECTION -
    private func retrieveTasks(for tasklist: TaskList, in project: Project) {
        guard let tasklistid = tasklist.id else { return }
        
        logMessage(.Info, "~~~~~~~~~~~~~")
        let urlStringWithTasklistID = TeamworkConstants.tasksInTasklistURL.replacingOccurrences(of: "{tasklistid}", with: tasklistid)
        
        httpGetRequest(urlString: urlStringWithTasklistID) { (error, response, json) in
            if let nsError = error as NSError? {
                DispatchQueue.main.async {
                    self.delegate?.errorReceived(nsError)
                }
                return
            }

            guard let httpResponse = response, let jsonDict = json else { return }

            //TODO: add error status code handling: 500, 4xx, etc.
            if httpResponse.statusCode == 200 {
                tasklist.tasks = Task.retrieveTasks(from: jsonDict)
                project.tasklistRequestCounter -= 1
                if project.tasklistRequestCounter == 0 {
                    // the request counter reached 0 means no more requests are pending. Let the delegate know that all tasks where received.
                    DispatchQueue.main.async {
                        self.delegate?.tasksForAllTasklistReceived()
                    }
                }
            }
        }
    }
    
    
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
