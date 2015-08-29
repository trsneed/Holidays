//
//  Holiday.swift
//  MyHolidays
//
//  Created by Tim Sneed on 8/26/15.
//  Copyright (c) 2015 Sneed. All rights reserved.
//

import UIKit
import SwiftyJSON

enum HolidayKeys:String{
	case dateKey = "date"
	case localNameKey = "localName"
	case englishNameKey = "englishNameKey"
}

public class Holiday: NSObject, NSCoding {
	public let date:NSDate
	public let localName:String
	public let englishName:String
	public lazy var shortDate:String = {
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat =  NSDateFormatter.dateFormatFromTemplate("MMddyyyy", options: 0, locale: NSLocale.currentLocale())
		return dateFormatter.stringFromDate(self.date)
	}()
	
	public init(jsonDict:JSON){
		localName = jsonDict["localName"].stringValue
		englishName = jsonDict["englishName"].stringValue
		let day = jsonDict["date"]["day"].intValue
		let month = jsonDict["date"]["month"].intValue
		let year = jsonDict["date"]["year"].intValue
		date = Helpers.dateFromValues(year: year, month: month, day: day)
	}
	
	//MARK: NSCoding
	
	public required init(coder aDecoder: NSCoder) {
		self.date = aDecoder.decodeObjectForKey(HolidayKeys.dateKey.rawValue) as! NSDate
		self.localName = aDecoder.decodeObjectForKey(HolidayKeys.localNameKey.rawValue) as! String
		self.englishName = aDecoder.decodeObjectForKey(HolidayKeys.englishNameKey.rawValue) as! String
	}
	
	public func encodeWithCoder(aCoder: NSCoder) {
		aCoder.encodeObject(self.date, forKey: HolidayKeys.dateKey.rawValue)
		aCoder.encodeObject(self.localName, forKey: HolidayKeys.localNameKey.rawValue)
		aCoder.encodeObject(self.englishName, forKey: HolidayKeys.englishNameKey.rawValue)
	}
}
