//
//  NotificationHelper.swift
//  MyHolidays
//
//  Created by Tim Sneed on 8/28/15.
//  Copyright (c) 2015 Sneed. All rights reserved.
//

import UIKit

class NotificationHelper: NSObject {
	class func sendNotification(holiday:Holiday){
		var localNotification: UILocalNotification = UILocalNotification()
		localNotification.category = CategoryIdentifiers.holidayCategory.rawValue
		localNotification.alertBody = "Just thought I'd let you know, today is \(holiday.englishName)"
		localNotification.fireDate = NSDate(timeIntervalSinceNow: 1)
		UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
	}
}
