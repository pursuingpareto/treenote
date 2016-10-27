//
//  TreeViewController.swift
//  TreeNote
//
//  Created by Andrew Brown on 10/25/16.
//  Copyright © 2016 Andrew Brown. All rights reserved.
//

import UIKit

class TreeViewController: PagedTableViewController {
    
    var tree: Tree!
    
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
        tree = Tree()
        tree.populateWithFakeData()
        super.loadView()
    }
    
    fileprivate func getCell(forIndexPath indexPath: IndexPath, onPage page: Int) -> Cell? {
        print("getting cell on page \(page) at indexPath \(indexPath)")
        return treeData[page][indexPath.section][indexPath.row]
    }
    
    fileprivate func nextStateForSelection(ofCell cell: Cell) -> CellState {
        switch cell.state {
        case .selected:
            return stateForCell(cell: cell)
//            return .unfocused
        case .editing:
            return .editing
        default:
            return .selected
        }
    }
    
    fileprivate func stateForCell(cell: Cell) -> CellState {
        if cell.parent == selectedParentCell || cell.parent == selectedCell || cell == selectedChildCell?.parent {
            return CellState.focused
        } else {
            return CellState.unfocused
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
        guard let cell = getCell(forIndexPath: fromIndexPath, onPage: fromPage) else {
//            print("error retrieving cell while adding new cell")
            return nil
        }
        let newCell = Cell()
//        newCell.parent = parent
        newCell.state = .editing
//        newCell.text = "example text"
        cell.state = .focused
        selectedCell = nil
        selectedParentCell = nil
        selectedChildCell = nil
        if parent != nil && toPage != fromPage {
            if toPage >= treeData.count {
                addPage(forPage: toPage)
                print("there are \(tableViews.count) UI pages")
            }
            let tableView = tableViews[toPage]
            tree.addCell(cell: newCell, toParent: parent, atIndex: toIndexPath.row)
            if parent!.children.count == 1 {
                print("inserting section \(toIndexPath.section)")
                var indexSet = IndexSet()
                indexSet.insert(toIndexPath.section)
                tableView.insertSections(indexSet, with: .none)
            } else {
                tableView.insertRows(at: [toIndexPath], with: .none)
                print("inserted row at indexPath \(toIndexPath) on page \(tableViews.index(of: tableView))")
            }
            
            print("there are \(treeData.count) data pages")
//            guard let indexPath = indexPathForCell(cell: newCell, onPage: toPage) else {
//                print("couldn't get indexPath")
//                return nil
//            }
//            print("index path of new cell SHOULD be \(indexPath) on page \(toPage)")
            
            
//            tableView.beginUpdates()
            
            tableView.reloadData()
//            var indexSet = IndexSet()
//            indexSet.insert(toIndexPath.section)
//            tableView.reloadSections(indexSet, with: .automatic)
//            tableView.endUpdates()
            guard let cardCell = tableView.cellForRow(at: toIndexPath) else {
                print("ERROR!! Couldn't get ANY cell at indexpath \(toIndexPath)")
                return nil
            }
            print("got cell!! It's \(cardCell)")
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
        return cardCell
    }
}

extension TreeViewController: PagedTableViewControllerDelegate {
    func pagedTableViewController(_ pagedTableViewController: PagedTableViewController, didSelectRowAt indexPath: IndexPath, onPage page: Int) {
        guard let cell = getCell(forIndexPath: indexPath, onPage: page) else {
            return
        }
        var indexPathsNeedingUpdate = [indexPath]
        let previouslySelected = selectedCell
        selectedCell = cell
        selectedChildCell = nil
        selectedParentCell = nil
        if previouslySelected != nil && previouslySelected != cell {
            previouslySelected!.state = stateForCell(cell: previouslySelected!)
            if let previousIndexPath = indexPathForCell(cell: previouslySelected!, onPage: page) {
                print("previous indexPath is \(previousIndexPath)")
                indexPathsNeedingUpdate.append(previousIndexPath)
            }
        }
        let nextState = nextStateForSelection(ofCell: cell)
        guard nextState != cell.state else {
            return
        }

//        if let currentSelection = selectedCellForPage[page] {
//            indexPathsToUpdate.append(cu)
//        }
        cell.state = nextState
        currentTableView.beginUpdates()
        currentTableView.reloadRows(at: indexPathsNeedingUpdate, with: .automatic)
        
        currentTableView.endUpdates()
    }
    
    func pagedTableViewController(_ pagedTableViewController: PagedTableViewController, didDeselectRowAt indexPath: IndexPath, onPage page: Int) {
        print("  deselecting")
        let cell = getCell(forIndexPath: indexPath, onPage: page)
        print("deselected cell with text \(cell?.text)")
    }
    
    func pagedTableViewController(_ pagedTableViewController: PagedTableViewController, shouldHighlightRowAt indexPath: IndexPath, onPage page: Int) -> Bool {
        return true
    }
    
    // TODO - implement this better. Probably require a height property for card cells
    func pagedTableViewController(_ pagedTableViewController: PagedTableViewController, heightForRowAt indexPath: IndexPath, onPage page: Int) -> CGFloat {
        return UITableViewAutomaticDimension
//        guard let cell = getCell(forIndexPath: indexPath, onPage: page) else {
//            print("invalid index path")
//            return 50
//        }
//        
//        switch cell.state {
//        case .selected:
//            return 250
//        case .editing:
//            return 200
//        default:
//            return 90
//        }
    }
    
    func pagedTableViewController(_ pagedTableViewController: PagedTableViewController, didFinishAnimatingTransition finished: Bool, toPage: Int) {
        print("did finish editing")
        let sections = treeData[toPage]
        for (sectionNum, section) in sections.enumerated() {
            for (rowNum, cell) in section.enumerated() {
                if cell.state == .editing {
                    let indexPath = IndexPath(row: rowNum, section: sectionNum)
                    
                    
                    DispatchQueue.global(qos: .userInitiated).async {
                        self.currentTableView.reloadData()
                        DispatchQueue.main.async {
                            guard let editCell = self.cellForRowAt(indexPath: indexPath, onPage: toPage) as? EditingCardCell else {
                                let cell = self.getCell(forIndexPath: indexPath, onPage: toPage)
                                print("cell at \(indexPath) on page \(toPage) has state \(cell?.state) and text \(cell?.text)")
                                return
                            }
                            print("GOT EDIT CELL with text \(editCell.markdownTextView.text)")
                            editCell.markdownTextView.becomeFirstResponder()
                        }
                    }
                }
            }
        }
    }
    
    func reuseIdentifiersToRegister(forTableViewOnPage page: Int) -> [String : String] {
        return [CellState.focused.reuseIdentifier: "DefaultCardCell",
                CellState.selected.reuseIdentifier: "SelectedCardCell",
                CellState.editing.reuseIdentifier: "EditingCardCell"]
    }
    
//    func pagedTableViewController(_ pagedTableViewController: PagedTableViewController, shouldTransitionWith interactionType: PagedTableViewInteractionType, at indexPath: IndexPath?) -> Bool {
//        return true
//    }

    
    func pagedTableViewController(_ pagedTableViewController: PagedTableViewController, scrollPositionForTransitionToPage nextPage: Int, fromPage: Int, withSwipeAt indexPath: IndexPath?) -> IndexPath? {
        // TODO - improve this implementation
        return IndexPath(row: 0, section: 0)
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
        currentTableView.beginUpdates()
        currentTableView.reloadRows(at: [indexPath], with: .automatic)
        currentTableView.endUpdates()
        guard let editingCell = currentTableView.cellForRow(at: indexPath) as? EditingCardCell else {
            return
        }
        editingCell.markdownTextView.becomeFirstResponder()
        print("delegate acknowledge edit")
    }
    
    func addAboveButtonPressed(inCardCell cardCell: SelectedCardCell) {
        print("delegate acknowledges add above")
        guard let indexPath = currentTableView.indexPath(for: cardCell) else {
            return
        }
        guard let cell = getCell(forIndexPath: indexPath, onPage: currentPage) else {
            return
        }
        guard let editCell = addCell(toIndexPath: indexPath, toPage: currentPage, fromIndexPath: indexPath, fromPage: currentPage, withParent: cell.parent) else {
            print("error retrieving edit cell")
            return
        }
        editCell.markdownTextView.becomeFirstResponder()
    }
    
    func addBelowButtonPressed(inCardCell cardCell: SelectedCardCell) {
        guard let indexPath = currentTableView.indexPath(for: cardCell) else {
            return
        }
        guard let cell = getCell(forIndexPath: indexPath, onPage: currentPage) else {
            return
        }
        let newCellIndexPath = IndexPath(row: indexPath.row+1, section: indexPath.section)
        guard let editCell = addCell(toIndexPath: newCellIndexPath, toPage: currentPage, fromIndexPath: indexPath, fromPage: currentPage, withParent: cell.parent) else {
            print("error retrieving edit cell")
            return
        }
        editCell.markdownTextView.becomeFirstResponder()
        print("delegate acknowledges add below")
    }
    
    func addRightButtonPressed(inCardCell cardCell: SelectedCardCell) {
        guard let indexPath = currentTableView.indexPath(for: cardCell) else {
            return
        }
        guard let cell = getCell(forIndexPath: indexPath, onPage: currentPage) else {
            return
        }
        let nextPage = currentPage + 1
        
        let newCellIndexPath = indexPathForNewChildOfCell(cell, onPage: currentPage)
        guard let editCell = addCell(toIndexPath: newCellIndexPath, toPage: nextPage, fromIndexPath: indexPath, fromPage: currentPage, withParent: cell) else {
            print("ERROR couldn't retrieve edit cell while adding right!")
            return
        }
        scrollRight(completion: nil)
//        editCell.markdownTextView.becomeFirstResponder()
        print("delegate acknowledges add right")
    }
    
    func didEndEditing(textView: UITextView, inCardCell cardCell: EditingCardCell) {
        print("delegate acknowledges did end editing")
        guard let indexPath = currentTableView.indexPath(for: cardCell) else {
            print("error, this card is not on current tableview")
            return
        }
        let cell = treeData[currentPage][indexPath.section][indexPath.row]
        cell.text = textView.text
        cell.state = .selected
        selectedCell = cell
        currentTableView.beginUpdates()
        currentTableView.reloadRows(at: [indexPath], with: .automatic)
        currentTableView.endUpdates()
    }
    
    func doneEditingButtonPressed(inCardCell cardCell: EditingCardCell) {
        cardCell.markdownTextView.resignFirstResponder()
        print("delegate acknowledges done editing button pressed")
    }
    
    func formattingHelpButtonPressed(inCardCell cardCell: CardCell) {
        print("delegate acknowledges formatting help pressed")
    }
    
    func deleteButtonPressed(inCardCell cardCell: SelectedCardCell) {
        print("delegate acknowledges delete button pressed")
    }
}
