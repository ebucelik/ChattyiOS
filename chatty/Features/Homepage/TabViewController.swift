//
//  TabViewController.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 08.07.22.
//

import UIKit
import SwiftUI

class TabViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setViewController()
    }

    func setViewController() {
        let feedViewController = UIHostingController(rootView: FeedView())
        let accountViewController = UIHostingController(rootView: AccountView())

        setViewControllers([feedViewController, accountViewController], animated: true)
    }
}
