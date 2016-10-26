//
//  EditingCardCell.swift
//  TreeNote
//
//  Created by Andrew Brown on 10/25/16.
//  Copyright © 2016 Andrew Brown. All rights reserved.
//

import UIKit

class EditingCardCell: CardCell {
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        // TODO - implement by calling delegate method.
        delegate.doneEditingButtonPressed(inCardCell: self)
    }
    
    @IBAction func formattingHelpPressed(_ sender: UIButton) {
        // TODO - implement as modal
        delegate.formattingHelpButtonPressed(inCardCell: self)
    }
    
    @IBOutlet weak var markdownTextView: UITextView!
    
    override func setup(withCell cell: Cell) {
        markdownTextView.text = cell.text
        markdownTextView.delegate = self
        backgroundColor = UIColor.white
        layer.borderColor = UIColor.primaryColor.cgColor
        layer.borderWidth = 5.0
        layer.cornerRadius = 4.0
    }
}

extension EditingCardCell: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        self.delegate.didEndEditing(textView: textView, inCardCell: self)
    }
}
