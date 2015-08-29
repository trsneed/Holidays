//
//  ViewController.swift
//  MyHolidays
//
//  Created by Tim Sneed on 8/26/15.
//  Copyright (c) 2015 Sneed. All rights reserved.
//

import UIKit

class CountriesViewController: BaseHolidaysViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
	var countries:[Country]?
	var countriesSearchResults:Array<Country>?
	@IBOutlet weak var countriesTableView: UITableView!
	@IBOutlet weak var countriesSearchBar: UISearchBar!
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
		self.title = "Select a Location"
		configureBarButtons()
		countriesSearchBar.delegate = self
		countriesTableView.delegate = self
		countriesTableView.dataSource = self
		self.repository!.getCountries { (countries) -> Void in
			self.countries = countries
			if self.countries?.count > 0{
				self.countriesTableView.reloadData()
				self.countriesSearchBar.becomeFirstResponder()
			}
		}
    }
	
	func configureBarButtons(){
		let cancelButton = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancelButton:")
		if let countryCode = NSUserDefaults.standardUserDefaults().objectForKey(StorageKeys.selectedCounty.rawValue) as? String{
			cancelButton.enabled = true
			
		} else {
			cancelButton.enabled = false
		}
		self.navigationItem.leftBarButtonItem = cancelButton
	}
	
	func cancelButton(sender: UIBarButtonItem) {
		self.dismissViewControllerAnimated(true, completion: nil)
	}
	
	override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if self.countriesSearchBar.text != "" {
			return self.countriesSearchResults?.count ?? 0
		} else {
			return self.countries?.count ?? 0
		}
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		var cell = tableView.dequeueReusableCellWithIdentifier("countryCell") as! CountriesTableViewCell
		if self.countriesSearchBar.text != ""{
			let country = countriesSearchResults![indexPath.row]
			cell.countryLabel.text = country.name
		} else {
		let country = countries![indexPath.row]
		cell.countryLabel.text = country.name
		}
		return cell

	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		var country:Country
		if self.countriesSearchBar.text != "" {
			country = countriesSearchResults![indexPath.row]
		} else {
			country = countries![indexPath.row]
		}
		
		NSUserDefaults.standardUserDefaults().setObject(country.countryCode, forKey: StorageKeys.selectedCounty.rawValue)
		self.dismissViewControllerAnimated(true, completion: { () -> Void in
			NSNotificationCenter.defaultCenter().postNotificationName(CountrySelectedNotification, object: nil)
		})
	}

	func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
		filterContentForSearchText(searchText)
		self.countriesTableView.reloadData()
	}
	
	func filterContentForSearchText(searchText: String) {
		if self.countries == nil {
			self.countriesSearchResults = nil
			return
		}
		self.countriesSearchResults = self.countries!.filter({( aCountry: Country) -> Bool in
			return aCountry.name.lowercaseString.rangeOfString(searchText.lowercaseString) != nil
		})
	}
	
}
