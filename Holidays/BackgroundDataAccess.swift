//
//  BackgroundDataAccess.swift
//  MyHolidays
//
//  Created by Tim Sneed on 8/28/15.
//  Copyright (c) 2015 Sneed. All rights reserved.
//

import UIKit


struct SessionProperties {
	static let identifier : String! = "url_session_background_download"
}

typealias downloadTaskCompletionHandler = (NSURLSessionTask!,NSURL?,NSError?) -> Void


public class BackgroundDataAccess : NSObject, NSURLSessionDelegate, NSURLSessionDownloadDelegate {
	var backgroundTasks = [NSURLSessionTask:downloadTaskCompletionHandler]()
	class var sharedInstance: BackgroundDataAccess {
		struct Static {
			static var instance : BackgroundDataAccess?
			static var token : dispatch_once_t = 0
		}
		
		dispatch_once(&Static.token) {
			Static.instance = BackgroundDataAccess()
			Static.instance!.backgroundTasks = [NSURLSessionTask:downloadTaskCompletionHandler]()
		}
		
		return Static.instance!
	}
	
	public final func performBackgroundRequest(request:NSURLRequest, success:(String)->Void, failure:((NSError?) -> Void)?) -> Void {
		
		var configuration = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier(SessionProperties.identifier)
		var backgroundSession = NSURLSession(configuration: configuration, delegate: self, delegateQueue: nil)
		var downloadTask = backgroundSession.downloadTaskWithRequest(request)
		let completion:downloadTaskCompletionHandler = { task, dataFileUrl, error in
			self.backgroundTasks.removeValueForKey(task)
			if let error = error, failure = failure {
				dispatch_async(dispatch_get_main_queue(), { () -> Void in
					failure(error)
					return
				})
			} else {
				if let url = dataFileUrl, data = NSData(contentsOfURL: url) {
					let responseString = NSString(data: data, encoding: NSUTF8StringEncoding)
					
					dispatch_async(dispatch_get_main_queue()) {
						success(responseString as! String)
					}
				} else {
					success("")
				}
			}
		}
		
		self.backgroundTasks[downloadTask] = completion
		downloadTask.resume()
		
	}

	
	//MARK: session delegate
	public func URLSession(session: NSURLSession, didBecomeInvalidWithError error: NSError?) {
		println("session error: \(error?.localizedDescription).")
	}
	
	public func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
		if let completion = self.backgroundTasks.removeValueForKey(downloadTask) {
			completion(downloadTask, location, nil)
		}
		println("session \(session) has finished the download task \(downloadTask) of URL \(location).")
	}
	
	public func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
		println("session \(session) download task \(downloadTask) wrote an additional \(bytesWritten) bytes (total \(totalBytesWritten) bytes) out of an expected \(totalBytesExpectedToWrite) bytes.")
	}
	
	public func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
		println("session \(session) download task \(downloadTask) resumed at offset \(fileOffset) bytes out of an expected \(expectedTotalBytes) bytes.")
	}
	
	public func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
		if let completion = self.backgroundTasks.removeValueForKey(task) {
			completion(task, nil, error)
		}
		if error == nil {
			println("session \(session) download completed")
		} else {
			println("session \(session) download failed with error \(error?.localizedDescription)")
		}
	}
}

