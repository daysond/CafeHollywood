//
//  SceneDelegate.swift
//  HYSOR
//
//  Created by Dayson Dong on 2020-03-11.
//  Copyright © 2020 Dayson Dong. All rights reserved.
//

import UIKit
import Firebase

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        NotificationCenter.default.addObserver(self, selector: #selector(SceneDelegate.changeRootViewController(_:)), name: .authStateDidChange, object: nil)
        
        window = UIWindow(frame: UIScreen.main.bounds)
        let main = Auth.auth().currentUser == nil ? UINavigationController(rootViewController: AuthHomeViewController()) : MainTabBarViewController()
//        let main = Auth.auth().currentUser == nil ? AuthHomeViewController()  : MainTabBarViewController()
//        let main = AuthHomeViewController()
//        print(Auth.auth().currentUser?.email)
        window?.rootViewController = main
        window?.makeKeyAndVisible()
        window?.windowScene = windowScene
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        NetworkManager.shared.addTableListener()
       
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
      
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
     
    }
    
    
    
    
    @objc func changeRootViewController(_ notification: Notification) {
        
        if let data = notification.userInfo as? [String: Any], let isAuth = data["isAuth"] as? Bool {
            
            if isAuth {
                
                window?.rootViewController = MainTabBarViewController()
                
            } else {
                
                window?.rootViewController = UINavigationController(rootViewController: AuthHomeViewController())
                
            }
            
            
        }
        
        
    }


}

