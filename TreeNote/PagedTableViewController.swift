//
//  PagedTableView.swift
//  PagedTableView
//
//  Created by Andrew Brown on 10/20/16.
//  Copyright © 2016 Andrew Brown. All rights reserved.
//

import UIKit
import Down

class PagedTableViewController: UIPageViewController {
    
    public var ptvcDataSource: PagedTableViewControllerDataSource!
    public var ptvcDelegate: PagedTableViewControllerDelegate?
    
    // TODO - I'm a little reluctant to expose the entire table view. Don't really feel like implementing all methods though
    public var currentTableView: UITableView! {
        return self.currentViewController.tableView!
    }
    
    public var indexPathsOfSelectedCells = Set<IndexPath>()
    
    public func dequeueReusableCellWithIdentifier(_ identifier: String, forCellAtIndexPath indexPath: IndexPath, onPage page: Int) -> UITableViewCell? {
        let viewController = self.orderedViewControllers[page]
        let tableView = viewController.tableView!
        return tableView.dequeueReusableCell(withIdentifier: identifier)
//        return tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
    }
    
    public func cellForRowAt(indexPath : IndexPath, onPage page: Int) -> UITableViewCell? {
        let tableView = self.orderedViewControllers[page].tableView!
//        tableView.reloadRows(at: [indexPath], with: .none)
        return tableView.cellForRow(at: indexPath)

    }
    
    public func scrollRight(completion: (() -> Void)?) {
        guard currentPage != orderedViewControllers.count-1 else {
            return
        }
        let lastVC = currentViewController
        let nextVC = orderedViewControllers[currentPage+1]
        delegate?.pageViewController!(self, willTransitionTo: [nextVC])
        setViewControllers([nextVC], direction: .forward, animated: true, completion: {
            finished in
//            if finished {
//                completion?()
//            }
            
            self.delegate?.pageViewController!(self, didFinishAnimating: true, previousViewControllers: [lastVC!], transitionCompleted: finished)
        })
    }
    public func scrollLeft() {
        guard currentPage != 0 else {
            print("currentPage \(currentPage) previousPage \(previousPage)")
            return
        }
        let lastVC = currentViewController
        let nextVC = orderedViewControllers[currentPage-1]
        delegate?.pageViewController!(self, willTransitionTo: [nextVC])
        setViewControllers([nextVC], direction: .reverse , animated: true, completion: {
            finished in
            self.delegate?.pageViewController!(self, didFinishAnimating: true, previousViewControllers: [lastVC!], transitionCompleted: finished)
        })
    }
    
    fileprivate var currentViewController: UITableViewController! {
        return viewControllers!.last as! UITableViewController
    }
    public var tableViews = [UITableView]()
    fileprivate var orderedViewControllers = [UITableViewController]()
    public var indexPathOfLastSwipe: IndexPath?
    public fileprivate(set) var currentPage: Int = 0 {
        didSet {
            previousPage = oldValue
        }
    }
    fileprivate var previousPage: Int?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func loadView(){
        super.loadView()
    }
    
    override func viewDidLoad() {
        setupViewControllers()
        setViewControllers([orderedViewControllers.first!], direction: .forward, animated: true, completion: nil)
        dataSource = self
        delegate = self
        
        super.viewDidLoad()
        addInterceptingPanRecognizer()
    }
    
    fileprivate func pageNumber(of tableView: UITableView) -> Int {
        return self.tableViews.index(of: tableView)!
    }
    
    private func setupViewControllers() {
        let numPages = self.ptvcDataSource.numberOfPages(in: self)
        for pageNum in 0...numPages-1 {
            addPage(forPage: pageNum)
        }
    }
    
    public func addPage(forPage page: Int) {
        let tableViewController = UITableViewController(style: .grouped)
        tableViewController.tableView.dataSource = self
        tableViewController.tableView.delegate = self
        orderedViewControllers.append(tableViewController)
        let tableView = tableViewController.tableView!
        tableView.allowsSelection = true
        tableView.allowsMultipleSelection = false
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 250.0
        if let reuseIdentifiers = ptvcDelegate?.reuseIdentifiersToRegister?(forTableViewOnPage: page) {
            //                for (identifier, cellClass) in reuseIdentifiers {
            //                    tableView.register(cellClass, forCellReuseIdentifier: identifier)
            //                }
            // TODO - fix the data structure that this method returns. Don't need cell class.
            for (identifier, nibName) in reuseIdentifiers {
                let nib = UINib(nibName: nibName, bundle: nil)
                tableView.register(nib, forCellReuseIdentifier: identifier)
            }
        }
        tableViews.append(tableViewController.tableView)
    }
    
    private func addInterceptingPanRecognizer() {
        /* this is a required hack caused by a known bug in UIPageViewController.
         intercepting pan gestures does two things: 1 - it allows me to prevent
         non-table-cell touches from triggering a pan and 2 - it lets me access the
         index path of the cell from which the pan originated.
         */
        for v in view.subviews {
            if v.isKind(of: UIScrollView.self) {
                let scrollView = v as! UIScrollView
                scrollView.delaysContentTouches = false
                let panRec = UIPanGestureRecognizer(target: self, action: nil)
                panRec.delegate  = self
                scrollView.addGestureRecognizer(panRec)
            }
        }
    }
}

extension PagedTableViewController: UIPageViewControllerDataSource{
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let numPages = self.ptvcDataSource.numberOfPages(in: self)
        print("numPages is \(numPages)")
        guard let viewController = viewController as? UITableViewController else {
            return nil
        }
        guard let index = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        if index >= numPages-1 {
            return nil
        }
//        if index >= numPages - 1 {
//            addViewController(forPage: index)
//            return orderedViewControllers[index+1]
////            return nil
//        } else {
//            return orderedViewControllers[index+1]
//        }
        print("attempting to get ordered view controller at index \(index + 1)")
        return orderedViewControllers[index+1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewController = viewController as? UITableViewController else {
            return nil
        }
        guard let index = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        if index == 0 {
            return nil
        } else {
            return orderedViewControllers[index-1]
        }
    }
}

extension PagedTableViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        print("will transition")
        guard let nextViewController = pendingViewControllers.first as? UITableViewController else {
            return
        }
        previousPage = currentPage
        guard let nextPage = orderedViewControllers.index(of: nextViewController) else {
            return
        }
        indexPathsOfSelectedCells.removeAll()
        ptvcDelegate?.pagedTableViewController?(self, willTransition: nextPage, fromPage: currentPage)
        if let scrollPosition = ptvcDelegate?.pagedTableViewController?(self, scrollPositionForTransitionToPage: nextPage, fromPage: previousPage!, withSwipeAt: indexPathOfLastSwipe) {
            nextViewController.tableView.scrollToRow(at: scrollPosition, at: .top, animated: true)
        }
//        nextViewController.tableView.reloadData()
//        currentPage = nextPage
//        if let scrollPosition = self.ptvcDelegate?.pagedTableViewController?(self, scrollPositionForTransitionToPage: nextPage, fromPage: previousPage!, withSwipeAt: self.indexPathOfLastSwipe) {
//            nextViewController.tableView.scrollToRow(at: scrollPosition, at: .top, animated: true)
//        }
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        currentPage = orderedViewControllers.index(of: currentViewController)!
        let fromPage: Int = completed ? previousPage! : currentPage
        self.ptvcDelegate?.pagedTableViewController?(self, didFinishAnimatingTransition: finished, toPage: currentPage, fromPage: fromPage, transitionCompleted: completed)
    }
}

extension PagedTableViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        let pageNumber = self.pageNumber(of: tableView)
        return self.ptvcDataSource.pagedTableViewController(self, numberOfSectionsOnPage: pageNumber)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let pageNumber = self.pageNumber(of: tableView)
        let cell = self.ptvcDataSource.pagedTableViewController(self, cellForRowAt: indexPath, onPage: pageNumber)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let pageNumber = self.pageNumber(of: tableView)
        return self.ptvcDataSource.pagedTableViewController(self, numberOfRowsInSection: section, onPage: pageNumber)
    }
}

extension PagedTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let pageNumber = self.pageNumber(of: tableView)
        self.ptvcDelegate?.pagedTableViewController?(self, willDisplay: cell, forRowAt: indexPath, onPage: pageNumber)
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let pageNumber = self.pageNumber(of: tableView)
        // TODO - handle case where delegate returns nil!
        if let returnedIndexPath = self.ptvcDelegate?.pagedTableViewController?(self, willSelectRowAt: indexPath, onPage: pageNumber) {
            return returnedIndexPath
        } else {
            return indexPath
        }
    }
    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        guard let title = ptvcDelegate?.pagedTableViewController?(self, titleForHeaderIn: section, onPage: pageNumber(of: tableView)) else {
//            return nil
//        }
//        let down = Down(markdownString: title)
//        
//        let width = tableView.bounds.width
//        let view = UITableViewHeaderFooterView(frame: CGRect(x: 0, y: 0, width: width, height: 100))
//        view.contentView
//        try? view.textLabel?.text = down.toAttributedString().string
//        return view
//    }
//    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let pageNumber = self.pageNumber(of: tableView)
        indexPathsOfSelectedCells.insert(indexPath)
        self.ptvcDelegate?.pagedTableViewController?(self, didSelectRowAt: indexPath, onPage: pageNumber)
    }
    
    func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        let pageNumber = self.pageNumber(of: tableView)
        // TODO - handle case where delegate returns nil!
        if let returnedIndexPath = self.ptvcDelegate?.pagedTableViewController?(self, willDeselectRowAt: indexPath, onPage: pageNumber) {
            return returnedIndexPath
        } else {
            return indexPath
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let pageNumber = self.pageNumber(of: tableView)
        indexPathsOfSelectedCells.remove(indexPath)
        self.ptvcDelegate?.pagedTableViewController?(self, didDeselectRowAt: indexPath, onPage: pageNumber)
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let pageNumber = self.pageNumber(of: tableView)
        self.ptvcDelegate?.pagedTableViewController?(self, didHighlightRowAt: indexPath, onPage: pageNumber)
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        let pageNumber = self.pageNumber(of: tableView)
        self.ptvcDelegate?.pagedTableViewController?(self, didUnhighlightRowAt: indexPath, onPage: pageNumber)
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
//        return false
        let pageNumber = self.pageNumber(of: tableView)
        guard let should = self.ptvcDelegate?.pagedTableViewController?(self, shouldHighlightRowAt: indexPath, onPage: pageNumber) else {
            return false
        }
        return should
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // TODO - make sure we handle unimmplemented case
        if let height = self.ptvcDelegate?.pagedTableViewController?(self, heightForRowAt: indexPath, onPage: currentPage) {
            return height
        } else {
            return UITableViewAutomaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
//        return indexPathsOfSelectedCells.contains(indexPath)
        return false
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: IndexPath) -> Bool {
//        return indexPathsOfSelectedCells.contains(indexPath)
        return false
    }
    
    func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        if indexPathsOfSelectedCells.contains(indexPath) {
            return 60
        } else {
            return 0
        }
    }
    
//    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
//        print("assigning Edit actions")
//        let action1 = UITableViewRowAction(style: .destructive, title: "Delete", handler: {_,_ in print("delete")})
//        let action2 = UITableViewRowAction(style: .default, title: "Default", handler: {_,_ in print("default")})
//        let action3 = UITableViewRowAction(style: .normal, title: "Normal", handler: {_,_ in print("normal")})
//        return [action1, action2, action3]
//    }
//    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if indexPathsOfSelectedCells.contains(indexPath) {
            return .delete
        } else {
            return .none
        }
    }
    
    func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
//    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        return true
//    }
}

extension PagedTableViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard gestureRecognizer.isKind(of: UIPanGestureRecognizer.self) else {
            return true
        }
        guard let tableViewController = self.viewControllers?.first as? UITableViewController else {
            return true
        }
        if let indexPath = tableViewController.tableView.indexPathForRow(at: touch.location(in: tableViewController.tableView)) {
            // this touch should be handled by the page view controller.
            self.indexPathOfLastSwipe = indexPath
            return false
        }
        print("touch intercepted!")
        return true
    }
}
