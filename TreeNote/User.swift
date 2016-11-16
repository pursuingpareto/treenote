//
//  User.swift
//  TreeNote
//
//  Created by Andrew Brown on 10/28/16.
//  Copyright © 2016 Andrew Brown. All rights reserved.
//

import Foundation

class User {
    // TODO - pull all this "exampleTree" business into a separate file.
    var exampleTree = Tree(rootCells: [
        Cell(withMarkdownText: "## ![Tree image](https://gingkoapp.com/p/images/leaf.png) Navigation\nWelcome! This is the first **root cell** of the tree. Swipe **left** on this card to see its **`children`**"),
        Cell(withMarkdownText: "## ![Tree image](https://gingkoapp.com/p/images/leaf.png) Manipulation\nTap this cell to select it. Once it's selected there are several things you can do:\n1. Add a **`sibling`** cell by pressing one of the **`+`** buttons at the top and bottom of the cell.\n2. Edit the **markdown text** for this cell by pressing the pen button.\n3. Delete the cell by pressing the delete button.\n4. For cells which currently have no children, you can add a child cell by pressing the **`+`** button to the right."),
        Cell(withMarkdownText: "## ![Tree image](https://gingkoapp.com/p/images/leaf.png) Markdown\nThis app uses [markdown](https://daringfireball.net/projects/markdown/syntax), an easy-to-read and easy-to-write format for creating rich text documents.\nYou can get formatting help by selecting the **`Formatting Help`** button in a cell that is in edit mode."),
        Cell(withMarkdownText: "# ![Tree image](https://gingkoapp.com/p/images/leaf.png) Why?\nI made this as a mobile-friendly version of my favorite note taking web app [Gingko](https://gingkoapp.com). Check out the children of this cell if you care to know more."),
        Cell(withMarkdownText: "# ![Tree image](https://gingkoapp.com/p/images/leaf.png) Design Decisions\nI put this app together as a way to refresh my iOS development skills and to learn more about Swift 3 (I'm not intending to put this into the app store). This motivation had several impacts on my design decisions.")
        ], title: "Demonstration Tree")
    
    static let sharedInstance = User()
    
    private init() {
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
        let navCell = exampleTree!.rootCells[0]
        navCell.append(cell: Cell(withMarkdownText: "## Well done\nThis cell is the first **`child`** of the cell titled \"navigation\"."))
        navCell.append(cell: Cell(withMarkdownText: "...and this is the second child. Notice how they're grouped together."))
        navCell.append(cell: Cell(withMarkdownText: "Try swiping **right** from one of the cells in this section. The **`parent`** of this section will be scrolled to the top."))
        
        let manipulationCell = exampleTree!.rootCells[1]
        manipulationCell.append(cell: Cell(withMarkdownText: "### First Child of \"Manipulation\"\nThis is the first child of the cell titled \"manipulation\". It's grouped with its **`sibling cells`** (only one to begin with)."))
        manipulationCell.append(cell: Cell(withMarkdownText: "### Growing the family\nIncrease the size of this family by:\n1. Adding a sibling cell below this one.\n2. Adding a child cell to the sibling you created."))
        
        let mdCell = exampleTree!.rootCells[2]
        mdCell.append(cell: Cell(withMarkdownText: "### The Pros of Markdown\nMarkdown is both expressive and easy to learn. You can easily read markdown even when it's unrendered."))
        mdCell.append(cell: Cell(withMarkdownText: "### The Cons of Markdown\nThe biggest problem with writing in markdown on a mobile device? Navigating keyboards! Want to make a heading? That will be two clicks just to get to the keyboard with the `#` character and then another click to go back. Ugh."))
        
        let whyCell = exampleTree!.rootCells[3]
        whyCell.append(cell: Cell(withMarkdownText: "### Reason 1: I love Gingko\nI like taking notes in a way that lets me jump between levels of granularity without losing context. I find Gingko's hierarchical approach great for that."))
        whyCell.append(cell: Cell(withMarkdownText: "### Reason 2: Get back into iOS development\nIt had been a while since I'd done iOS development and I wanted to get back in the game / try out Swift 3 / have some code to share with people who may want to hire me 😬.\nI chose to recreate *some* of Gingko because it allowed me to use the existing web app as a sort of spec and focus my effort on the code."))
        whyCell.append(cell: Cell(withMarkdownText: "### Why not put this in the App Store?\nAfter getting this to a suitable beta-level I realized that too much is lost in the small-screen implementation of this. It's impractical to actually show the parents, children **and** siblings of a given card at once on an iPhone but without all of that context I think you lose most of what I loved about Gingko in the first place."))
        
        let designCell = exampleTree!.rootCells[4]
        designCell.append(cell: Cell(withMarkdownText: "### Persistence\nMy approach to persistence here was \"get it working fast\". Some implications: \n* I used NSKeyedArchiver to persist trees locally.\n* All of a user's trees are loaded into memory at once.\n* No remote persistence.\n* Saving of data only happens when the app enters background or terminates."))
        designCell.append(cell: Cell(withMarkdownText: "### Testing\nThere are no tests. I've been using TDD more and more in the code I write, but for this app the most likely causes of bugs were in the UI (which is hard to write tests for until the UI actually exists). In hindsight, I wish I had written some simple UI test cases for basic interactions (adding / deleting / navigating between cells) once I had gotten those working."))
    }
}
