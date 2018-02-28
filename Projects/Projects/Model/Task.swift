//
//  Task.swift
//  Projects
//
//  Created by Dario on 2/28/18.
//  Copyright © 2018 Dario. All rights reserved.
//

import Foundation

/*
 TASKS IN A TASKLIST REQUEST:
 https://pablinludico.teamwork.com/tasklists/1547974/tasks.json
 
 SAMPLE RESPONSE JSON:
 {
    STATUS: "OK",
    todo - items: [
        {
            id: 16783279,
            canComplete: true,
            comments - count: 0,
            description: "",
            has - reminders: false,
            has - unread - comments: false,
            private: 0,
            content: "first task for 2nd",
            order: 2000,
            project - id: 292215,
            project - name: "2nd Project",
            todo - list - id: 1547974,
            todo - list - name: "General tasks",
            tasklist - private: false,
            tasklist - isTemplate: false,
            status: "new",
            company - name: "PablinLudico",
            company - id: 99591,
            creator - id: 318412,
            creator - firstname: "Pablin",
            creator - lastname: "Ludico",
            completed: false,
            start - date: "",
            due - date - base: "",
            due - date: "",
            created - on: "2018-02-27T12:41:00Z",
            last - changed - on: "2018-02-27T12:41:43Z",
            position: 2000,
            estimated - minutes: 0,
            priority: "",
            progress: 0,
            harvest - enabled: false,
            parentTaskId: "",
            lockdownId: "",
            tasklist - lockdownId: "",
            has - dependencies: 0,
            has - predecessors: 0,
            hasTickets: false,
            timeIsLogged: "0",
            attachments - count: 0,
            predecessors: [],
            canEdit: true,
            viewEstimatedTime: true,
            creator - avatar - url: "https://s3.amazonaws.com/TWFiles/463631/userAvatar/twia_40fa36c22f0c8e22e082b45f66412964.png",
            canLogTime: true,
            userFollowingComments: false,
            userFollowingChanges: false,
            DLM: 0
},
        {
            id: 16792013,
            canComplete: true,
            comments - count: 0,
            description: "2nd task description",
            has - reminders: false,
            has - unread - comments: false,
            private: 0,
            content: "2nd general task",
            order: 2001,
            project - id: 292215,
            project - name: "2nd Project",
            todo - list - id: 1547974,
            todo - list - name: "General tasks",
            tasklist - private: false,
            tasklist - isTemplate: false,
            status: "new",
            company - name: "PablinLudico",
            company - id: 99591,
            creator - id: 318412,
            creator - firstname: "Pablin",
            creator - lastname: "Ludico",
            completed: false,
            start - date: "",
            due - date - base: "",
            due - date: "",
            created - on: "2018-02-27T23:01:00Z",
            last - changed - on: "2018-02-27T23:01:23Z",
            position: 2001,
            estimated - minutes: 0,
            priority: "",
            progress: 0,
            harvest - enabled: false,
            parentTaskId: "",
            lockdownId: "",
            tasklist - lockdownId: "",
            has - dependencies: 0,
            has - predecessors: 0,
            hasTickets: false,
            timeIsLogged: "0",
            attachments - count: 0,
            responsible - party - ids: "318412",
            responsible - party - id: "318412",
            responsible - party - names: "Pablin L.",
            responsible - party - type: "Person",
            responsible - party - firstname: "Pablin",
            responsible - party - lastname: "Ludico",
            responsible - party - summary: "Pablin L.",
            predecessors: [],
            canEdit: true,
            viewEstimatedTime: true,
            creator - avatar - url: "https://s3.amazonaws.com/TWFiles/463631/userAvatar/twia_40fa36c22f0c8e22e082b45f66412964.png",
            canLogTime: true,
            userFollowingComments: false,
            userFollowingChanges: false,
            DLM: 0
}
]
}

 */

struct Task {
    let content: String?
    let description: String?
    
    init(from json: [String: AnyObject]) {
        content     = json["content"] as? String
        description = json["description"] as? String
    }
    
    
    static func retrieveTasks(from json: [String: AnyObject]) -> [Task] {
        var tasks = [Task]()
        if let tasksArray = json["todo-items"] as? [AnyObject] {
            for task in tasksArray {
                if let taskDict = task as? [String: AnyObject] {
                    tasks.append(Task(from: taskDict))
                }
            }
        }
        
        return tasks
    }
}



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
