//
//  User.swift
//  TreeNote
//
//  Created by Andrew Brown on 10/28/16.
//  Copyright © 2016 Andrew Brown. All rights reserved.
//

import Foundation

class User {
    static let sharedInstance = User()
    var trees = [Tree]()
    func saveTrees() {
        let saveSuccessful = NSKeyedArchiver.archiveRootObject(trees, toFile: Tree.ArchiveURL.path)
        if !saveSuccessful {
            print("failed to save tree")
        } else {
            print("successfully saved trees")
        }
    }
    func loadTrees() -> [Tree]? {
        if let trees = NSKeyedUnarchiver.unarchiveObject(withFile: Tree.ArchiveURL.path) as? [Tree] {
            self.trees = trees
            print("successfully loaded trees")
            return trees
        }
        print("failed to load trees")
        return nil
    }
}
