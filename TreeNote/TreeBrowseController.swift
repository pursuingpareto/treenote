//
//  TreeBrowseController.swift
//  TreeNote
//
//  Created by Andrew Brown on 10/28/16.
//  Copyright © 2016 Andrew Brown. All rights reserved.
//

import UIKit

class TreeBrowseController: UIViewController {
    var newTitleField: UITextField?
    var trees : [Tree] {
        get {
            return User.sharedInstance.trees
        }
        set {
            print("set value of trees. Now there are \(newValue.count)")
            User.sharedInstance.trees = newValue
        }
    }
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func editButtonPressed(_ sender: UIBarButtonItem) {
        tableView.setEditing(!tableView.isEditing, animated: true)
        sender.title = tableView.isEditing ? "Done" : "Edit"
    }
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        let newTreePrompt = UIAlertController(title: "Create New Tree", message: nil, preferredStyle: .alert)
        newTreePrompt.addTextField(configurationHandler: {
            textField in
            textField.placeholder = "New Tree Title"
            textField.autocapitalizationType = .words
            self.newTitleField = textField
        })
        newTreePrompt.addAction(UIAlertAction(title: "Cancel", style: .cancel , handler: nil))
        newTreePrompt.addAction(UIAlertAction(title: "OK", style: .default, handler: {
            action in
            let firstCell = Cell()
            firstCell.text = "Example Text"
            let newTree = Tree(rootCells: [firstCell], title: "Untitled Tree")!
            guard let text = self.newTitleField?.text else {
                print("no text found for title")
                return
            }
            newTree.title = text
            for tree in self.trees {
                if tree.title == text {
                    print("title already exists.")
                    return
                }
            }
            self.trees.append(newTree)
            self.tableView.insertRows(at: [IndexPath(row: self.trees.count-1, section: 0)] , with: .automatic)
            
        }))
        present(newTreePrompt, animated: true, completion: nil)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        if let userTrees = User.sharedInstance.loadTrees() {
            // user already has some saved trees.
            trees = userTrees
            if trees.count == 0 {
                trees = [User.sharedInstance.exampleTree!, User.sharedInstance.techTree!]
            }
        } else {
            trees = [User.sharedInstance.exampleTree!, User.sharedInstance.techTree!]
        }
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
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else {
            return
        }
        trees.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}
