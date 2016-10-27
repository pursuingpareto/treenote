//
//  CardCellDelegate.swift
//  TreeNote
//
//  Created by Andrew Brown on 10/25/16.
//  Copyright © 2016 Andrew Brown. All rights reserved.
//

import UIKit

protocol CardCellDelegate {
    func editButtonPressed(inCardCell cardCell: SelectedCardCell)
    func deleteButtonPressed(inCardCell cardCell: SelectedCardCell)
    func didEndEditing(textView: UITextView, inCardCell cardCell: EditingCardCell)
    func addBelowButtonPressed(inCardCell cardCell: SelectedCardCell)
    func addAboveButtonPressed(inCardCell cardCell: SelectedCardCell)
    func addRightButtonPressed(inCardCell cardCell: SelectedCardCell)
    func doneEditingButtonPressed(inCardCell cardCell: EditingCardCell)
    func formattingHelpButtonPressed(inCardCell cardCell: CardCell) 
}
