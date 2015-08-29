//
//  Country.swift
//  MyHolidays
//
//  Created by Tim Sneed on 8/26/15.
//  Copyright (c) 2015 Sneed. All rights reserved.
//

import UIKit
import SwiftyJSON
public struct Country {
	public let name:String
	public let countryCode:String
	
	public init(jsonDict:JSON){
		self.name =  jsonDict["fullName"].stringValue
		self.countryCode = jsonDict["countryCode"].stringValue
	}
}
