//
//  User.swift
//  TreeNote
//
//  Created by Andrew Brown on 10/28/16.
//  Copyright © 2016 Andrew Brown. All rights reserved.
//

import Foundation

class User {
    var exampleTree = Tree(rootCells: [
        Cell(withMarkdownText: "# ![Tree image](https://gingkoapp.com/p/images/leaf.png) Welcome!\nThis is the first **`root cell`** in the tree."),
        Cell(withMarkdownText: "## ![Tree image](https://gingkoapp.com/p/images/leaf.png) Navigation\nSwipe **left** on this card to see its **`children`**"),
        Cell(withMarkdownText: "## ![Tree image](https://gingkoapp.com/p/images/leaf.png) Manipulation\nTap this cell to select it. Once it's selected there are several things you can do:\n1. Add a **`sibling`** cell by pressing one of the **`+`** buttons at the top and bottom of the cell.\n2. Edit the **markdown text** for this cell by pressing the pen button.\n3. Delete the cell by pressing the delete button.\n4. For cells which currently have no children, you can add a child cell by pressing the **`+`** button to the right."),
        Cell(withMarkdownText: "## ![Tree image](https://gingkoapp.com/p/images/leaf.png) Markdown\nThis app uses [markdown](https://daringfireball.net/projects/markdown/syntax), an easy-to-read and easy-to-write format for creating rich text documents.\nYou can get formatting help by selecting the **`Formatting Help`** button in a cell that is in edit mode."),
        Cell(withMarkdownText: "# ![Tree image](https://gingkoapp.com/p/images/leaf.png) Why?\nI made this as a mobile-friendly version of my favorite note taking web app [Gingko](https://gingkoapp.com). Check out the children of this cell if you care to know more.")
        ], title: "Demonstration Tree")
    
    var techTree = Tree(rootCells: [
        Cell(withMarkdownText: "# Models\nThis app uses 3 models: `Tree`, `Cell`, and `User`"),
        Cell(withMarkdownText: "# Views\nMost of the visual work is in the cells which populate the various table views used in this app."),
        Cell(withMarkdownText: "# ViewControllers\nThis app has 4 view controllers: `PagedTableViewController` (which also has corresponding `delegate` and `dataSource` protocols), `TreeViewController` (which conforms to these protocols), `TreeBrowseViewController`, and `FormattingHelpController`.")
        ], title: "Technical Notes")
    
    static let sharedInstance = User()
    
    init() {
        setupExampleTree()
    }
    
    var trees = [Tree]()
    
    func saveTrees() {
        let saveSuccessful = NSKeyedArchiver.archiveRootObject(trees, toFile: Tree.ArchiveURL.path)
        if !saveSuccessful {
            print("failed to save tree")
        }
    }
    
    func loadTrees() -> [Tree]? {
        if let trees = NSKeyedUnarchiver.unarchiveObject(withFile: Tree.ArchiveURL.path) as? [Tree] {
            self.trees = trees
            return trees
        }
        print("failed to load trees")
        return nil
    }
    
    private func setupExampleTree() {
        let navCell = exampleTree!.rootCells[1]
        navCell.append(cell: Cell(withMarkdownText: "## Well done\nThis cell is the first **`child`** of the cell titled \"navigation\"."))
        navCell.append(cell: Cell(withMarkdownText: "...and this is the second child. Notice how they're grouped together."))
        navCell.append(cell: Cell(withMarkdownText: "Try swiping **right** from one of the cells in this section. The **`parent`** of this section will be scrolled to the top."))
        
        let manipulationCell = exampleTree!.rootCells[2]
        manipulationCell.append(cell: Cell(withMarkdownText: "### First Child of \"Manipulation\"\nThis is the first child of the cell titled \"manipulation\". It's grouped with its **`sibling cells`** (only one to begin with)."))
        manipulationCell.append(cell: Cell(withMarkdownText: "### Growing the family\nIncrease the size of this family by:\n1. Adding a sibling cell below this one.\n2. Adding a child cell to the sibling you created."))
        
        let whyCell = exampleTree!.rootCells[4]
        whyCell.append(cell: Cell(withMarkdownText: "### Reason 1: I love Gingko\nI like taking notes in a way that lets me jump between levels of granularity without losing context. I find Gingko's hierarchical approach great for that."))
        whyCell.append(cell: Cell(withMarkdownText: "### Reason 2: Get back into iOS development\nIt had been a while since I'd done iOS development and I wanted to get back in the game / try out Swift 3 / have some code to share with people who may want to hire me 😬.\nI chose to recreate *some* of Gingko because it allowed me to use the existing web app as a sort of spec and focus my effort on the code."))
        whyCell.append(cell: Cell(withMarkdownText: "### Why not put this in the App Store?\nAfter getting this to a suitable beta-level I realized that too much is lost in the small-screen implementation of this. It's impractical to actually show the parents, children **and** siblings of a given card at once on an iPhone but without all of that context I think you lose most of what I loved about Gingko in the first place."))
    }
}
