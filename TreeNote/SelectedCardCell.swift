//
//  SelectedCardCell.swift
//  TreeNote
//
//  Created by Andrew Brown on 10/25/16.
//  Copyright © 2016 Andrew Brown. All rights reserved.
//

import UIKit
import Down

class SelectedCardCell: CardCell {
    
    @IBOutlet weak var rightBar: UIToolbar!
    @IBOutlet weak var bottomBar: UIToolbar!
    @IBOutlet weak var topBar: UIToolbar!
    @IBOutlet weak var addRightButton: UIBarButtonItem!
    
    @IBAction func addCellAbovePressed(_ sender: UIBarButtonItem) {
        delegate.addAboveButtonPressed(inCardCell: self)
    }
    
    @IBAction func addCellBelowPressed(_ sender: UIBarButtonItem) {
        delegate.addBelowButtonPressed(inCardCell: self)
    }
    
    @IBAction func addCellRightPressed(_ sender: UIBarButtonItem) {
        delegate.addRightButtonPressed(inCardCell: self)
    }
    
    @IBAction func closeButtonPressed(_ sender: UIBarButtonItem) {
        delegate.deleteButtonPressed(inCardCell: self)
    }
    
    @IBAction func editButtonPressed(_ sender: UIBarButtonItem) {
        delegate.editButtonPressed(inCardCell: self)
    }
    
    @IBOutlet weak var mainLabel: UILabel!
    
    override func setup(withCell cell: Cell) {
        rightBar.clipsToBounds = true
        bottomBar.clipsToBounds = true
        topBar.clipsToBounds = true
        if cell.children.count == 0 {
            addRightButton.isEnabled = true
        } else {
            addRightButton.isEnabled = false
        }
        let down =  Down(markdownString: cell.text)
        try? mainLabel.attributedText = down.toAttributedString()
        backgroundColor = UIColor.white
    }
}
