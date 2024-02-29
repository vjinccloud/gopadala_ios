//
//  PayNewMainTableViewCell.swift
//  indogo
//
//  Created by mac on 2021/6/4.
//  Copyright © 2021 DIM. All rights reserved.
//

import UIKit

class PayNewMainTableViewCell: UITableViewCell {
    @IBOutlet weak var backV: UIView!
    @IBOutlet weak var logoImg: UIImageView!
    @IBOutlet weak var payTitleL: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        backV.layer.cornerRadius = 8
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
