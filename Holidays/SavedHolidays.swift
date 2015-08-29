//
//  SavedHolidays.swift
//  Holidays
//
//  Created by Tim Sneed on 8/29/15.
//  Copyright (c) 2015 Sneed. All rights reserved.
//

import UIKit
let calendarId = "calendarId"
final class SavedHolidays: NSObject, NSCoding {
	let calendarId:String
	
	init(calendarIdentifier:String){
		self.calendarId = calendarIdentifier
	}
	
	required init(coder aDecoder: NSCoder){
		self.calendarId = aDecoder.decodeObjectForKey(calendarId) as! String
	}
	func encodeWithCoder(aCoder: NSCoder) {
		aCoder.encodeObject(self.calendarId, forKey: calendarId)
	}
}