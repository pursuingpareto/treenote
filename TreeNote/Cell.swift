//
//  Cell.swift
//  TreeNote
//
//  Created by Andrew Brown on 10/25/16.
//  Copyright © 2016 Andrew Brown. All rights reserved.
//

import Foundation

enum CellState {
    case unfocused
    case focused
    case selected
    case editing
    
    var reuseIdentifier: String {
        switch self {
        case .selected:
            return "selectedCardCell"
        case .editing:
            return "editingCardCell"
        default:
            return "defaultCardCell"
        }
    }
}

class Cell {
    var text: String = ""
    weak var parent: Cell?
    var children = [Cell]()
    var state : CellState = .unfocused
    func append(cell: Cell) {
        cell.parent = self
        self.children.append(cell)
    }
    
    func add(cell: Cell, atIndex index: Int) {
        self.children.insert(cell, at: index)
        cell.parent = self
    }
}

extension Cell: Equatable {
    static func ==(lhs: Cell, rhs: Cell) -> Bool {
        if lhs.parent == rhs.parent && lhs.text == rhs.text && lhs.children.count == rhs.children.count {
            return true
        } else {
            return false
        }
    }
}

