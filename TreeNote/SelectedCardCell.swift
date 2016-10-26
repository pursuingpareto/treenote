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
    
    
    // TODO - implement all these methods through calls to delegate functions.
    @IBAction func addCellAbovePressed(_ sender: UIButton) {
        delegate.addAboveButtonPressed(inCardCell: self)
    }
    
    @IBAction func addCellBelowPressed(_ sender: UIButton) {
        delegate.addBelowButtonPressed(inCardCell: self)
    }
    
    @IBAction func addCellRightPressed(_ sender: UIButton) {
        delegate.addRightButtonPressed(inCardCell: self)
    }
    
    @IBAction func closeButtonPressed(_ sender: UIButton) {
        delegate.deleteButtonPressed(inCardCell: self)
    }
    
    @IBAction func editButtonPressed(_ sender: UIButton) {
        delegate.editButtonPressed(inCardCell: self)
    }
    
    @IBOutlet weak var mainLabel: UILabel!
    
    override func setup(withCell cell: Cell) {
        let down =  Down(markdownString: cell.text)
        try? mainLabel.attributedText = down.toAttributedString()
//        mainLabel.text = cell.text
        backgroundColor = UIColor.white
    }
}
