//
//  ViewControllerRepresentable.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 08.07.22.
//

import UIKit
import SwiftUI

struct ViewControllerRepresentable: UIViewControllerRepresentable {

    let viewController: UIViewController

    public init(viewController: UIViewController) {
        self.viewController = viewController
    }

    func makeUIViewController(context: Context) -> some UIViewController {
        viewController
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) { }
}
