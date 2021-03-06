//
//  PagedTableViewDelegate.swift
//  PagedTableViewController
//
//  Created by Andrew Brown on 10/20/16.
//  Copyright © 2016 Andrew Brown. All rights reserved.
//

import UIKit

// Note - consider refactoring so that user just supplies the corresponding UIPageViewController and UITableView dataSources and delegates.
@objc protocol PagedTableViewControllerDelegate {
    
    // MARK : Page transitions
    @objc optional func pagedTableViewController(_ pagedTableViewController: PagedTableViewController, scrollPositionForTransitionToPage nextPage: Int, fromPage: Int, withSwipeAt indexPath: IndexPath?) -> IndexPath?
    @objc optional func pagedTableViewController(_ pagedTableViewController: PagedTableViewController, didFinishAnimatingTransition finished: Bool, toPage: Int, fromPage: Int, transitionCompleted completed: Bool)
    @objc optional func pagedTableViewController(_ pagedTableViewController: PagedTableViewController, willTransition toPage: Int, fromPage: Int)
    
    // MARK : TableViewDelegate methods
    @objc optional func pagedTableViewController(_ pagedTableViewController: PagedTableViewController, willSelectRowAt indexPath: IndexPath, onPage page: Int) -> IndexPath?
    @objc optional func pagedTableViewController(_ pagedTableViewController: PagedTableViewController, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath, onPage page: Int)
    @objc optional func pagedTableViewController(_ pagedTableViewController: PagedTableViewController, didSelectRowAt indexPath: IndexPath, onPage page: Int)
    @objc optional func pagedTableViewController(_ pagedTableViewController: PagedTableViewController, willDeselectRowAt indexPath: IndexPath, onPage page: Int) -> IndexPath?
    @objc optional func pagedTableViewController(_ pagedTableViewController: PagedTableViewController, didDeselectRowAt indexPath: IndexPath, onPage page: Int)
    @objc optional func pagedTableViewController(_ pagedTableViewController: PagedTableViewController, shouldHighlightRowAt indexPath: IndexPath, onPage page: Int) -> Bool
    @objc optional func pagedTableViewController(_ pagedTableViewController: PagedTableViewController, didHighlightRowAt indexPath: IndexPath, onPage page: Int)
    @objc optional func pagedTableViewController(_ pagedTableViewController: PagedTableViewController, didUnhighlightRowAt indexPath: IndexPath, onPage page: Int)
    @objc optional func pagedTableViewController(_ pagedTableViewController: PagedTableViewController, heightForRowAt indexPath: IndexPath, onPage page: Int) -> CGFloat
    @objc optional func pagedTableViewController(_ pagedTableViewController: PagedTableViewController, titleForHeaderIn section: Int, onPage page: Int) -> String?
    
    // MARK : Allow Registration of tableViewCell reuse identifiers without exposing tableView
    @objc optional func reuseIdentifiersToRegister(forTableViewOnPage page: Int) -> [String: String]
    @objc optional func pagedTableViewController(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath )
    
    // MARK : Methods which allow further customization.
    @objc optional func tableViewDataSource(forPage page: Int) -> UITableViewDataSource?
    @objc optional func tableViewDelegate(forPage page: Int) -> UITableViewDelegate?
}
