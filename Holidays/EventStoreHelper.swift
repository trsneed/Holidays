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
}
