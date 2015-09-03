//
//  EventStoreHelper.swift
//  Holidays
//
//  Created by Tim Sneed on 8/29/15.
//  Copyright (c) 2015 Sneed. All rights reserved.
//

import UIKit
import EventKit
class EventStoreHelper: NSObject {
	class var sharedInstance: EventStoreHelper {
		struct Static {
			static var instance : EventStoreHelper?
			static var token : dispatch_once_t = 0
		}
		
		dispatch_once(&Static.token) {
			Static.instance = EventStoreHelper()
		}
		
		return Static.instance!
	}
	var eventStore:EKEventStore?
	override init(){
		eventStore = EKEventStore()
	}
	
	var hasAccess:Bool?
	let calendarName = "Holidays"
	
	lazy var savedHolidays:NSMutableDictionary = {
		let docsDir = dirPaths[0] as! String
		let dataFilePath = docsDir.stringByAppendingPathComponent("saved_events_data.archive")
		var dataDictionary = NSMutableDictionary()
		if self.fileManager.fileExistsAtPath(dataFilePath) {
			dataDictionary = NSKeyedUnarchiver.unarchiveObjectWithFile(dataFilePath) as! NSMutableDictionary
		}
		return dataDictionary
	}()
	
	
	
	lazy var fileManager:NSFileManager = {
		return NSFileManager.defaultManager()
	}()
	
	private let calendarIdKey = "holidayCalendar"
	func checkAccessToEventStore() {
		let authStatus = EKEventStore.authorizationStatusForEntityType(EKEntityTypeEvent)
		switch authStatus{
		case .Denied, .Restricted:
			self.hasAccess = false
		case .Authorized:
			self.hasAccess = true
		case .NotDetermined:
			var status:EKAuthorizationStatus
			self.eventStore?.requestAccessToEntityType(EKEntityTypeEvent, completion: { (hasAccess, error) -> Void in
				if let error = error{
					self.hasAccess = false
					println("maybe send a notification to start")
				} else if hasAccess ?? false{
					self.hasAccess = false
				} else {
					self.hasAccess = true
				}
			})
		default:
			println("I got nothing")
		}
	}
	
	func saveHolidayToEventStore(holiday:Holiday, keepTrying:Bool = true){
		let calendars = eventStore!.calendarsForEntityType(EKEntityTypeEvent) as! [EKCalendar]
		let calendarId = NSUserDefaults.standardUserDefaults().objectForKey(calendarIdKey) as? String

		//find our calendar
		var calendar:EKCalendar?
		if let found = find(lazy(calendars).map({ $0.calendarIdentifier == calendarId}), true) {
			calendar = calendars[found]
		}
		
		if let calendar = calendar{
			let startDate = holiday.date
			var event = EKEvent(eventStore: self.eventStore)
			event.calendar = calendar
			event.allDay = true
			event.title = holiday.englishName
			event.startDate = holiday.date
			event.endDate = holiday.date
			var error: NSError?
			let result = eventStore!.saveEvent(event, span: EKSpanThisEvent, error: &error)
			if result == false {
				if let error = error {
					println("An error occured \(error)")
				}
			} else {
				self.saveEventAndResultToDisk(event.eventIdentifier, holidayNameKey: holiday.keyToSaveToCalendar)
			}
		} else {
			if keepTrying{
				createCalendar()
				//and recurse once :)
				self.saveHolidayToEventStore(holiday, keepTrying:false)
			}
		}

	}
	
	func removeHolidayFromEventStore(holiday:Holiday){
		let calendars = eventStore!.calendarsForEntityType(EKEntityTypeEvent) as! [EKCalendar]
		let calendarId = NSUserDefaults.standardUserDefaults().objectForKey(calendarIdKey) as? String
		
		//find our calendar
		var calendar:EKCalendar?
		if let found = find(lazy(calendars).map({ $0.calendarIdentifier == calendarId}), true) {
			calendar = calendars[found]
		}
		
		if let calendar = calendar{
			let eventKey = savedHolidays.allKeysForObject(holiday.keyToSaveToCalendar)
			var error: NSError?
			for key in eventKey{
				let event = eventStore?.eventWithIdentifier(key as! String)
				eventStore?.removeEvent(event, span: EKSpanThisEvent, commit: false, error: &error)
				savedHolidays.removeObjectForKey(key)
			}
			eventStore?.commit(&error)
			if let error = error {
				println("An error occured \(error)")
			} else {
				saveToDisk()
			}
		} else {
			println("uh-oh")
		}
	}
	
	private func createCalendar(){
		if let eventStore = self.eventStore{
			let appCalendar = EKCalendar(forEntityType: EKEntityTypeEvent, eventStore: eventStore)
			//set the name
			appCalendar.title = calendarName
			
			//get a local calendar type
			let sourcesInEventStore = eventStore.sources() as! [EKSource]
			//appCalendar.source =
			let sources = sourcesInEventStore.filter({
					(source: EKSource) -> Bool in
					source.sourceType.value == EKSourceTypeLocal.value  || (source.sourceType.value == EKSourceTypeCalDAV.value  && source.title.lowercaseString == "icloud")
					})
			
			for source in sources{
				if (appCalendar.source == nil && source.sourceType.value == EKSourceTypeLocal.value){
					appCalendar.source = source
				}
				
				if (source.sourceType.value == EKSourceTypeCalDAV.value && source.title.lowercaseString == "icloud"){
					if(source.calendarsForEntityType(EKEntityTypeEvent).count > 0){
						appCalendar.source = source
						break
					}
				}
			}
			
			//save that calendar
			var error: NSError? = nil
			let calendarWasSaved = eventStore.saveCalendar(appCalendar, commit: true, error: &error)
			
			if calendarWasSaved == false {
				//maybe a notification?
			} else {
				//save to user defaults, it is a default :)
				NSUserDefaults.standardUserDefaults().setValue(appCalendar.calendarIdentifier, forKey: calendarIdKey)
			}
		}
	}
	
	private func saveEventAndResultToDisk(eventID:String, holidayNameKey:String){
		savedHolidays[eventID] = holidayNameKey
		saveToDisk()
	}
	
	private func saveToDisk(){
		let docsDir = dirPaths[0] as! String
		let dataFilePath = docsDir.stringByAppendingPathComponent("saved_events_data.archive")
		NSKeyedArchiver.archiveRootObject(savedHolidays, toFile: dataFilePath)

	}
}
