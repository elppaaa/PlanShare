//
//  DetailPlanRouter.swift
//  PlanShare
//
//  Created by JK on 2022/01/19.
//

import CoreLocation
import RIBs

// MARK: - DetailPlanInteractable

protocol DetailPlanInteractable: Interactable, MarkedMapListener {
  var router: DetailPlanRouting? { get set }
  var listener: DetailPlanListener? { get set }
}

// MARK: - DetailPlanViewControllable

protocol DetailPlanViewControllable: ViewControllable {
  // TODO: Declare methods the router invokes to manipulate the view hierarchy.
}

// MARK: - DetailPlanRouter

final class DetailPlanRouter: ViewableRouter<DetailPlanInteractable, DetailPlanViewControllable>, DetailPlanRouting {

  // MARK: Lifecycle

  // TODO: Constructor inject child builder protocols to allow building children.
  init(
    interactor: DetailPlanInteractable,
    viewController: DetailPlanViewControllable,
    markedMapBuilder: MarkedMapBuildable
  ) {
    self.markedMapBuilder = markedMapBuilder
    super.init(interactor: interactor, viewController: viewController)
    interactor.router = self
  }

  // MARK: Private

  private let markedMapBuilder: MarkedMapBuildable

  private func pushChild(_ router: ViewableRouting) {
    viewController.push(viewController: router.viewControllable)
    attachChild(router)
  }
}

// MARK: - DetailPlanRouting

extension DetailPlanRouter {
  func routeToMarkedMap(location: CLLocationCoordinate2D) {
    let router = markedMapBuilder.build(withListener: interactor, location: location)

    pushChild(router)
  }
}
