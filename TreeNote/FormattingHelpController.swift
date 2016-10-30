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
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return data.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return data[section].cellTexts.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FormattingHelpCell.identifier, for: indexPath) as! FormattingHelpCell
        let text = data[indexPath.section].cellTexts[indexPath.row]
        print("indexPath is \(indexPath). text is \(text). rawLabel is \(cell.rawLabel)")
        cell.rawLabel.text = text
        
        let down = Down(markdownString: text)
        var attributedText: NSAttributedString? = nil
        attributedText = try? down.toAttributedString()
        
        try? cell.renderedLabel.attributedText = down.toAttributedString()
        return cell
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return data[section].title
    }
    
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
