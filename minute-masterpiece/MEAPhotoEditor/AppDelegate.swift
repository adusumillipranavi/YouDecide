//
//  AppDelegate.swift
//  MEAPhotoEditor
//
//  Created by Pranavi Adusumilli  on 10/19/16.
//  Copyright © 2016 MeaMobile. All rights reserved.
//

import UIKit
import mea_photokit
import Firebase
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		Fabric.with([Crashlytics.self])
		let path = Bundle.main.path(forResource: "SourceKeys", ofType: "plist")!
		let keys = NSDictionary(contentsOfFile: path) as! [String: AnyObject]
		
		let sources = MPKCollectionTypeLocal | MPKCollectionTypeFacebook | MPKCollectionTypeInstagram | MPKCollectionTypeFlickr 
		MEAPhotoKit.setupPhotoKit(withSources: UInt(sources), andSourceKeys: keys)
        FIRApp.configure()
        GADMobileAds.configure(withApplicationID: "ca-app-pub-8189404576936801~3821855905");
		return true
        
	}
	
	
	func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
		let source = options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String
		let annotation = options[UIApplicationOpenURLOptionsKey.annotation]
		return MEAPhotoKit.handle(app, open: url, sourceApplication: source, annotation: annotation)
	}


}

