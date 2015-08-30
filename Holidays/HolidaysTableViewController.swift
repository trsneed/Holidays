//
//  HolidaysTableViewController.swift
//  MyHolidays
//
//  Created by Tim Sneed on 8/26/15.
//  Copyright (c) 2015 Sneed. All rights reserved.
//

import UIKit

enum ActionIdentifiers:String{
	case addToCalendarIdentifier = "addToCalendar"
	case moreInformationIdentifier = "moreInformation"
}

enum CategoryIdentifiers:String{
	case holidayCategory = "holidayCategory"
}

class HolidaysTableViewController: BaseHolidaysTableViewController {
	var holidays:[Holiday]?
    override func viewDidLoad() {
        super.viewDidLoad()
		self.title = "Holidays"
		let m = EventStoreHelper.sharedInstance
		configureBarButtons()
		if let countryCode = NSUserDefaults.standardUserDefaults().objectForKey(StorageKeys.selectedCounty.rawValue) as? String {
			getHolidays(countryCode, onCompletion: {})
		} else {
			presentChangeLocation()
		}
    }
	
	func getHolidays(countryCode:String, onCompletion:(((Void))->Void)){
		self.repository!.getHolidaysForCountry(countryCode, year: 2015, onCompletion: { (holidays) -> Void in
			self.holidays = holidays
			self.tableView.reloadData()
			onCompletion()
			//lets see if they are registered and ask if we can ask to register some notifications
			let settings = UIApplication.sharedApplication().currentUserNotificationSettings()
			if settings.types == UIUserNotificationType.None{
				self.showAlertToAskIfWeCanRegister()
			}
		})
	}
	
	func showAlertToAskIfWeCanRegister(){
		let alertController = UIAlertController(title: "Would you like to recieve notifications?", message: "To get the most out of Holidays, we would like to show you an occasional notification about the holidays on a given day. Is that ok?", preferredStyle: UIAlertControllerStyle.Alert)
		
		let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { (action) -> Void in
			self.registerForNotifications()
		}
		let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
		
		alertController.addAction(okAction)
		alertController.addAction(cancelAction)
		self.presentViewController(alertController, animated: true, completion: nil)
	}
	
	func registerForNotifications(){
		let notificationType = UIUserNotificationType.Alert | UIUserNotificationType.Badge | UIUserNotificationType.Sound
		
		let addToCalendarAction = UIMutableUserNotificationAction()
		addToCalendarAction.identifier = ActionIdentifiers.addToCalendarIdentifier.rawValue
		addToCalendarAction.title = "Add To Calendar"
		addToCalendarAction.activationMode = UIUserNotificationActivationMode.Background
		addToCalendarAction.destructive = false
		addToCalendarAction.authenticationRequired = false
		
		let moreInformationAction = UIMutableUserNotificationAction()
		moreInformationAction.identifier = ActionIdentifiers.moreInformationIdentifier.rawValue
		moreInformationAction.title = "More Info"
		moreInformationAction.activationMode = UIUserNotificationActivationMode.Background
		moreInformationAction.destructive = false
		moreInformationAction.authenticationRequired = true
		
		let actionCategory = UIMutableUserNotificationCategory()
		actionCategory.identifier = CategoryIdentifiers.holidayCategory.rawValue
		actionCategory.setActions([addToCalendarAction, moreInformationAction], forContext: .Default)
		actionCategory.setActions([addToCalendarAction, moreInformationAction], forContext: .Minimal)
		
		
		let settings = UIUserNotificationSettings(forTypes: notificationType, categories: [actionCategory])
		
		UIApplication.sharedApplication().registerUserNotificationSettings(settings)
	}
	
	func configureBarButtons(){
		let changeLocationButton = UIBarButtonItem(title: "Location", style: UIBarButtonItemStyle.Plain, target: self, action: "changeLocation:")
		self.navigationItem.rightBarButtonItem = changeLocationButton
	}
	
	func changeLocation(sender: UIBarButtonItem) {
		presentChangeLocation()
	}
	
	func presentChangeLocation(){
		let storyboard = self.storyboard!
		let vc = storyboard.instantiateViewControllerWithIdentifier("changeLocationViewController") as? UIViewController
		let navController = UINavigationController(rootViewController: vc!)
		self.navigationController?.presentViewController(navController, animated: true, completion: { () -> Void in
			NSNotificationCenter.defaultCenter().addObserver(self, selector: "countrySelected:", name: CountrySelectedNotification, object: nil)
		})
	}
	
	func countrySelected(notification:NSNotification){
		//janitor this notification right quick
		NSNotificationCenter.defaultCenter().removeObserver(self, name: CountrySelectedNotification, object: nil)
		if let countryCode = NSUserDefaults.standardUserDefaults().objectForKey(StorageKeys.selectedCounty.rawValue) as? String{
			getHolidays(countryCode, onCompletion: {})
		}
	}
	
	@IBAction func tableRefreshing(sender: AnyObject) {
		if let countryCode = NSUserDefaults.standardUserDefaults().objectForKey(StorageKeys.selectedCounty.rawValue) as? String{
			getHolidays(countryCode, onCompletion: { (complete) -> Void in
				self.refreshControl?.endRefreshing()
			})
		}
	}
	

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
		if let count = self.holidays?.count{
			return count
		}else{
			return 0
		}
    }

	override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return 70
	}
	
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
        let cell = tableView.dequeueReusableCellWithIdentifier("holidayTableViewCell") as! HolidayTableViewCell
		if self.holidays?.count > 0{
			let holiday = self.holidays![indexPath.row]
			cell.englishNameLabel.text = holiday.englishName
			cell.localNameLabel.text = holiday.localName
			cell.dateLabel.text = holiday.shortDate
		}
        return cell
    }
	
	override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
		let eventStore = EventStoreHelper.sharedInstance
		let holidayToActionUpon = self.holidays![indexPath.row]
		if eventStore.savedHolidays.allKeysForObject(holidayToActionUpon.keyToSaveToCalendar).count == 0{
		//alright lets tackle adding this to the calendar
			let addToCalendar = UITableViewRowAction(style: .Normal, title: "Add To Calendar") { action, index in
				eventStore.checkAccessToEventStore()
				if eventStore.hasAccess ?? false{
					eventStore.saveHolidayToEventStore(holidayToActionUpon)
				} else {
					self.showNoAccessMessage()
				}
				tableView.setEditing(false, animated: true)
			}
			addToCalendar.backgroundColor = UIColor.greenColor()
		
			return [addToCalendar]
		} else{
			let removeFromCalendar = UITableViewRowAction(style: .Normal, title: "Remove from Calendar") { action, index in
				eventStore.checkAccessToEventStore()
				if eventStore.hasAccess ?? false{
					eventStore.removeHolidayFromEventStore(holidayToActionUpon)
				} else {
					self.showNoAccessMessage()
				}
				tableView.setEditing(false, animated: true)
			}
			removeFromCalendar.backgroundColor = UIColor.redColor()
			
			return [removeFromCalendar]
		}
	}
	
	func showNoAccessMessage(){
		let alertView = UIAlertController(title: "Hmm, something went wrong",
			message: "Please make sure you have given 'Holidays' access to creating events in your calendar",
			preferredStyle: .Alert)
		let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
		alertView.addAction(okAction)
		self.presentViewController(alertView, animated: true, completion: nil)
	}
	override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		// the cells you would like the actions to appear needs to be editable
		return true
	}
	
	override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
		// you need to implement this method too or you can't swipe to display the actions
	}


    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
