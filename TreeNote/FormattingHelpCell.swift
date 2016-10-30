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
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
