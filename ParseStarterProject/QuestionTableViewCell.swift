//
//  QuestionTableViewCell.swift
//  Movement
//
//  Created by Zara Perumal on 11/9/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import Foundation
import UIKit

class QuestionTableViewCell : UITableViewCell {
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answerView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
