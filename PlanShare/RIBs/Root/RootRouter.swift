//
//  RootRouter.swift
//  PlanShare
//
//  Created by JK on 2022/01/10.
//

import Dispatch
import RIBs

// MARK: - RootInteractable

protocol RootInteractable: Interactable, HomeListener {
  var router: RootRouting? { get set }
  var listener: RootListener? { get set }
}

// MARK: - RootViewControllable

protocol RootViewControllable: ViewControllable {
  // TODO: Declare methods the router invokes to manipulate the view hierarchy.
  func push(viewController: ViewControllable, animated: Bool)
}

// MARK: - RootRouter

final class RootRouter: LaunchRouter<RootInteractable, RootViewControllable>, RootRouting {

  // MARK: Lifecycle

  init(
    interactor: RootInteractor,
    viewController: RootViewControllable,
    homeBuilder: HomeBuildable
  )
  {
    self.homeBuilder = homeBuilder
    super.init(interactor: interactor, viewController: viewController)
    interactor.router = self
  }

  // MARK: Internal

  override func didLoad() {
    super.didLoad()
    routeToHome()
  }

  // MARK: Private

  private let homeBuilder: HomeBuildable
  private var homeActionableItem: HomeActionableItem?

}

// MARK: - RootRouting

extension RootRouter {

  @discardableResult
  func routeToHome() -> HomeActionableItem {
    if let actionableItem = homeActionableItem {
      return actionableItem
    } else {
      let (homeRouter, actionableItem) = homeBuilder.build(withListener: interactor)
      attachChild(homeRouter)
      viewController.push(viewController: homeRouter.viewControllable, animated: true)
      homeActionableItem = actionableItem
      return actionableItem
    }
  }
}
