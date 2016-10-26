//
//  PagedTableViewDelegate.swift
//  PagedTableViewController
//
//  Created by Andrew Brown on 10/20/16.
//  Copyright © 2016 Andrew Brown. All rights reserved.
//

import UIKit


// TODO - provide default implementations of many of these methods instead of having such a hefty protocol.
@objc protocol PagedTableViewControllerDelegate {
    // MARK : Page transitions
    @objc optional func pagedTableViewController(_ pagedTableViewController: PagedTableViewController, shouldTransitionWith interactionType: PagedTableViewInteractionType, at indexPath: IndexPath?) -> Bool
    @objc optional func pagedTableViewController(_ pagedTableViewController: PagedTableViewController, scrollPositionForTransitionToPage nextPage: Int, fromPage: Int, withSwipeAt indexPath: IndexPath?) -> IndexPath?
    @objc optional func pagedTableViewController(_ pagedTableViewController: PagedTableViewController, didFinishAnimatingTransition finished: Bool, toPage: Int)
    @objc optional func scrollPosition(forTransitionWith interactionType: PagedTableViewInteractionType, fromIndexPath indexPath: IndexPath?, onPage page: Int) -> IndexPath?
    
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
    // MARK : Allow Registration of tableViewCell reuse identifiers without exposing tableView
    @objc optional func reuseIdentifiersToRegister(forTableViewOnPage page: Int) -> [String: String]
    
    // MARK : Methods which allow further customization.
    @objc optional func tableViewDataSource(forPage page: Int) -> UITableViewDataSource?
    @objc optional func tableViewDelegate(forPage page: Int) -> UITableViewDelegate?
    
    
    
}
