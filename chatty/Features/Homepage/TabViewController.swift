//
//  TabViewController.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 08.07.22.
//

import UIKit
import SwiftUI
import ComposableArchitecture
import Combine

class TabViewController: UITabBarController {

    let store: StoreOf<AppCore>
    let viewStore: ViewStoreOf<AppCore>
    var cancellables = Set<AnyCancellable>()

    let feedView: FeedView
    let entryView: EntryView

    init(store: StoreOf<AppCore>) {
        self.store = store
        self.viewStore = ViewStore(store)

        self.feedView = FeedView(
            store: store.scope(
                state: \.feed,
                action: AppCore.Action.feed
            )
        )

        self.entryView = EntryView(
            store: store.scope(
                state: \.entry,
                action: AppCore.Action.entry
            )
        )

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        viewStore.send(.onAppear)

        viewStore.publisher.accountState.sink { [self] accountState in
            if case let .loaded(account) = accountState {
                account == nil ? pushViewController(with: entryView) : dismiss(animated: true)
            }
        }.store(in: &cancellables)

        viewStore.publisher.showFeed.sink { showFeed in
            if showFeed {
                self.popViewController()
            }
        }.store(in: &cancellables)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setCoreViewController()
    }

    private func setCoreViewController() {
        let viewController = UIHostingController(
            rootView: feedView
        )
        let feedViewTabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "house.fill"), tag: 0)
        viewController.tabBarItem = feedViewTabBarItem

        let accountViewController = UIHostingController(rootView: AccountView())
        let accountViewTabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "person.fill"), tag: 1)
        accountViewController.tabBarItem = accountViewTabBarItem

        setViewControllers([viewController, accountViewController], animated: true)
    }

    private func pushViewController(with view: some View) {
        let viewController = UIHostingController(
            rootView: view
                .navigationBarHidden(true)
        )

        viewController.hidesBottomBarWhenPushed = true

        addPushTransitionToNavigationController()

        navigationController?.pushViewController(viewController, animated: false)

        print("EBU: ")
    }

    private func popViewController() {
        addPopTransitionToNavigationController()

        _ = navigationController?.popViewController(animated: false)
    }

    private func addPushTransitionToNavigationController() {
        let transition = CATransition()
        transition.duration = 0.25
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.moveIn
        transition.subtype = CATransitionSubtype.fromTop

        navigationController?.view.layer.add(transition, forKey: kCATransition)
    }

    private func addPopTransitionToNavigationController() {
        let transition = CATransition()
        transition.duration = 0.25
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.reveal
        transition.subtype = CATransitionSubtype.fromBottom

        navigationController?.view.layer.add(transition, forKey: kCATransition)
    }
}
