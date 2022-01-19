//
//  RootRouter.swift
//  PlanShare
//
//  Created by JK on 2022/01/10.
//

import RIBs

// MARK: - RootInteractable

protocol RootInteractable: Interactable, HomeListener, EditingListener {
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
    homeBuilder: HomeBuildable)
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

  private func routeToHome() {
    let homeRouter = homeBuilder.build(withListener: interactor)
    attachChild(homeRouter)
    viewController.push(viewController: homeRouter.viewControllable, animated: false)
  }
}
