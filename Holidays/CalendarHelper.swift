//
//  CalendarHelper.swift
//  MyHolidays
//
//  Created by Tim Sneed on 8/27/15.
//  Copyright (c) 2015 Sneed. All rights reserved.
//

import UIKit
import EventKit

class CalendarHelper: NSObject {
	class func addToCalendar(holiday:Holiday){
		let store = EKEventStore()
		store.requestAccessToEntityType(EKEntityTypeEvent) {(granted, error) in
			if !granted { return }
			var event = EKEvent(eventStore: store)
			event.title = "Event Title"
			event.startDate = NSDate() //today
			event.endDate = event.startDate.dateByAddingTimeInterval(60*60) //1 hour long meeting
			event.calendar = store.defaultCalendarForNewEvents
			var err: NSError?
			store.saveEvent(event, span: EKSpanThisEvent, commit: true, error: &err)
		}
	}
}
