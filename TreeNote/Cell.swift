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

class Cell: NSObject, NSCoding {
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
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(text, forKey: PropertyKey.cellTextKey)
        aCoder.encode(parent, forKey: PropertyKey.cellParentKey)
        aCoder.encode(children, forKey: PropertyKey.cellChildrenKey)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let text = aDecoder.decodeObject(forKey: PropertyKey.cellTextKey) as? String
        let parent = aDecoder.decodeObject(forKey: PropertyKey.cellParentKey) as? Cell
        let children = aDecoder.decodeObject(forKey: PropertyKey.cellChildrenKey) as? [Cell]
        guard text != nil && children != nil else {
            print("error decoding cell")
            return nil
        }
        self.init()
        self.parent = parent
        self.text = text!
        self.children = children!
    }
}

//extension Cell: Equatable {
//    static func ==(lhs: Cell, rhs: Cell) -> Bool {
//        if lhs.parent == rhs.parent && lhs.text == rhs.text && lhs.children.count == rhs.children.count {
//            return true
//        } else {
//            return false
//        }
//    }
//}

