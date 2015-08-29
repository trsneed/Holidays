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
	//	self.init()
		eventStore = EKEventStore()
		//lets go ahead and call this
		//self.checkAccessToEventStore()
	}
	
	var hasAccess:Bool?
	
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

}
