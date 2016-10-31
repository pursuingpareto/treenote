//
//  FormattingHelpCell.swift
//  TreeNote
//
//  Created by Andrew Brown on 10/28/16.
//  Copyright © 2016 Andrew Brown. All rights reserved.
//

import UIKit

class FormattingHelpCell: UITableViewCell {
    static let identifier = "formattingHelpCell"
    @IBOutlet weak var rawLabel: UILabel!
    @IBOutlet weak var renderedLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        rawLabel.numberOfLines = 0
        renderedLabel.numberOfLines = 0
    }
}
