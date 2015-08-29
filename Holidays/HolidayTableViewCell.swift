//
//  HolidayTableViewCell.swift
//  MyHolidays
//
//  Created by Tim Sneed on 8/27/15.
//  Copyright (c) 2015 Sneed. All rights reserved.
//

import UIKit

class HolidayTableViewCell: UITableViewCell {

	@IBOutlet weak var dateLabel: UILabel!
	@IBOutlet weak var englishNameLabel: UILabel!
	@IBOutlet weak var localNameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
		self.selectionStyle = .None
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
      //  super.setSelected(selected, animated: animated)
		//do nothing
        // Configure the view for the selected state
    }

}
