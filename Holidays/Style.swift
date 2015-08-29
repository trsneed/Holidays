//
//  Style.swift
//  MyHolidays
//
//  Created by Tim Sneed on 8/27/15.
//  Copyright (c) 2015 Sneed. All rights reserved.
//

import UIKit

public class Style {
	let fontFamily = "HelveticaNeue-Light"
	let fontFamilySemiBold = "HelveticaNeue"
	let fontFamilyBold = "HelveticaNeue-Bold"
	let fontFamilyLight = "HelveticaNeue-UltraLight"
	
	func boldFontOfSize(size:CGFloat) -> UIFont {
		return UIFont(name:fontFamilyBold, size:size)!
	}
	func semiboldFontOfSize(size:CGFloat) -> UIFont {
		return UIFont(name:fontFamilySemiBold, size:size)!
	}
	func fontOfSize(size:CGFloat) -> UIFont {
		return UIFont(name:fontFamily, size:size)!
	}
	func lightFontOfSize(size:CGFloat) -> UIFont {
		return UIFont(name:fontFamilyLight, size:size)!
	}
}
