//
//  HomeRouter.swift
//  PlanShare
//
//  Created by JK on 2022/01/10.
//

import CoreText
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
    detailPlanBuilder: DetailPlanBuildable ,
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
  func routeToDetailPlan(plan: Plan, model: PlanModel) {
    Task(priority: .userInitiated) {
      let router = await self.detailPlanBuilder.build(withListener: self.interactor, currentPlan: plan, model: model)
      self.attachChild(router)
      self.viewController.addChild(viewContronller: router.viewControllable)
    }
  }

  func routeToNewPlan() {
    Task(priority: .userInitiated) {
      let router = await self.editingBuilder.build(withListener: self.interactor, currentPlan: nil)
      self.viewController.push(viewController: router.viewControllable)
      self.attachChild(router)
    }
  }

  func routeToHome() {
    DispatchQueue.main.async {
      self.viewController.pop()
      self.detachCurrentChild()
    }
  }

  func routeToEditing(plan: Plan) {
    Task(priority: .userInitiated) {
      let router = await self.editingBuilder.build(withListener: self.interactor, currentPlan: plan)
      self.viewController.push(viewController: router.viewControllable)
      self.attachChild(router)
    }
  }

}
