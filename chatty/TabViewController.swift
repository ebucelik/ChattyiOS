//
//  TabViewController.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 08.07.22.
//

import UIKit

class TabViewController: UITabBarController {

    override func viewDidLoad() {
        let test1 = UIViewController()
        let test2 = UIViewController()
        test1.view.backgroundColor = .red
        test2.view.backgroundColor = .yellow
        viewControllers = [test1, test2]
    }
}
