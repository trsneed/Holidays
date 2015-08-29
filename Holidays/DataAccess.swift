//
//  DataAccess.swift
//  MyHolidays
//
//  Created by Tim Sneed on 8/26/15.
//  Copyright (c) 2015 Sneed. All rights reserved.
//

import UIKit

public typealias CallbackBlock = (result: String, error: String?) -> ()

class DataAccess: NSObject, NSURLSessionDelegate, NSURLSessionTaskDelegate {
	private static var numberOfCallsToSetVisible = 0
	private static var outstandingTasks = [String:NSURLSessionTask]()
	
	
	var callback: CallbackBlock = {
		(resultString, error) -> Void in
		if error == nil {
			println(resultString)
		} else {
			println(error)
		}
	}
	
	private func setNetworkActivityIndicatorVisible(setVisible:Bool){
		if(setVisible){
			DataAccess.numberOfCallsToSetVisible += 1
			println("Number of Calls Incremented to: \(DataAccess.numberOfCallsToSetVisible)")
		} else {
			DataAccess.numberOfCallsToSetVisible -= 1
			println("Number of Calls Decremented to: \(DataAccess.numberOfCallsToSetVisible)")
		}
		
		println("Number of Calls: \(DataAccess.numberOfCallsToSetVisible)")
		UIApplication.sharedApplication().networkActivityIndicatorVisible = DataAccess.numberOfCallsToSetVisible > 0
	}
	
 
	func httpGet(request: NSMutableURLRequest!, callback: (String,
		String?) -> Void) {
			var configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
			var session = NSURLSession(configuration: configuration, delegate: self,
				delegateQueue:NSOperationQueue.mainQueue())
			var task = session.dataTaskWithRequest(request){
				(data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
				if error != nil {
					self.setNetworkActivityIndicatorVisible(false)
					callback("", error.localizedDescription)
				} else {
					var result = NSString(data: data, encoding:
						NSASCIIStringEncoding)!
					callback(result as String, nil)
					self.setNetworkActivityIndicatorVisible(false)
				}
			}
			setNetworkActivityIndicatorVisible(true)
			task.resume()
	}
	
	func URLSession(session: NSURLSession,
		task: NSURLSessionTask,
		willPerformHTTPRedirection response:
		NSHTTPURLResponse,
		newRequest request: NSURLRequest,
		completionHandler: (NSURLRequest!) -> Void) {
			var newRequest : NSURLRequest? = request
			println(newRequest?.description);
			completionHandler(newRequest)
	}
}
