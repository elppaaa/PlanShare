//
//  HomeRouter.swift
//  PlanShare
//
//  Created by JK on 2022/01/10.
//

import RIBs

// MARK: - HomeInteractable

protocol HomeInteractable: Interactable {
  var router: HomeRouting? { get set }
  var listener: HomeListener? { get set }
}

// MARK: - HomeViewControllable

protocol HomeViewControllable: ViewControllable {
  // TODO: Declare methods the router invokes to manipulate the view hierarchy.
}

// MARK: - HomeRouter

final class HomeRouter: ViewableRouter<HomeInteractable, HomeViewControllable>, HomeRouting {

  // TODO: Constructor inject child builder protocols to allow building children.
  override init(interactor: HomeInteractable, viewController: HomeViewControllable) {
    super.init(interactor: interactor, viewController: viewController)
    interactor.router = self
  }
}
