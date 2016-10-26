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
        print("page: \(page), indexPath: \(indexPath)")
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
            print("previously selected is \(previouslySelected!.text)")
            previouslySelected!.state = stateForCell(cell: previouslySelected!)
            print("previously selected state is \(previouslySelected!.state)")
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
        print("indexPaths needing update are \(indexPathsNeedingUpdate)")
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
    }
    
    func addBelowButtonPressed(inCardCell cardCell: SelectedCardCell) {
        print("delegate acknowledges add below")
    }
    
    func addRightButtonPressed(inCardCell cardCell: SelectedCardCell) {
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
