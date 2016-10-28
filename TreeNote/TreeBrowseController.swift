//
//  TreeBrowseController.swift
//  TreeNote
//
//  Created by Andrew Brown on 10/28/16.
//  Copyright © 2016 Andrew Brown. All rights reserved.
//

import UIKit

class TreeBrowseController: UIViewController {
    
    var trees : [Tree] {
        get {
            return User.sharedInstance.trees
        }
        set {
            User.sharedInstance.trees = newValue
        }
    }
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        if let userTrees = User.sharedInstance.loadTrees() {
            // user already has some saved trees.
            trees = userTrees
            if trees.count == 0 {
                let newTree = Tree(rootCells: [], title: "New Tree")!
                newTree.populateWithFakeData()
                trees = [newTree]
            }
        } else {
            if let tree = Tree(rootCells: [], title: "Untitled Tree") {
                tree.populateWithFakeData()
                trees = [tree]
            }
        }
//        treeTitles.append("My First Tree")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
//    fileprivate func treeForTitle(_ title: String) -> Tree? {
//        let tree = Tree(rootCells: [], title: title)
//        tree?.populateWithFakeData()
//        return tree
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        guard let browseCell = sender as? TreeBrowseCell else {
            print("Received segue from invalid sender \(sender)")
            return
        }
        guard let treeTitle = browseCell.textLabel?.text else {
            print("tree browse cell had no textlabel text")
            return
        }
        var tree: Tree? = nil
        for t in trees {
            if t.title == treeTitle {
                tree = t
                break
            }
        }
        guard let nextVC = segue.destination as? TreeViewController else {
            print("attempting to segue to invalid view controller \(segue.destination)")
            return
        }
        if tree != nil {
            nextVC.tree = tree
            nextVC.navigationItem.title = treeTitle
        }
    }
}

extension TreeBrowseController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trees.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "treeBrowseCell", for: indexPath) as! TreeBrowseCell
        cell.textLabel!.text = trees[indexPath.row].title
        return cell
    }
}

extension TreeBrowseController: UITableViewDelegate {
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let title = treeTitles[indexPath.row]
//        let tree = treeForTitle(title)
//        performSegue(withIdentifier: <#T##String#>, sender: <#T##Any?#>)
//        
//    }
}
