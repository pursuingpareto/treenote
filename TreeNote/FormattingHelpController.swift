//
//  FormattingHelpController.swift
//  TreeNote
//
//  Created by Andrew Brown on 10/28/16.
//  Copyright © 2016 Andrew Brown. All rights reserved.
//

import UIKit
import Down

class FormattingHelpController: UITableViewController {
    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    struct HelpSection {
        let title: String
        let cellTexts : [String]
    }
    let data: [HelpSection] = [
        HelpSection(title: "Use # for headers", cellTexts: [
            "# Big Header",
            "## Medium Header",
            "### Small Header",
            ]),
        HelpSection(title: "Use * or ` to format text", cellTexts: [
            "**Bold text**",
            "*Italic text",
            "`Monospaced text`",
            ]),
        HelpSection(title: "Create lists", cellTexts: [
            "Unordered list:\n* item 1\n* item 2\n* item 3",
            "Ordered list:\n1. first item\n2. second item",
            ]),
        HelpSection(title: "Add Links and Images", cellTexts: [
            "![](https://gingkoapp.com/p/images/leaf.png) - link to image with url.",
            "[The best note-taking app](http://www.gingkoapp.com)"
            ])
    ]
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableViewAutomaticDimension
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[section].cellTexts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FormattingHelpCell.identifier, for: indexPath) as! FormattingHelpCell
        let text = data[indexPath.section].cellTexts[indexPath.row]
        print("indexPath is \(indexPath). text is \(text). rawLabel is \(cell.rawLabel)")
        cell.rawLabel.text = text
        
        let down = Down(markdownString: text)        
        try? cell.renderedLabel.attributedText = down.toAttributedString()
        return cell
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return data[section].title
    }
}
