//
//  BaseHolidaysTableViewController.swift
//  Holidays
//
//  Created by Tim Sneed on 8/29/15.
//  Copyright (c) 2015 Sneed. All rights reserved.
//

import UIKit

class BaseHolidaysTableViewController: UITableViewController {

	var repository:Repository?
	
    override func viewDidLoad() {
        super.viewDidLoad()
		repository = appDelegate().repository
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
