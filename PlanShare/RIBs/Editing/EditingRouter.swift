//
//  EditingRouter.swift
//  PlanShare
//
//  Created by JK on 2022/01/10.
//

import RIBs

// MARK: - EditingInteractable

protocol EditingInteractable: Interactable {
  var router: EditingRouting? { get set }
  var listener: EditingListener? { get set }
}

// MARK: - EditingViewControllable

protocol EditingViewControllable: ViewControllable {
  // TODO: Declare methods the router invokes to manipulate the view hierarchy.
}

// MARK: - EditingRouter

final class EditingRouter: ViewableRouter<EditingInteractable, EditingViewControllable>, EditingRouting {

  // TODO: Constructor inject child builder protocols to allow building children.
  override init(interactor: EditingInteractable, viewController: EditingViewControllable) {
    super.init(interactor: interactor, viewController: viewController)
    interactor.router = self
  }
}