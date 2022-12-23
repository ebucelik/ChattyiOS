//
//  TabViewController.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 08.07.22.
//

import UIKit
import SwiftUI
import ComposableArchitecture

class TabViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setViewController()
    }

    func setViewController() {
        let feedViewController = UIHostingController(
            rootView: FeedView(
                store: Store(
                    initialState: FeedCore.State(),
                    reducer: FeedCore()
                )
            )
        )
        let feedViewTabBarItem = UITabBarItem(title: "Startpage", image: UIImage(systemName: "house.fill"), tag: 0)

        feedViewController.tabBarItem = feedViewTabBarItem

        let accountViewController = UIHostingController(rootView: AccountView())
        let accountViewTabBarItem = UITabBarItem(title: "Account", image: UIImage(systemName: "person.fill"), tag: 1)
        accountViewController.tabBarItem = accountViewTabBarItem

        setViewControllers([feedViewController, accountViewController], animated: true)
    }
}
