//
//  TaskList.swift
//  Projects
//
//  Created by Dario on 2/28/18.
//  Copyright © 2018 Dario. All rights reserved.
//

import Foundation

/*
 TASKLISTS REQUEST:
 https://pablinludico.teamwork.com/projects/{project_id}/tasklists.json
 
 SAMPLE RESPONSE JSON:
tasklists: [
    {
        name: "General tasks",
        pinned: false,
        milestone - id: "",
        description: "",
        uncompleted - count: 2,
        id: "1547974",
        complete: false,
        private: false,
        isTemplate: false,
        position: 4000,
        status: "new",
        projectId: "292215",
        projectName: "2nd Project",
        DLM: null
},
    {
        name: "silly task list",
        pinned: false,
        milestone - id: "",
        description: "",
        uncompleted - count: 2,
        id: "1548890",
        complete: false,
        private: false,
        isTemplate: false,
        position: 4001,
        status: "new",
        projectId: "292215",
        projectName: "2nd Project",
        DLM: null
}
]

 */

class TaskList {
    let name: String?
    let description: String?
    let id: String?
    var tasks: [Task]?
    
    static func retrieveTasklists(from json: [String: AnyObject]) -> [TaskList] {
        var tasklists = [TaskList]()
        guard let tasklistArray = json["tasklists"] as? [AnyObject] else { return tasklists }
        
        for tasklist in tasklistArray {
            if let tasklistDict = tasklist as? [String: AnyObject] {
                tasklists.append(TaskList(from: tasklistDict))
            }
        }
        
        return tasklists
    }
    
    init(from json: [String: AnyObject]) {
        name        = json["name"] as? String
        description = json["description"] as? String
        id          = json["id"] as? String
    }
}

