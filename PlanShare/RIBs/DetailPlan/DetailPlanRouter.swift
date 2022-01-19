//
//  DetailPlanRouter.swift
//  PlanShare
//
//  Created by JK on 2022/01/19.
//

import RIBs

// MARK: - DetailPlanInteractable

protocol DetailPlanInteractable: Interactable {
  var router: DetailPlanRouting? { get set }
  var listener: DetailPlanListener? { get set }
}

// MARK: - DetailPlanViewControllable

protocol DetailPlanViewControllable: ViewControllable {
  // TODO: Declare methods the router invokes to manipulate the view hierarchy.
}

// MARK: - DetailPlanRouter

final class DetailPlanRouter: ViewableRouter<DetailPlanInteractable, DetailPlanViewControllable>, DetailPlanRouting {

  // TODO: Constructor inject child builder protocols to allow building children.
  override init(interactor: DetailPlanInteractable, viewController: DetailPlanViewControllable) {
    super.init(interactor: interactor, viewController: viewController)
    interactor.router = self
  }
}
