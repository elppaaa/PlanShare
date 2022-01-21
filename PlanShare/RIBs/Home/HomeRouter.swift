//
//  HomeRouter.swift
//  PlanShare
//
//  Created by JK on 2022/01/10.
//

import RIBs

// MARK: - HomeInteractable

protocol HomeInteractable: Interactable, DetailPlanListener, EditingListener {
  var router: HomeRouting? { get set }
  var listener: HomeListener? { get set }
}

// MARK: - HomeViewControllable

protocol HomeViewControllable: ViewControllable {
  // TODO: Declare methods the router invokes to manipulate the view hierarchy.
  func addChild(viewContronller: ViewControllable)
}

// MARK: - HomeRouter

final class HomeRouter: ViewableRouter<HomeInteractable, HomeViewControllable>, HomeRouting {

  // MARK: Lifecycle

  init(
    interactor: HomeInteractable,
    viewController: HomeViewControllable,
    detailPlanBuilder: DetailPlanBuildable,
    editingBuilder: EditingBuildable
  ) {
    self.detailPlanBuilder = detailPlanBuilder
    self.editingBuilder = editingBuilder
    super.init(interactor: interactor, viewController: viewController)
    interactor.router = self
  }

  // MARK: Private

  private let detailPlanBuilder: DetailPlanBuildable
  private let editingBuilder: EditingBuildable
}

// MARK: - HomeRouting

extension HomeRouter {

  // MARK: Internal

  func routeToDetailPlan(plan: Plan) {
    let router = detailPlanBuilder.build(withListener: interactor, currentPlan: plan)
    attachChild(router)
    viewController.addChild(viewContronller: router.viewControllable)
  }

  func dismissChild(_ router: DetailPlanRouting) {
    detachChild(router)
  }

  func routeToNewPlan() {
    let router = editingBuilder.build(withListener: interactor, currentPlan: nil)
    attachChild(router)
    viewController.push(viewController: router.viewControllable)
  }

  func routeToHome() {
    detachChilds()
  }

  // MARK: Private

  private func detachChilds() {
    children.forEach { detachChild($0) }
  }
}
