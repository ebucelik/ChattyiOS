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
    let searchView: SearchView
    let accountView: AccountView
    let entryView: EntryView

    let loadingView: UIHostingController<LoadingView> = {
        let loadingView = UIHostingController(rootView: LoadingView(fullScreen: true))
        loadingView.view.translatesAutoresizingMaskIntoConstraints = false
        loadingView.view.isHidden = true
        return loadingView
    }()

    let errorView: UIHostingController<ErrorView> = {
        let errorView = UIHostingController(rootView: ErrorView())
        errorView.view.translatesAutoresizingMaskIntoConstraints = false
        errorView.view.isHidden = true
        return errorView
    }()

    init(store: StoreOf<AppCore>) {
        self.store = store
        self.viewStore = ViewStore(store)

        self.feedView = FeedView(
            store: store.scope(
                state: \.feed,
                action: AppCore.Action.feed
            )
        )

        self.searchView = SearchView(
            store: store.scope(
                state: \.search,
                action: AppCore.Action.search
            )
        )

        self.accountView = AccountView(
            store: store.scope(
                state: \.account,
                action: AppCore.Action.account
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

        setupView()

        setConstraints()

        viewStore.send(.onAppear)

        viewStore.publisher.accountState.sink { [self] accountState in
            switch accountState {
            case .loading, .refreshing, .none:
                loadingView.view.isHidden = false
                errorView.view.isHidden = true

            case let .loaded(account):
                loadingView.view.isHidden = true
                errorView.view.isHidden = true

                if account == nil {
                    pushViewController(with: entryView)
                }

            case .error:
                loadingView.view.isHidden = true
                errorView.view.isHidden = false

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

    private func setupView() {
        view.addSubview(loadingView.view)
        view.addSubview(errorView.view)
    }

    private func setConstraints() {
        NSLayoutConstraint.activate([
            loadingView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingView.view.topAnchor.constraint(equalTo: view.topAnchor),
            loadingView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            errorView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            errorView.view.topAnchor.constraint(equalTo: view.topAnchor),
            errorView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            errorView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setCoreViewController() {
        let viewController = UIHostingController(
            rootView: feedView
                .navigationBarHidden(true)
        )
        let feedViewTabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "house.fill"), tag: 0)
        viewController.tabBarItem = feedViewTabBarItem

        let searchViewController = UIHostingController(
            rootView: searchView
                .navigationBarHidden(true)
        )
        let searchViewTabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "magnifyingglass"), tag: 1)
        searchViewController.tabBarItem = searchViewTabBarItem

        let accountViewController = UIHostingController(
            rootView: accountView
                .navigationBarHidden(true)
        )
        let accountViewTabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "person.fill"), tag: 2)
        accountViewController.tabBarItem = accountViewTabBarItem

        setViewControllers(
            [
                viewController,
                searchViewController,
                accountViewController
            ],
            animated: true
        )
    }

    private func pushViewController(with view: some View) {
        let viewController = UIHostingController(
            rootView: view
                .navigationBarHidden(true)
        )

        viewController.hidesBottomBarWhenPushed = true

        addPushTransitionToNavigationController()

        navigationController?.pushViewController(viewController, animated: false)
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
