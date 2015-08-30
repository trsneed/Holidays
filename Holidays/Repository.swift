//
//  Repository.swift
//  MyHolidays
//
//  Created by Tim Sneed on 8/26/15.
//  Copyright (c) 2015 Sneed. All rights reserved.
//

import UIKit
import SwiftyJSON

enum ActionType:String {
	case getCountries = "getSupportedCountries"
	case getPublicHolidaysForYear = "getPublicHolidaysForYear"
	case isPublicHoliday = "isPublicHoliday"
	case getPublicHolidaysForDateRange = "getPublicHolidaysForDateRange"
}

enum ParamType:String {
	case year = "year"
	case country = "country"
	case region = "region"
	case date = "date"
	case fromDate = "fromDate"
	case toDate = "toDate"
}
let apiRoot = "http://kayaposoft.com/enrico/json/v1.0/?"

let action = "action"
//getPublicHolidaysForYear&year=2013&country=est&region=
class Repository: NSObject {
	var dataFilePath: String?
	
	
	func getCountries(onCompletion:(([Country])->Void)){
		let dataAccess = DataAccess()
		let params = NSDictionary(object: ActionType.getCountries.rawValue, forKey: action)
		let url = NSURL(string: apiRoot + params.queryStringFromDictionary())!
		println(url)
		dataAccess.httpGet(NSMutableURLRequest(URL: url), callback: { (result, error) -> Void in
			if let error = error{
				//hmm
			} else {
				if let dataFromString = result.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
					let json = JSON(data: dataFromString)
					var returnedArray = Array<Country>()
					for (key: String, subJson: JSON) in json {
						returnedArray.append(Country(jsonDict: subJson))
					}
					onCompletion(returnedArray)
				}
			}
		})
	}
	
	func getHolidaysForCountry(countryCode:String, year:Int, onCompletion:(([Holiday]) -> Void)){
		
		//check if exists
		let filemgr = NSFileManager.defaultManager()
		let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
		
		let docsDir = dirPaths[0] as! String
		dataFilePath = docsDir.stringByAppendingPathComponent("\(countryCode)_data.archive")
		
		if filemgr.fileExistsAtPath(dataFilePath!) {
			
			let dataDictionary = NSKeyedUnarchiver.unarchiveObjectWithFile(dataFilePath!) as! NSDictionary
			let holidays = dataDictionary.objectForKey("\(countryCode)_\(year)") as? [Holiday]
			onCompletion(holidays!)
		} else{
		
		let dataAccess = DataAccess()
		let params = NSDictionary(objectsAndKeys: ActionType.getPublicHolidaysForYear.rawValue, action, "2015", ParamType.year.rawValue,
					countryCode, ParamType.country.rawValue)
		
		let url = NSURL(string: apiRoot + params.queryStringFromDictionary())!
		dataAccess.httpGet(NSMutableURLRequest(URL: url), callback: { (result, error) -> Void in
			if let error = error{
				//hmm
			} else {
				if let dataFromString = result.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
					let json = JSON(data: dataFromString)
					var returnedArray = Array<Holiday>()
					for (key: String, subJson: JSON) in json{
						returnedArray.append(Holiday(jsonDict: subJson, countryCode: countryCode))
					}
					let value = NSDictionary(objectsAndKeys: returnedArray, "\(countryCode)_\(year)")
					
					NSKeyedArchiver.archiveRootObject(value, toFile: self.dataFilePath!)
					onCompletion(returnedArray)
				}
			}
		})
		}
	}
	
	func checkIfHolidayAndRetrieveHoliday(countryCode:String, completionHandler: (UIBackgroundFetchResult) -> Void){
		
		//let params = NSDictionary(objectsAndKeys: ActionType.isPublicHoliday.rawValue, action, NSDate().stringForApi(), ParamType.date.rawValue,
		let params = NSDictionary(objectsAndKeys: ActionType.isPublicHoliday.rawValue, action, "25-12-2015", ParamType.date.rawValue,
			countryCode, ParamType.country.rawValue)
		let url = NSURL(string: apiRoot + params.queryStringFromDictionary())!
		let request = NSURLRequest(URL: url)
	
		BackgroundDataAccess.sharedInstance.performBackgroundRequest(request, success: { (result) -> Void in
			if let dataFromString = result.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
				let json = JSON(data: dataFromString)
				let isHoliday = json["isPublicHoliday"].boolValue
				if isHoliday{
					//make another call to get the holiday
					self.getTodaysHolidayAndScheduleNotification(countryCode, completionHandler: completionHandler)
				} else {
					completionHandler(UIBackgroundFetchResult.NewData)
				}
			} else {
				completionHandler(.NewData)
			}
		}) { (error) -> Void in
			completionHandler(UIBackgroundFetchResult.Failed)
		}
	}
	
	func getTodaysHolidayAndScheduleNotification(countryCode:String, completionHandler: (UIBackgroundFetchResult) -> Void){
//		let params = NSDictionary(objectsAndKeys: ActionType.getPublicHolidaysForDateRange.rawValue, action, NSDate().stringForApi(), ParamType.fromDate.rawValue,
//			NSDate().stringForApi(), ParamType.toDate.rawValue, countryCode, ParamType.country.rawValue)
		let params = NSDictionary(objectsAndKeys: ActionType.getPublicHolidaysForDateRange.rawValue, action, "25-12-2015", ParamType.fromDate.rawValue,
			"25-12-2015", ParamType.toDate.rawValue, countryCode, ParamType.country.rawValue)
		let url = NSURL(string: apiRoot + params.queryStringFromDictionary())!
		let request = NSURLRequest(URL: url)
		
		BackgroundDataAccess.sharedInstance.performBackgroundRequest(request, success: { (result) -> Void in
			if let dataFromString = result.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false){
				let json = JSON(data: dataFromString)
				for (key: String, subJson: JSON) in json{
					let holiday = Holiday(jsonDict: subJson, countryCode: countryCode)
					NotificationHelper.sendNotification(holiday)
				}
				completionHandler(.NewData)
			} else {
				completionHandler(.NewData)
			}
		}) { (error) -> Void in
			completionHandler(.Failed)
		}
	}
}


