//
//  TreeViewController.swift
//  TreeNote
//
//  Created by Andrew Brown on 10/25/16.
//  Copyright © 2016 Andrew Brown. All rights reserved.
//

import UIKit

enum TreeFocusMode {
    case asParentOfChild    // set on transitions UP / left in the hierarchy
    case asChildrenOfParent // set on transitions DOWN / right in the hierarchy
    case asSiblingsOfCell   // set on selections within the hierarchy
    case asInitialRootView  // initial setting
}

enum TransitionMode {
    case swipeToChildren
    case swipeToParents
    case addCell
    case none
}

class TreeViewController: PagedTableViewController {
    
    var tree: Tree!
    var focusMode = TreeFocusMode.asInitialRootView
    var currentTransitionMode: TransitionMode = .none
    var selectedCell: Cell? = nil
    var selectedParentCell: Cell? = nil
    var selectedChildCell: Cell? = nil
    
    // TODO - reimplement this to reduce the amount of repeated tree traversal.
    var treeData : [[[Cell]]] {
        var depth = 0
        var data = [[[Cell]]]()
        while true {
            let sectionedCells = tree.getSectionedCells(atDepth: depth)
            guard !sectionedCells.isEmpty else {
                return data
            }
            guard !sectionedCells[0].isEmpty else {
                return data
            }
            data.append(sectionedCells)
            depth += 1
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func loadView() {
        ptvcDataSource = self
        ptvcDelegate = self
        super.loadView()
    }
    
    fileprivate func getCell(forIndexPath indexPath: IndexPath, onPage page: Int) -> Cell? {
        return treeData[page][indexPath.section][indexPath.row]
    }
    
    fileprivate func nextStateForSelection(ofCell cell: Cell) -> CellState {
        switch cell.state {
        case .selected: return .focused
        case .editing:  return .editing
        default:        return .selected
        }
    }
    
    fileprivate func stateForCell(cell: Cell) -> CellState {
        switch focusMode {
        case .asInitialRootView:  return CellState.focused
        case .asChildrenOfParent: return cell.parent == selectedParentCell ? .focused : .unfocused
        case .asParentOfChild:    return cell == selectedChildCell?.parent ? CellState.focused : CellState.unfocused
        case .asSiblingsOfCell:   return cell.parent == selectedCell?.parent ? CellState.focused : CellState.unfocused
        }
    }
    
    fileprivate func indexPathForCell(cell: Cell, onPage page: Int) -> IndexPath? {
        for (sectionNumber, section) in treeData[page].enumerated() {
            for (rowNumber, newCell) in section.enumerated() {
                if newCell == cell {
                    return IndexPath(row: rowNumber, section: sectionNumber)
                }
            }
        }
        return nil
    }
    
    fileprivate func indexPathForNewChildOfCell(_ cell: Cell, onPage page: Int) -> IndexPath {
        let nextPage = page + 1
        if nextPage < treeData.count {
            var nextSection = 0
            for section in treeData[page] {
                for cellInSection in section {
                    if cell == cellInSection {
                        return IndexPath(row: cell.children.count, section: nextSection)
                    }
                    if cellInSection.children.count > 0 {
                        nextSection += 1
                    }
                }
            }
            print("INVALID! The cell \(cell) doesn't exist on page \(page)")
        }
        return IndexPath(row: 0, section: 0)
    }
    
    fileprivate func addCell(toIndexPath: IndexPath, toPage: Int, fromIndexPath: IndexPath, fromPage: Int, withParent parent: Cell?) -> EditingCardCell? {
        print("adding cell")
        guard let cell = getCell(forIndexPath: fromIndexPath, onPage: fromPage) else { return nil }
        let newCell = Cell()
        newCell.state = .editing
        cell.state = .focused
        if parent != nil && toPage != fromPage {
            if toPage > fromPage {
                selectedParentCell = getCell(forIndexPath: fromIndexPath, onPage: fromPage)
            }
            if toPage >= treeData.count {
                addPage(forPage: toPage)
            }
            let tableView = tableViews[toPage]
            tree.addCell(cell: newCell, toParent: parent, atIndex: toIndexPath.row)
            if parent!.children.count == 1 {
                var indexSet = IndexSet()
                indexSet.insert(toIndexPath.section)
                tableView.insertSections(indexSet, with: .none)
            } else {
                tableView.insertRows(at: [toIndexPath], with: .none)
                print("inserted row at indexPath \(toIndexPath) on page \(tableViews.index(of: tableView))")
            }
            tableView.reloadData()
            // TODO - use the other cellForRow method
            guard let editCell = tableView.cellForRow(at: toIndexPath) as? EditingCardCell else {
                print("ERROR! couldn't get editing cell at indexPath \(toIndexPath) on page \(toPage)")
                return nil
            }
            return editCell
        } else {
            tree.addCell(cell: newCell, toParent: cell.parent, atIndex: toIndexPath.row)
            currentTableView.beginUpdates()
            currentTableView.insertRows(at: [toIndexPath], with: .none)
            var indexSet = IndexSet()
            indexSet.insert(toIndexPath.section)
            currentTableView.reloadSections(indexSet, with: .automatic)
            currentTableView.endUpdates()
            guard let editCell = currentTableView.cellForRow(at: toIndexPath) as? EditingCardCell else {
                print("ERROR: couldn't get editing cell")
                return nil
            }
            return editCell
        }
    }
    
    // TODO - fix this implementation if it becomes problematic. It scales poorly with tree size.
    fileprivate func deleteDescendents(ofParent parent: Cell, onPage page: Int) {
        let nextPage = page+1
        if nextPage >= tableViews.count { return }
        let sections = treeData[nextPage]
        for (secNum, section) in sections.enumerated() {
            let representativeCell = section.first
            if representativeCell?.parent != parent {
                continue
            }
            var childrenToDelete = [Cell]()
            for cell in section {
                if cell.children.count == 0 {
                    tree.delete(cell: cell)
                } else {
                    childrenToDelete.append(cell)
                }
            }
            if childrenToDelete.count > 0 {
                for child in childrenToDelete {
                    deleteDescendents(ofParent: child, onPage: nextPage)
                    tree.delete(cell: child)
                }
            }
            let table = tableViews[nextPage]
            var indexSet = IndexSet()
            indexSet.insert(secNum)
            table.deleteSections(indexSet, with: .none)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let navController = segue.destination as? UINavigationController {
            let nib = UINib(nibName: "FormattingHelpCell", bundle: nil)
            if let formattingHelpController = navController.viewControllers.first as? FormattingHelpController {
                formattingHelpController.tableView.register(nib, forCellReuseIdentifier: FormattingHelpCell.identifier)
            }
        }
    }
}

extension TreeViewController: PagedTableViewControllerDataSource {
    func numberOfPages(in: PagedTableViewController) -> Int {
        return treeData.count
    }
    
    func pagedTableViewController(_ pagedTableViewController: PagedTableViewController, numberOfSectionsOnPage page: Int) -> Int {
        return treeData[page].count
    }
    
    func pagedTableViewController(_ pagedTableViewController: PagedTableViewController, numberOfRowsInSection section: Int, onPage page: Int) -> Int {
        return treeData[page][section].count
    }
    
    // TODO - fix so only one card can be editing or selected
    func pagedTableViewController(_ pagedTableViewController: PagedTableViewController, cellForRowAt indexPath: IndexPath, onPage page: Int) -> UITableViewCell {
        let cell = treeData[page][indexPath.section][indexPath.row]
        var cardCell: CardCell
        switch cell.state {
        case .editing:
            cardCell = pagedTableViewController.dequeueReusableCellWithIdentifier(cell.state.reuseIdentifier, forCellAtIndexPath: indexPath, onPage: page) as! EditingCardCell
        case .selected:
            cardCell = pagedTableViewController.dequeueReusableCellWithIdentifier(cell.state.reuseIdentifier, forCellAtIndexPath: indexPath, onPage: page) as! SelectedCardCell
        default:
            let state = stateForCell(cell: cell)
            cell.state = state
            cardCell = pagedTableViewController.dequeueReusableCellWithIdentifier(cell.state.reuseIdentifier, forCellAtIndexPath: indexPath, onPage: page) as! DefaultCardCell
        }
        cardCell.delegate = self
        cardCell.setup(withCell: cell)
        cardCell.setNeedsLayout()
        return cardCell
    }
}

extension TreeViewController: PagedTableViewControllerDelegate {
    func pagedTableViewController(_ pagedTableViewController: PagedTableViewController, didSelectRowAt indexPath: IndexPath, onPage page: Int) {
        guard let cell = getCell(forIndexPath: indexPath, onPage: page) else { return }
        print("did select row at \(indexPath)")
        var sectionsNeedingUpdate = IndexSet()
        sectionsNeedingUpdate.insert(indexPath.section)
        defer {
            focusMode = .asSiblingsOfCell
            if selectedCell != nil {
                selectedCell!.state = stateForCell(cell: selectedCell!)
            }
            selectedCell = cell
            selectedChildCell = nil
            selectedParentCell = nil
            let nextState = nextStateForSelection(ofCell: cell)
            cell.state = nextState
            currentTableView.beginUpdates()
            print("sections needing update are \(sectionsNeedingUpdate)")
            currentTableView.reloadSections(sectionsNeedingUpdate, with: .fade)
            currentTableView.endUpdates()
            currentTableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
        
        // add additional sections to sectionsNeedingUpdate as necessary.
        switch focusMode {
        case .asSiblingsOfCell:
            if selectedCell != nil && selectedCell!.parent != cell.parent {
                if let selectedIndexPath = indexPathForCell(cell: selectedCell!, onPage: currentPage) {
                    sectionsNeedingUpdate.insert(selectedIndexPath.section)
                } else {
                    print("Error getting selectedIndexPath for selectedCell \(selectedCell)")
                }
            }
        case .asChildrenOfParent:
            for (secNum, section) in treeData[currentPage].enumerated() {
                let representativeCell = section.first
                if representativeCell?.parent == selectedParentCell {
                    sectionsNeedingUpdate.insert(secNum)
                    break
                }
            }
        case .asParentOfChild:
            guard let parentCell = selectedChildCell?.parent else {
                print("error getting parent cell")
                break
            }
            guard let parentIndexPath = indexPathForCell(cell: parentCell, onPage: currentPage) else {
                print("error getting parentIndexPath for parentCell \(parentCell)")
                break
            }
            sectionsNeedingUpdate.insert(parentIndexPath.section)
        default:
            print("don't need to add any sections for update.")
        }
        focusMode = .asSiblingsOfCell
    }

    func pagedTableViewController(_ pagedTableViewController: PagedTableViewController, shouldHighlightRowAt indexPath: IndexPath, onPage page: Int) -> Bool {
        return true
    }
    
    // TODO - implement this better. Probably require a height property for card cells
    func pagedTableViewController(_ pagedTableViewController: PagedTableViewController, heightForRowAt indexPath: IndexPath, onPage page: Int) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    // TODO - use focusMode to handle focusing
    func pagedTableViewController(_ pagedTableViewController: PagedTableViewController, didFinishAnimatingTransition finished: Bool, toPage: Int, fromPage: Int, transitionCompleted completed: Bool) {
        print("didFinishAnimatingTransition \(currentTransitionMode)")
        defer {
            if currentTransitionMode != .addCell {
                selectedCell = nil
            }
            currentTransitionMode = .none
            indexPathOfLastSwipe = nil
        }
        guard completed else {
            return
        }
    }
    
    func pagedTableViewController(_ pagedTableViewController: PagedTableViewController, willTransition toPage: Int, fromPage: Int) {
        if currentTransitionMode != .addCell {
            currentTransitionMode = (toPage > fromPage) ? .swipeToChildren : .swipeToParents
        }
        // do necessary updates for fromPage tableView and prepare toPage data
        var indexPathsToUpdateOnCurrentPage: [IndexPath] = []
        var nextFocusMode = focusMode
        defer {
            selectedCell?.state = .focused
//            selectedCell = nil
            var previousFocusMode = focusMode
            focusMode = nextFocusMode
            let nextTableView = tableViews[toPage]
            nextTableView.reloadData()
            DispatchQueue.main.async {
                nextFocusMode = self.focusMode
                self.focusMode = previousFocusMode
                self.currentTableView.beginUpdates()
                self.currentTableView.reloadRows(at: indexPathsToUpdateOnCurrentPage, with: .automatic)
                self.currentTableView.endUpdates()
                self.focusMode = nextFocusMode
            }
        }
        if indexPathOfLastSwipe != nil {
            indexPathsToUpdateOnCurrentPage.append(indexPathOfLastSwipe!)
        }
        labelpoint: if selectedCell != nil {
            guard let selected = selectedCell else { break labelpoint }
            guard let selectedIndexPath = indexPathForCell(cell: selected, onPage: fromPage) else { break labelpoint }
            indexPathsToUpdateOnCurrentPage.append(selectedIndexPath)
        }
        switch currentTransitionMode {
        case .swipeToChildren:
            nextFocusMode = .asChildrenOfParent
            if let swipedCell = getCell(forIndexPath: indexPathOfLastSwipe!, onPage: fromPage) {
                selectedParentCell = swipedCell
                selectedChildCell = nil
            } else {
                print("error getting Swiped cell.")
            }
        case .addCell:
            nextFocusMode = .asChildrenOfParent
        case .swipeToParents:
            nextFocusMode = .asParentOfChild
            if let swipedCell = getCell(forIndexPath: indexPathOfLastSwipe!, onPage: fromPage) {
                selectedChildCell = swipedCell
                selectedParentCell = nil
            } else {
                print("error getting Swiped cell.")
            }
        default:
            print("ERROR, transition mode shouldn't be none after successful transition.")
        }
    }
    
    func reuseIdentifiersToRegister(forTableViewOnPage page: Int) -> [String : String] {
        return [CellState.focused.reuseIdentifier: "DefaultCardCell",
                CellState.selected.reuseIdentifier: "SelectedCardCell",
                CellState.editing.reuseIdentifier: "EditingCardCell"]
    }
    
    func pagedTableViewController(_ pagedTableViewController: PagedTableViewController, scrollPositionForTransitionToPage nextPage: Int, fromPage: Int, withSwipeAt indexPath: IndexPath?) -> IndexPath? {
        switch currentTransitionMode {
        case .swipeToChildren:
            let swipedCell = getCell(forIndexPath: indexPath!, onPage: fromPage)!
            var section = indexPathForNewChildOfCell(swipedCell, onPage: fromPage).section
            let maxSection = ptvcDataSource.pagedTableViewController(self, numberOfSectionsOnPage: nextPage)
            if section > maxSection-1 {
                section = maxSection - 1
            }
            // should scroll with multiple sections visible.
            if swipedCell.children.count == 0 && section > 0 {
                return IndexPath(row: treeData[nextPage][section-1].count - 1, section: section-1)
            }
            return IndexPath(row: 0, section: section)
        case .swipeToParents:
            let swipedCell = getCell(forIndexPath: indexPath!, onPage: fromPage)!
            for (secNum, sec) in treeData[nextPage].enumerated() {
                for (rowNum, cell) in sec.enumerated() {
                    if cell == swipedCell.parent {
                        let destIndexPath = IndexPath(row: rowNum, section: secNum)
                        return destIndexPath
                    }
                }
            }
        case .addCell:
            let section = indexPathForNewChildOfCell(selectedCell!, onPage: fromPage).section
            return IndexPath(row: 0, section: section)
    
        default:
            print("Error! couldn't get a scroll position because currentTransitionMode is none")
            return nil
        }
        return nil
    }
}

extension TreeViewController: CardCellDelegate {
    func editButtonPressed(inCardCell cardCell: SelectedCardCell) {
        guard let indexPath = currentTableView.indexPath(for: cardCell) else {
            return
        }
        guard let cell = getCell(forIndexPath: indexPath, onPage: currentPage) else {
            return
        }
        cell.state = .editing
        self.currentTableView.beginUpdates()
        var indexSet = IndexSet()
        indexSet.insert(indexPath.section)
        self.currentTableView.reloadSections(indexSet, with: .automatic)
        self.currentTableView.endUpdates()
        currentTableView.scrollToRow(at: indexPath, at: .top, animated: true)
        // TODO - see how much of this is necessary
        DispatchQueue.global(qos: .userInitiated).async {
            DispatchQueue.main.async {
                guard let newCell = self.cellForRowAt(indexPath: indexPath, onPage: self.currentPage) else {
                    print("couldn't even get a measely uitableview cell")
                    return
                }
                print("newCell is \(newCell)")
                guard let editingCell = self.cellForRowAt(indexPath: indexPath, onPage: self.currentPage) as? EditingCardCell else {
                    print("couldn't get editing cell after pressing edit button.")
                    return
                }
                editingCell.markdownTextView.becomeFirstResponder()
            }
        }
    }
    
    func addAboveButtonPressed(inCardCell cardCell: SelectedCardCell) {
        guard let indexPath = currentTableView.indexPath(for: cardCell) else { return }
        guard let cell = getCell(forIndexPath: indexPath, onPage: currentPage) else { return }
        guard let editCell = addCell(toIndexPath: indexPath, toPage: currentPage, fromIndexPath: indexPath, fromPage: currentPage, withParent: cell.parent) else {
            print("error retrieving edit cell")
            return
        }
        editCell.markdownTextView.becomeFirstResponder()
    }
    
    func addBelowButtonPressed(inCardCell cardCell: SelectedCardCell) {
        guard let indexPath = currentTableView.indexPath(for: cardCell) else { return }
        guard let cell = getCell(forIndexPath: indexPath, onPage: currentPage) else { return }
        let newCellIndexPath = IndexPath(row: indexPath.row+1, section: indexPath.section)
        guard let editCell = addCell(toIndexPath: newCellIndexPath, toPage: currentPage, fromIndexPath: indexPath, fromPage: currentPage, withParent: cell.parent) else {
            print("error retrieving edit cell")
            return
        }
        editCell.markdownTextView.becomeFirstResponder()
    }
    
    func addRightButtonPressed(inCardCell cardCell: SelectedCardCell) {
        guard let indexPath = currentTableView.indexPath(for: cardCell) else { return }
        guard let cell = getCell(forIndexPath: indexPath, onPage: currentPage) else { return }
        let nextPage = currentPage + 1
        let newCellIndexPath = indexPathForNewChildOfCell(cell, onPage: currentPage)
        guard addCell(toIndexPath: newCellIndexPath, toPage: nextPage, fromIndexPath: indexPath, fromPage: currentPage, withParent: cell) != nil else {
            print("ERROR couldn't retrieve edit cell while adding right!")
            return
        }
        currentTransitionMode = .addCell
        scrollRight(completion: nil)
    }
    
    func didEndEditing(textView: UITextView, inCardCell cardCell: EditingCardCell) {
        guard let indexPath = currentTableView.indexPath(for: cardCell) else { return }
        let cell = treeData[currentPage][indexPath.section][indexPath.row]
        cell.text = textView.text
        cell.state = .selected
        selectedCell = cell
        currentTableView.beginUpdates()
        currentTableView.reloadRows(at: [indexPath], with: .automatic)
        currentTableView.endUpdates()
        currentTableView.scrollToRow(at: indexPath, at: .top, animated: true)
        let newCell = cellForRowAt(indexPath: indexPath, onPage: currentPage)
        newCell?.layoutIfNeeded()
    }
    
    func doneEditingButtonPressed(inCardCell cardCell: EditingCardCell) {
        cardCell.markdownTextView.resignFirstResponder()
    }
    
    func formattingHelpButtonPressed(inCardCell cardCell: CardCell) {
        performSegue(withIdentifier: "showFormattingHelp", sender: self)
    }
    
    func deleteButtonPressed(inCardCell cardCell: SelectedCardCell) {
        guard let indexPath = currentTableView.indexPath(for: cardCell) else {
            print("error getting index path while deleting")
            return
        }
        guard let cell = getCell(forIndexPath: indexPath, onPage: currentPage) else {
            print("error getting cell while deleting")
            return
        }
        var pageNum = currentPage + 1
        while pageNum < tableViews.count-1 {
            // todo - move reloadData calls to background thread
            let table = tableViews[pageNum]
            table.reloadData()
            pageNum += 1
        }
        deleteDescendents(ofParent: cell, onPage: currentPage)
        currentTableView.beginUpdates()
        tree.delete(cell: cell)
        currentTableView.deleteRows(at: [indexPath], with: .automatic)
        currentTableView.endUpdates()
    }
}
