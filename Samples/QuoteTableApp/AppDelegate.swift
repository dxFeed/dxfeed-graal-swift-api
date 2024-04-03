//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import UIKit
import DXFeedFramework

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        UIButton.appearance().tintColor = .text
//        var thread: Thread? = Thread {
//            var endpoint = try? DXEndpoint.create()
//            print("execute1 in new thread \(pthread_mach_thread_np(pthread_self()))")
//            try? SystemProperty.setProperty("test", "test")
//            try? SystemProperty.setProperty("test", "test")
//
////            while(true) {
////                Thread.sleep(forTimeInterval: 0.1)
////            }
//        }
//        thread?.start()
//        thread = nil
//        Thread.sleep(forTimeInterval: 0.1)
////        var thread2: Thread? = Thread {
////            print("execute2 in new thread \(pthread_mach_thread_np(pthread_self()))")
////            _ = try? DXEndpoint.create()
////        }
////        thread2?.start()
////        thread2 = nil
////        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication,
                     didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {}
}
