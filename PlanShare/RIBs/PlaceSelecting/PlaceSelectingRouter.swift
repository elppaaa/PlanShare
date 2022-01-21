//
//  PlaceSelectingRouter.swift
//  PlanShare
//
//  Created by JK on 2022/01/19.
//

import CoreLocation
import RIBs

// MARK: - PlaceSelectingInteractable

protocol PlaceSelectingInteractable: Interactable, MarkedMapListener {
  var router: PlaceSelectingRouting? { get set }
  var listener: PlaceSelectingListener? { get set }
}

// MARK: - PlaceSelectingViewControllable

protocol PlaceSelectingViewControllable: ViewControllable {
  // TODO: Declare methods the router invokes to manipulate the view hierarchy.
}

// MARK: - PlaceSelectingRouter

final class PlaceSelectingRouter: ViewableRouter<PlaceSelectingInteractable, PlaceSelectingViewControllable>, PlaceSelectingRouting {

  // MARK: Lifecycle

  // TODO: Constructor inject child builder protocols to allow building children.
  init(
    interactor: PlaceSelectingInteractable,
    viewController: PlaceSelectingViewControllable,
    markedMapBuilder: MarkedMapBuildable
  ) {
    self.markedMapBuilder = markedMapBuilder
    super.init(interactor: interactor, viewController: viewController)
    interactor.router = self
  }

  // MARK: Private

  private let markedMapBuilder: MarkedMapBuildable
}

// MARK: - PlaceSelectingRouting

extension PlaceSelectingRouter {
  func routeToMarkedMap(location: CLLocationCoordinate2D) {
    let router = markedMapBuilder.build(withListener: interactor, location: location)

    viewController.push(viewController: router.viewControllable)
    attachChild(router)
  }
}
