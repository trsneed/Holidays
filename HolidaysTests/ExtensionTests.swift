//
//  ExtensionTests.swift
//  Holidays
//
//  Created by Tim Sneed on 8/29/15.
//  Copyright (c) 2015 Sneed. All rights reserved.
//

import UIKit
import XCTest
import Holidays
class ExtensionTests: XCTestCase {
	func testStringForApiFormatsCorrectly(){
		let date = NSDate(timeIntervalSince1970: 1440812694)
		XCTAssertEqual("28-08-2015", date.stringForApi(), "Date must equal 28-08-2015")
	}
	
	func testQueryStringForDictionaryWorks(){
		let dictionary = NSDictionary(objectsAndKeys: "myValue", "myKey", "myOtherParameterValue", "myOtherParameterKey")
		let expectedString = "myKey=myValue&myOtherParameterKey=myOtherParameterValue"
		XCTAssertEqual(expectedString, dictionary.queryStringFromDictionary(), "Values Must Match")
	}
}
