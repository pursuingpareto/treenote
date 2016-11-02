//
//  Tree.swift
//  TreeNote
//
//  Created by Andrew Brown on 10/25/16.
//  Copyright © 2016 Andrew Brown. All rights reserved.
//

import Foundation

struct PropertyKey {
    static let rootCellKey = "rootCells"
    static let titleKey = "title"
    static let cellTextKey = "cellText"
    static let cellChildrenKey = "cellChildren"
    static let cellParentKey = "cellParent"
}

class Tree: NSObject, NSCoding {
    var title = "Untitled Tree"
    fileprivate(set) var rootCells = [Cell]()
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("trees")

    init?(rootCells: [Cell], title: String) {
        self.title = title
        self.rootCells = rootCells
        super.init()
    }
    
    func addCell(cell: Cell, toParent parent: Cell?, atIndex index: Int) {
        if let parent = parent {
            parent.add(cell: cell, atIndex: index)
        } else {
            self.rootCells.insert(cell, at: index)
        }
    }
    
    func delete(cell: Cell) {
        var pathToCell = getPathToCell(cell: cell)
        var children = self.rootCells
        var child: Cell? = nil
        var nextIndex: Int
        while pathToCell.count > 1 {
            nextIndex = pathToCell.popLast()!
            child = children[nextIndex]
            children = child!.children
        }
        let indexOfCellToRemove = pathToCell.popLast()!
        children.remove(at: indexOfCellToRemove)
        if child != nil {
            child!.children = children
        } else {
            self.rootCells = children
        }
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
    
    // MARK: NSCoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(rootCells, forKey: PropertyKey.rootCellKey)
        aCoder.encode(title, forKey: PropertyKey.titleKey)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let rootCells = aDecoder.decodeObject(forKey: PropertyKey.rootCellKey) as? [Cell] else { return nil }
        guard let title = aDecoder.decodeObject(forKey: PropertyKey.titleKey) as? String else { return nil }
        self.init(rootCells: rootCells, title: title)
    }
}


