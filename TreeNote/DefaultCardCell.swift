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
        switch cell.state {
        case .focused:
            backgroundColor = UIColor.white
        default:
            backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        }
    }
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return false
    }
}
