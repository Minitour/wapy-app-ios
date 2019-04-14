//
//  AZRemoteTableDelegate.swift
//  AZAutoTableView
//
//  Created by Antonio Zaitoun on 26/06/2018.
//  Copyright © 2018 Antonio Zaitoun. All rights reserved.
//

import UIKit

open class AZRemoteTableDelegate: NSObject, UITableViewDelegate {


    /// A weak reference to the table view. Used to notify self when the refresh control is activated.
    open weak var tableView: UITableView?

    /// The current page that we are fetching.
    fileprivate(set) open var currentPage: Int = 0

    /// A flag indicating if the delegate is in a middle of a fetch.
    fileprivate(set) open var awaitingEvent: Bool = false

    /// A flag that indicates if there is more data to load.
    fileprivate(set) open var loadMore: Bool = true

    /// A flag that indicates if we loaded the first time.
    open var didInitialLoad: Bool{
        return currentPage != 0
    }

    open func reset() {
        currentPage = 0
        loadMore = true
    }

    /// Called only before initial load and if there was an error after the initial load.
    ///
    /// - Parameters:
    ///   - tableView: The table view.
    ///   - view: The view to displayl.
    open func tableView(_ tableView: UITableView, layoutView view: UIView) {
        tableView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.centerXAnchor.constraint(equalTo: tableView.centerXAnchor).isActive = true
        view.centerYAnchor.constraint(equalTo: tableView.centerYAnchor).isActive = true
    }

    /// A helper function used to attach the refresh control.
    ///
    /// - Parameters:
    ///   - tableView: The table view.
    ///   - refreshControl: The refresh control.
    public final func tableView(_ tableView: UITableView, setupRefreshControl refreshControl: UIRefreshControl){
        refreshControl.addTarget(self, action: #selector(didPullToRefresh(_:)), for: .valueChanged)
    }

    /// Gets called when tableview gets refreshed by the user.
    ///
    /// - Parameters:
    ///   - tableView: The table view
    ///   - control: The refresh control
    open func tableView(_ tableView: UITableView, didRefreshWithControl control: UIRefreshControl){}


    /// Function to override, gets called when the table needs to load more data.
    ///
    /// - Parameters:
    ///   - tableView: The table view.
    ///   - didRequestPage: The page being requested.
    open func tableView(_ tableView: UITableView, didRequestPage page: Int,usingRefreshControl: Bool = false){}


    /// Called before displaying a certain cell on the table. Overrided in order to detect when reaching the bottom.
    ///
    /// - Parameters:
    ///   - tableView:
    ///   - cell:
    ///   - indexPath:
    open func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        //get last element index
        let lastElement = tableView.remote.dataSource?.numberOfRowsInSection(tableView, section: indexPath.section) ?? 1

        // if last element is the current index
        if loadMore, indexPath.row == lastElement {

            //if not awaiting event
            if !awaitingEvent {
                awaitingEvent = true
                self.tableView(tableView, didRequestPage: currentPage)
            }
        }
    }


    /// Function called when tableview needs to reload data. Override to add your own custom functionality.
    ///
    /// - Parameter tableView: the table view that needs to has it's data reloaded.
    open func onReloadData(_ tableView: UITableView) {
        tableView.reloadData()
    }


    /// Notify delegate that the event has passed. Never call this function directly.
    /// This will get called only from the remote wrapper.
    open func notify(success: Bool){

        awaitingEvent = false

        if success {
            currentPage += 1
        }
    }

    @objc fileprivate func didPullToRefresh(_ target: UIRefreshControl) {
        if let tableView = tableView {

            //notify delegate method
            self.tableView(tableView, didRefreshWithControl: target)

            //reset current page
            currentPage = 0

            //call did request page 0
            self.tableView(tableView, didRequestPage: 0,usingRefreshControl: true)
        }
    }
}
