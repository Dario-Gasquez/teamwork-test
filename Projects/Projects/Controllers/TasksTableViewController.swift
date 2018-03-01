//
//  TasksTableViewController.swift
//  Projects
//
//  Created by Dario on 2/27/18.
//  Copyright © 2018 Dario. All rights reserved.
//

import UIKit

class TasksTableViewController: UITableViewController {

    var project: Project? {
        didSet {
            updateHeader()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(loadIndicator)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let projectInfo = project else { return }
        updateHeader()
        TeamworkMediator.shared.delegate = self
        showActivityIndicator()
        TeamworkMediator.shared.retrieveTasklists(for: projectInfo)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        downloadTask?.cancel()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // If we are loading the tasks we do not want the empty rows to show (return 0)
        let sectionsCount = loadIndicator.isHidden ? (project?.taskLists?.count ?? 1) : 0
        return sectionsCount
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let tasklistsCount = project?.taskLists?.count,
            section < tasklistsCount else { return 0 }
        
        return project?.taskLists?[section].tasks?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {        
        return project?.taskLists?[section].name
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
    
    
    //MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let headerView = view as? UITableViewHeaderFooterView else { return }
        
        headerView.textLabel?.textColor             = UIColor.white
        headerView.backgroundView?.backgroundColor  = UIColor(red: 20/255, green: 120/255, blue: 220/255, alpha: 1.0)
    }

    
    //MARK: - PRIVATE SECTION -
    private struct StoryBoard {
        static let taskCellIdentifier = "TaskViewCell"
    }
    
    @IBOutlet private weak var projectName: UILabel!
    @IBOutlet private weak var companyName: UILabel!
    @IBOutlet private weak var projectCategory: UILabel!
    @IBOutlet private weak var projectLogo: UIImageView!
    
    private var loadIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    private var downloadTask: URLSessionDownloadTask?
    
    private func updateHeader() {
        guard let projectInfo = project else { return }
        
        projectName?.text       = projectInfo.name
        companyName?.text       = projectInfo.company?.name
        let categoryName = (projectInfo.categoryName != nil && !projectInfo.categoryName!.isEmpty) ? projectInfo.categoryName! : "<none>"
        projectCategory?.text   = "Category: \(categoryName)"
        if let projectLogoURLString = projectInfo.projectLogoURL,
            let imageURL = URL(string: projectLogoURLString) {
            downloadTask = projectLogo?.loadImageWith(url: imageURL, session: URLSession.shared)
        }
    }
    

    private func showActivityIndicator() {
        loadIndicator.hidesWhenStopped = true
        loadIndicator.frame             = self.view.frame
        loadIndicator.color             = UIColor.lightGray
        loadIndicator.backgroundColor   = UIColor(red: 17/255, green: 41/255, blue: 58/255, alpha: 1.0)
        loadIndicator.startAnimating()
    }
    
    
    private func hideActivityIndicator() {
        if loadIndicator.isAnimating { loadIndicator.stopAnimating() }
    }
}


extension TasksTableViewController: TeamworkMediatorDelegate {
    func projectTasklistsReceived() {
        guard let projectInfo = project else { return }

        TeamworkMediator.shared.retrieveTasksForTasklists(in: projectInfo)
    }
    
    
    func tasksForAllTasklistReceived() {
        hideActivityIndicator()
        tableView.reloadData()
    }
}
