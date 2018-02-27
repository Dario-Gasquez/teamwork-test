//
//  ProjectsData.swift
//  Projects
//
//  Created by Dario on 2/27/18.
//  Copyright © 2018 Dario. All rights reserved.
//

import Foundation

/*
 SAMPLE 01 PROJECT JSON:
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
        name: "",
        id: "",
        color: ""
    },
    filesAutoNewVersion: false,
    overview - start - page: "default",
    tags: [],
    logo: "",
    startDate: "",
    id: "292215",
    last - changed - on: "2018-02-27T12:41:43Z",
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
}
*/


/// Stores a Project
struct Project {
    let name: String?
    let description: String?
    let company: Company?
    
    static func retrieveProjects(from json: [String: AnyObject]) -> [Project]? {
        
        guard let projectsArray = json["projects"] as? [AnyObject] else { return nil } //TODO: we might want to do somenthing else rather than return nil ?
        
        var projects = [Project]()
        for project in projectsArray {
            if let projectDict = project as? [String: AnyObject] {
                projects.append(Project(from: projectDict))
            }
        }

        return projects
    }
    
    //TODO: Swift 4 provides cleaner ways to parse JSON using Codable. More info: https://benscheirman.com/2017/06/swift-json/
    init(from json: [String: AnyObject]) {
        name = json["name"] as? String
        description = json["description"] as? String
        company = Company(from: json)
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
            let isOwnerString = jsonData["is - owner"] as? String,
            let id = jsonData["id"] as? String else {
                return nil
                
        }

        self.name = name
        self.id = id
        self.isOwner = (isOwnerString == "1" ? true : false)
    }
}
