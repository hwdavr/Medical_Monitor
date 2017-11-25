//
//  MMTableViewCell.swift
//  MedicalMonitor
//
//  Created by Weidian on 9/8/17.
//  Copyright © 2017 talengineer. All rights reserved.
//

import UIKit

class MMTableViewCell: UITableViewCell {

    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var channelName: UILabel!
    @IBOutlet weak var value: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
