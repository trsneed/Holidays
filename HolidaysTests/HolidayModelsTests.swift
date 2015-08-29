//
//  HolidaysTests.swift
//  HolidaysTests
//
//  Created by Tim Sneed on 8/28/15.
//  Copyright (c) 2015 Sneed. All rights reserved.
//

import UIKit
import XCTest
import SwiftyJSON
import Holidays
class HolidayModelsTests: XCTestCase {
	var holiday:Holiday!
    override func setUp() {
        super.setUp()
		let jsonString = "{\"date\":{\"day\":2,\"month\":12,\"year\":2015,\"dayOfWeek\":4},\"localName\":\"Ano Novo\",\"englishName\":\"New Year's Day\"}"
		let dataFromString = jsonString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
		let json = JSON(data: dataFromString!)
		holiday = Holiday(jsonDict: json)
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
	func testHolidayHydrates(){
		XCTAssertEqual("Ano Novo", holiday.localName)
		XCTAssertEqual("New Year's Day", holiday.englishName)
	}
	
	func testHolidayDate(){
		let expectedDate = "12/02/2015"
		XCTAssertEqual(expectedDate, holiday.shortDate, "date not right")
	}
    
}
