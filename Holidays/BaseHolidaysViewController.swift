//
//  BaseHolidaysViewController.swift
//  Holidays
//
//  Created by Tim Sneed on 8/29/15.
//  Copyright (c) 2015 Sneed. All rights reserved.
//

import UIKit

class BaseHolidaysViewController: UIViewController {

	var repository:Repository?
	
    override func viewDidLoad() {
        super.viewDidLoad()
		repository = appDelegate().repository
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
