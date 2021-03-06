//
//  SavedHolidays.swift
//  Holidays
//
//  Created by Tim Sneed on 8/29/15.
//  Copyright (c) 2015 Sneed. All rights reserved.
//

import UIKit

let calendarIdKey = "calendarIdKey"
let holidayNameKey = "holidayNameKey"

final class SavedHolidays: NSObject, NSCoding {
	let calendarId:String
	//let holidayNameCondensed:String
	init(calendarIdentifier:String, holiday:Holiday){
		self.calendarId = calendarIdentifier
		
	}
	
	//MARK: NSCoding
	
	required init(coder aDecoder: NSCoder) {
		self.calendarId = aDecoder.decodeObjectForKey(calendarIdKey) as! String
	}
	
	func encodeWithCoder(aCoder: NSCoder) {
		aCoder.encodeObject(self.calendarId, forKey: calendarId)
	}
}
