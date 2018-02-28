//
//  TasksTableViewController.swift
//  Projects
//
//  Created by Dario on 2/27/18.
//  Copyright © 2018 Dario. All rights reserved.
//

import UIKit

class TasksTableViewController: UITableViewController {

    var project: Project?

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateHeader()
        guard let projectInfo = project else { return }
        
        TeamworkMediator.shared.delegate = self
        TeamworkMediator.shared.retrieveTasklists(for: projectInfo)
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return project?.taskLists?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let tasklistsCount = project?.taskLists?.count,
            section < tasklistsCount else { return 0 }
        
        return project?.taskLists?[section].tasks?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let title = project?.taskLists?[section].name else { return "tasklist title not available" }
        
        return title
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: StoryBoard.taskCellIdentifier, for: indexPath)

        let tasks = project?.taskLists?[indexPath.section].tasks
        if let task = tasks?[indexPath.row] {
            cell.textLabel?.text = task.content
            cell.detailTextLabel?.text = task.description
        }
        
        return cell
    }

    
    //MARK: - PRIVATE SECTION -
    private struct StoryBoard {
        static let taskCellIdentifier = "TaskViewCell"
    }

    
    private func updateHeader() {
        if let projectInfo = project {
            //TODO: update header UI
        }
    }
    
}


extension TasksTableViewController: TeamworkMediatorDelegate {
    func projectTasklistsReceived() {
        guard let projectInfo = project else { return }

        //request the tasks for each tasklist
        TeamworkMediator.shared.retrieveTasksForTasklists(in: projectInfo)
    }
    
    func tasksForAllTasklistReceived() {
        tableView.reloadData()
    }
}
