//
//  Cell.swift
//  On the Map
//
//  Created by Nehal Jhala on 8/16/21.
//

import UIKit

class Cell: UITableViewCell {

    @IBOutlet weak var loginPinButton: UIButton!
    @IBOutlet weak var label1: UILabel!    
    @IBOutlet weak var label2: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
