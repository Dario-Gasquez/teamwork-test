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

        TeamworkMediator.shared.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        refreshProjects()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return projects?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let projectsData = projects, indexPath.row < projectsData.count else { return UITableViewCell() }
        
        //TODO: We could create a custom ProjectInformationCell class that allows as to show additional project information in each table view cell, customizing its UI elements (size, color, layout, etcetera).
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectInformationCell", for: indexPath)
        cell.textLabel?.text = projectsData[indexPath.row].name
        cell.detailTextLabel?.text = projectsData[indexPath.row].company?.name
        
        return cell
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    // MARK: - PRIVATE SECTION -
    
    @IBAction private func refreshProjects() {
        showActivityIndicator()
        TeamworkMediator.shared.retrieveProjects()
    }
    
    private var projects: [Project]? {
        didSet {
            tableView.reloadData()
        }
    }
    
    private var loadIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    
    private func showActivityIndicator() {
        tableView.separatorStyle = .none
        loadIndicator.hidesWhenStopped = true
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
