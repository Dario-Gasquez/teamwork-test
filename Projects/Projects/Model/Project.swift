//
//  ProjectsData.swift
//  Projects
//
//  Created by Dario on 2/27/18.
//  Copyright © 2018 Dario. All rights reserved.
//

import Foundation

/*
 REQUEST:
 https://pablinludico.teamwork.com/projects.json
 
 RESPONSE JSON:
{
    STATUS: "OK",
    projects: [
        {
            replyByEmailEnabled: true,
            starred: false,
            show - announcement: false,
            harvest - timers - enabled: false,
            status: "active",
            subStatus: "current",
            defaultPrivacy: "open",
            integrations: {
                microsoftConnectors: {
                    enabled: false
                },
                onedrivebusiness: {
                    enabled: false,
                    folder: "root",
                    account: "",
                    foldername: "root"
                }
            },
            created - on: "2018-02-27T12:41:34Z",
            category: {
                name: "mobile",
                id: "17400",
                color: ""
            },
            filesAutoNewVersion: false,
            overview - start - page: "default",
            tags: [],
            logo: "https://s3.amazonaws.com/TWFiles/463631/projectLogo/tf_B1812D60-E9E0-8073-2CEA279679E5D275.FiatPalioAdventure18.jpg",
            startDate: "",
            id: "292215",
            last - changed - on: "2018-02-27T23:04:24Z",
            endDate: "",
            defaults: {
                privacy: ""
            },
            company: {
                name: "PablinLudico",
                is - owner: "1",
                id: "99591"
            },
            tasks - start - page: "default",
            name: "2nd Project",
            privacyEnabled: false,
            description: "",
            announcement: "",
            isProjectAdmin: true,
            start - page: "projectoverview",
            notifyeveryone: false,
            boardData: {},
            announcementHTML: ""
},
        {
            replyByEmailEnabled: true,
            starred: false,
            show - announcement: false,
            harvest - timers - enabled: false,
            status: "active",
            subStatus: "current",
            defaultPrivacy: "open",
            integrations: {
                microsoftConnectors: {
                    enabled: false
                },
                onedrivebusiness: {
                    enabled: false,
                    folder: "root",
                    account: "",
                    foldername: "root"
                }
            },
            created - on: "2018-02-27T12:41:06Z",
            category: {
                name: "",
                id: "",
                color: ""
            },
            filesAutoNewVersion: false,
            overview - start - page: "default",
            tags: [],
            logo: "",
            startDate: "",
            id: "292213",
            last - changed - on: "2018-02-27T12:41:19Z",
            endDate: "",
            defaults: {
                privacy: ""
            },
            company: {
                name: "PablinLudico",
                is - owner: "1",
                id: "99591"
            },
            tasks - start - page: "default",
            name: "MFP",
            privacyEnabled: false,
            description: "",
            announcement: "",
            isProjectAdmin: true,
            start - page: "projectoverview",
            notifyeveryone: false,
            boardData: {},
            announcementHTML: ""
}
]
}
*/


/// Contains a Teamwork Project information
class Project {
    var name: String?
    var description: String?
    var company: Company?
    var id: String?
    var categoryName: String?
    var taskLists: [TaskList]?
    var projectLogoURL: String? //example: "https://s3.amazonaws.com/TWFiles/463631/projectLogo/tf_B1812D60-E9E0-8073-2CEA279679E5D275.FiatPalioAdventure18.jpg"
    
    /// This variable counts how many request have been made to retrieve tasks in a tasklist. It's incremented every time a new request is generated and decremented every time a request completes, once it reaches 0 it should inform the delegate that all the tasks have been retrieved.
    var tasklistRequestCounter = 0 //TODO: we probably can devise a more elegant solution
    
    static func retrieveProjects(from json: [String: AnyObject]) -> [Project]? {
        guard let projectsArray = json["projects"] as? [AnyObject] else { return nil } //TODO: we might want to do somenthing else rather than return nil ?
        
        var projects = [Project]()
        for projectData in projectsArray {
            if let projectJson = projectData as? [String: AnyObject] {
                projects.append(Project(from: projectJson))
            }
        }

        return projects
    }
    
    //TODO: Swift 4 provides cleaner ways to parse JSON using Codable. More info: https://benscheirman.com/2017/06/swift-json/
    init(from json: [String: AnyObject]) {
        name = json["name"] as? String
        description = json["description"] as? String
        
        if let companyInfo = json["company"] as? [String: AnyObject] {
            company = Company(from: companyInfo)
        }
        if let categoryInfo = json["category"] as? [String: AnyObject] {
            categoryName = categoryInfo["name"] as? String
        }
        id = json["id"] as? String
        projectLogoURL = json["logo"] as? String
    }
}


/*
SAMPLE JSON
company: {
    name: "PablinLudico",
    is - owner: "1",
    id: "99591"
}
*/
struct Company {
    let name: String
    let isOwner: Bool
    let id: String
    
    init?(from jsonData: [String: AnyObject]) {
        guard let name = jsonData["name"] as? String,
            let isOwnerString = jsonData["is-owner"] as? String,
            let id = jsonData["id"] as? String else {
                return nil
                
        }

        self.name = name
        self.id = id
        self.isOwner = (isOwnerString == "1" ? true : false)
    }
}
