//
//  PlaceSelectingRouter.swift
//  PlanShare
//
//  Created by JK on 2022/01/19.
//

import RIBs

// MARK: - PlaceSelectingInteractable

protocol PlaceSelectingInteractable: Interactable {
  var router: PlaceSelectingRouting? { get set }
  var listener: PlaceSelectingListener? { get set }
}

// MARK: - PlaceSelectingViewControllable

protocol PlaceSelectingViewControllable: ViewControllable {
  // TODO: Declare methods the router invokes to manipulate the view hierarchy.
}

// MARK: - PlaceSelectingRouter

final class PlaceSelectingRouter: ViewableRouter<PlaceSelectingInteractable, PlaceSelectingViewControllable>, PlaceSelectingRouting {

  // TODO: Constructor inject child builder protocols to allow building children.
  override init(interactor: PlaceSelectingInteractable, viewController: PlaceSelectingViewControllable) {
    super.init(interactor: interactor, viewController: viewController)
    interactor.router = self
  }
}
