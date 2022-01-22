//
//  EditingRouter.swift
//  PlanShare
//
//  Created by JK on 2022/01/10.
//

import Foundation
import RIBs

// MARK: - EditingInteractable

protocol EditingInteractable: Interactable, PlaceSelectingListener {
  var router: EditingRouting? { get set }
  var listener: EditingListener? { get set }
}

// MARK: - EditingViewControllable

protocol EditingViewControllable: ViewControllable {
  // TODO: Declare methods the router invokes to manipulate the view hierarchy.
}

// MARK: - EditingRouter

final class EditingRouter: ViewableRouter<EditingInteractable, EditingViewControllable>, EditingRouting {

  // MARK: Lifecycle

  // TODO: Constructor inject child builder protocols to allow building children.
  init(
    interactor: EditingInteractable,
    viewController: EditingViewControllable,
    placeSelectingBuilder: PlaceSelectingBuildable
  ) {
    self.placeSelectingBuilder = placeSelectingBuilder
    super.init(interactor: interactor, viewController: viewController)
    interactor.router = self
  }

  // MARK: Private

  private let placeSelectingBuilder: PlaceSelectingBuildable
}

// MARK: - EditingRouting

extension EditingRouter {
  func routeToPlace() {
    let router = placeSelectingBuilder.build(withListener: interactor)
    viewController.push(viewController: router.viewControllable)
    attachChild(router)
  }

  func popAndDetach() {
    viewController.pop()
    detachCurrentChild()
  }
}
