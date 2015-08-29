//
//  Extensions.swift
//  MyHolidays
//
//  Created by Tim Sneed on 8/27/15.
//  Copyright (c) 2015 Sneed. All rights reserved.
//

import UIKit

extension UIViewController {
	func appDelegate()->AppDelegate{
		return UIApplication.sharedApplication().delegate as! AppDelegate
	}
}

extension NSDate{
	public func stringForApi() -> String{
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat =  NSDateFormatter.dateFormatFromTemplate("ddMMYYYY", options: 0, locale: NSLocale(localeIdentifier: "en_GB"))
		let dateString = dateFormatter.stringFromDate(self)
		return String(map(dateString.generate()) {
				$0 == "/" ? "-" : $0
			})
	}
}

extension NSDictionary{
	public func queryStringFromDictionary() -> String {
		if (self.count > 0) {
			var qs = ""
			var index = 0
		
			for (key, value) in self {
				var stringValue = "\(value)"
			
				let encodedK = key.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
				let encodedV = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
			
				if index++ > 0 { qs += "&" }
				qs += "\(encodedK!)=\(encodedV!)"
			}
		
			return qs
		} else {
			return ""
		}
	}
}