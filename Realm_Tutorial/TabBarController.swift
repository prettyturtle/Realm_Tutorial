//
//  TabBarController.swift
//  Realm_Tutorial
//
//  Created by yc on 2023/02/22.
//

import UIKit

final class TabBarController: UITabBarController {
    let realmVC = UINavigationController(rootViewController: RealmViewController())
    let realmTVC = UINavigationController(rootViewController: RealmTableViewController())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        realmVC.tabBarItem = UITabBarItem(
            title: "Realm",
            image: UIImage(systemName: "figure.stand"),
            selectedImage: UIImage(systemName: "figure.wave")
        )
        realmTVC.tabBarItem = UITabBarItem(
            title: "Realm TVC",
            image: UIImage(systemName: "shippingbox"),
            selectedImage: UIImage(systemName: "shippingbox.fill")
        )
        
        viewControllers = [realmVC, realmTVC]
        selectedIndex = 1
    }
}
