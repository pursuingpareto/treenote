//
//  Tree.swift
//  TreeNote
//
//  Created by Andrew Brown on 10/25/16.
//  Copyright © 2016 Andrew Brown. All rights reserved.
//

import Foundation

class Tree {
    var title = "Untitled Tree"
//    private(set) var rootCells: [Cell] = [Cell()]
    private(set) var rootCells = [Cell]()
    // TODO - implement this to actually return maxDepth...
    private(set) var maxDepth = 2
    
    
    func addCell(cell: Cell, toParent parent: Cell?, atIndex index: Int) {
        let newCell = Cell()
        if let parent = parent {
            parent.add(cell: newCell, atIndex: index)
        } else {
            self.rootCells.insert(newCell, at: index)
        }
    }
    
    //    func deleteCell(atDepth depth: Int, inSection section: Int, atPosition position: Int) {
    //        var cellsAtDepth = self.getSectionedCells(atDepth: depth)
    //        print("removing cell at depth \(depth) in section \(section) at position \(position)")
    //        let removed = cellsAtDepth[section].remove(at: position)
    //        print("removed cell with text \(removed.text)")
    //    }
    
    func delete(cell: Cell) {
        print("deleting cell with text \(cell.text)")
        var pathToCell = getPathToCell(cell: cell)
        print("path to cell is \(pathToCell)")
        var children = self.rootCells
        var child: Cell? = nil
        var nextIndex: Int
        while pathToCell.count > 1 {
            nextIndex = pathToCell.popLast()!
            child = children[nextIndex]
            children = child!.children
        }
        
        let lastIndex = pathToCell.popLast()!
        let deleted = children.remove(at: lastIndex)
        if child != nil {
            child!.children = children
        } else {
            self.rootCells = children
        }
        
        print("Deleted cell with text \(deleted.text)")
    }
    
    func getPathToCell(cell: Cell) -> [Int] {
        var parents: [Cell] = [cell]
        var currentCell: Cell = cell
        while currentCell.parent != nil {
            parents.append(currentCell.parent!)
            currentCell = currentCell.parent!
        }
        var childIndices = [Int]()
        var parent: Cell
        var currentCandidates = self.rootCells
        while parents.count > 0 {
            parent = parents.popLast()!
            for (i, candidate) in currentCandidates.enumerated() {
                if candidate == parent {
                    childIndices.append(i)
                    currentCandidates = candidate.children
                    break
                }
            }
        }
        return childIndices.reversed()
    }
    
    func getSectionedCells(atDepth depth: Int) -> [[Cell]] {
        var currentLevelCells = [self.rootCells]
        var nextLevelCells = [[Cell]]()
        var currentDepth = 0
        while currentDepth < depth {
            for cellSection in currentLevelCells {
                for cell in cellSection {
                    if cell.children.count > 0 {
                        nextLevelCells.append(cell.children)
                    }
                }
            }
            currentDepth += 1
            currentLevelCells = nextLevelCells
            nextLevelCells.removeAll()
        }
        return currentLevelCells
    }
    
    func updateCellInSectionedCells(atDepth depth: Int, inSection section: Int, atPosition position: Int, toText text: String) -> [[Cell]]{
        let cellsAtDepth = self.getSectionedCells(atDepth: depth)
        let cell = cellsAtDepth[section][position]
        cell.text = text
        return cellsAtDepth
    }
    
    func populateWithFakeData() {
        let cellTexts = ["**bold** example 1", "*italics* here's another cell", "### h3 more cells!", "## A list\n* one\n* two"]
        var cell: Cell
        for cellText in cellTexts {
            cell = Cell()
            cell.text = cellText
            self.rootCells.append(cell)
        }
        for cell in self.rootCells {
            for cellText in cellTexts {
                let newCell = Cell()
                newCell.text = "\(cell.text) -- \(cellText)"
                cell.append(cell: newCell)
            }
        }
    }
}