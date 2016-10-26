//
//  CardCell.swift
//  TreeNote
//
//  Created by Andrew Brown on 10/25/16.
//  Copyright © 2016 Andrew Brown. All rights reserved.
//

import UIKit

class CardCell: UITableViewCell {
    var delegate: CardCellDelegate!
    func setup(withCell cell: Cell) {
        fatalError("Must override setup(withCell:)")
    }
}
