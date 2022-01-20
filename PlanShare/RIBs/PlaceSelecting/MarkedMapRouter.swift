//
//  MarkedMapRouter.swift
//  PlanShare
//
//  Created by JK on 2022/01/21.
//

import RIBs

// MARK: - MarkedMapInteractable

protocol MarkedMapInteractable: Interactable {
  var router: MarkedMapRouting? { get set }
  var listener: MarkedMapListener? { get set }
}

// MARK: - MarkedMapViewControllable

protocol MarkedMapViewControllable: ViewControllable {
  // TODO: Declare methods the router invokes to manipulate the view hierarchy.
}

// MARK: - MarkedMapRouter

final class MarkedMapRouter: ViewableRouter<MarkedMapInteractable, MarkedMapViewControllable>, MarkedMapRouting {

  // TODO: Constructor inject child builder protocols to allow building children.
  override init(interactor: MarkedMapInteractable, viewController: MarkedMapViewControllable) {
    super.init(interactor: interactor, viewController: viewController)
    interactor.router = self
  }
}
