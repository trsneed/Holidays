//
//  Helpers.swift
//  MyHolidays
//
//  Created by Tim Sneed on 8/26/15.
//  Copyright (c) 2015 Sneed. All rights reserved.
//

import UIKit


//public typealias JSONDictionary = [String:AnyObject]

enum StorageKeys:String{
	case selectedCounty = "selectedCountry"
}

let CountrySelectedNotification:String = "CountrySelected"

public class Helpers: NSObject {
	
	public static let style = Style()

	public class func dateFromValues(#year:Int, month:Int, day:Int) -> NSDate {
		var c = NSDateComponents()
		c.year = year
		c.month = month
		c.day = day
		
		var gregorian = NSCalendar(identifier:NSCalendarIdentifierGregorian)
		var date = gregorian!.dateFromComponents(c)
		return date!
	}
}
