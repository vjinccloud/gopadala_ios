//
//  RelationTVC.swift
//  indogo
//
//  Created by Wang Jen Chung on 2023/4/15.
//  Copyright © 2023 DIM. All rights reserved.
//

import UIKit

class RelationTVC: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = Color_Purple
        self.selectedBackgroundView = selectedBackgroundView
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = Color_Purple
        self.selectedBackgroundView = selectedBackgroundView
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
