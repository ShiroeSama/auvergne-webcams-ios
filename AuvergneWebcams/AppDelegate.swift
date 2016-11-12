//
//  AppDelegate.swift
//  AuvergneWebcams
//
//  Created by Drusy on 07/11/2016.
//
//

import UIKit
import Kingfisher
import Siren

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Cache
        ImageCache.default.maxCachePeriodInSecond = Webcam.refreshInterval
        ImageCache.default.cleanExpiredDiskCache()
        
        // Update
        Siren.sharedInstance.alertType = .skip
        Siren.sharedInstance.checkVersion(checkType: .immediately)
        
        let webcamOverview = WebcamOverviewViewController()
        let navigationController = NavigationController(rootViewController: webcamOverview)
        
        // Setup Window
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        Siren.sharedInstance.checkVersion(checkType: .daily)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        Siren.sharedInstance.checkVersion(checkType: .daily)
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}
