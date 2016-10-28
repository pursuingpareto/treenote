//
//  DefaultCardCell.swift
//  TreeNote
//
//  Created by Andrew Brown on 10/25/16.
//  Copyright © 2016 Andrew Brown. All rights reserved.
//

import UIKit
import Down

class DefaultCardCell: CardCell {
    
    @IBOutlet weak var mainLabel: UILabel!
    
    override func setup(withCell cell: Cell) {
        let down =  Down(markdownString: cell.text)
        try? mainLabel.attributedText = down.toAttributedString()
//        mainLabel.text = cell.text
        switch cell.state {
        case .focused:
            backgroundColor = UIColor.white
        default:
            backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        }
    }
}
