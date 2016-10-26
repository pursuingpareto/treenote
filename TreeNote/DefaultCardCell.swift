//
//  DefaultCardCell.swift
//  TreeNote
//
//  Created by Andrew Brown on 10/25/16.
//  Copyright © 2016 Andrew Brown. All rights reserved.
//

import UIKit

class DefaultCardCell: CardCell {
    
    @IBOutlet weak var mainLabel: UILabel!
    
    override func setup(withCell cell: Cell) {
        mainLabel.text = cell.text
        switch cell.state {
        case .focused:
            backgroundColor = UIColor.white
        default:
            backgroundColor = UIColor.lightGray
        }
    }
}
