//
//  ProjectsTableViewController.swift
//  Projects
//
//  Created by Dario on 2/27/18.
//  Copyright © 2018 Dario. All rights reserved.
//

import UIKit

class ProjectsTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(loadIndicator)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        TeamworkMediator.shared.delegate = self
        
        if isFirstTimeShowing {
            isFirstTimeShowing = false
            refreshProjects()
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return loadIndicator.isHidden ? 1 : 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return projects?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let projectsData = projects, indexPath.row < projectsData.count else { return UITableViewCell() }
        
        //TODO: Create a custom ProjectInformationCell class that allows as to show additional project information in each cell, customizing its UI elements (size, color, layout, etcetera).
        let cell = tableView.dequeueReusableCell(withIdentifier: StoryBoard.projectInformationCellIdentifier, for: indexPath)
        cell.textLabel?.text = projectsData[indexPath.row].name
        cell.detailTextLabel?.text = projectsData[indexPath.row].company?.name
        
        return cell
    }


    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let segueID = segue.identifier, let selectedRow = tableView.indexPathForSelectedRow?.row else { return }
        
        switch segueID {
        case StoryBoard.showProjectTasksSegueIdentifier:
            if let tasksVC = segue.destination as? TasksTableViewController {
                tasksVC.project = projects?[selectedRow]
            }
        default:
            break
        }
    }

    
    
    // MARK: - PRIVATE SECTION -
    private struct StoryBoard {
        static let showProjectTasksSegueIdentifier = "ShowProjectTasks"
        static let projectInformationCellIdentifier = "ProjectInformationCell"
    }
    
    @IBAction private func refreshProjects() {
        showActivityIndicator()
        TeamworkMediator.shared.retrieveProjects()
    }
    
    private var projects: [Project]? {
        didSet {
            tableView.reloadData()
        }
    }
    
    /// if this is the first time the screen is shown then retrieve the projects, otherwise only do it when the user pulls to refresh
    private var isFirstTimeShowing = true
    
    private var loadIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    
    private func showActivityIndicator() {
        tableView.separatorStyle = .none
        loadIndicator.hidesWhenStopped  = true
        loadIndicator.frame             = self.view.frame
        loadIndicator.color             = UIColor.lightGray
        loadIndicator.startAnimating()
    }
    
    private func hideActivityIndicator() {
        if loadIndicator.isAnimating { loadIndicator.stopAnimating() }
        self.tableView.separatorStyle = .singleLine
    }

}

extension ProjectsTableViewController: TeamworkMediatorDelegate {
    func errorReceived(_ error: NSError) {
        logMessage(.Info, error.debugDescription)
        showAlertError(error, in: self, completion: { [weak self] in
            guard let this = self else { return }
            this.hideActivityIndicator()
            this.refreshControl?.endRefreshing()
        })
    }
    
    func projectsDataReceived(projects: [Project]) {
        logMessage(.Info, projects.debugDescription)
        hideActivityIndicator()
        refreshControl?.endRefreshing()
        self.projects = projects
    }
}
