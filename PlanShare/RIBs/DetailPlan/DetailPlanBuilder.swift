//
//  DetailPlanBuilder.swift
//  PlanShare
//
//  Created by JK on 2022/01/19.
//

import RIBs

// MARK: - DetailPlanDependency

protocol DetailPlanDependency: Dependency {
  // TODO: Declare the set of dependencies required by this RIB, but cannot be
  // created by this RIB.
}

// MARK: - DetailPlanComponent

final class DetailPlanComponent: Component<DetailPlanDependency> {

  // TODO: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: - DetailPlanBuildable

protocol DetailPlanBuildable: Buildable {
  func build(withListener listener: DetailPlanListener, currentPlan: Plan) -> DetailPlanRouting
}

// MARK: - DetailPlanBuilder

final class DetailPlanBuilder: Builder<DetailPlanDependency>, DetailPlanBuildable {

  // MARK: Lifecycle

  override init(dependency: DetailPlanDependency) {
    super.init(dependency: dependency)
  }

  // MARK: Internal

  func build(withListener listener: DetailPlanListener, currentPlan plan: Plan) -> DetailPlanRouting {
    let component = DetailPlanComponent(dependency: dependency)
    let viewController = DetailPlanViewController()
    let interactor = DetailPlanInteractor(presenter: viewController, currentPlan: plan)
    interactor.listener = listener

    let markedMapBuilder = MarkedMapBuilder(dependency: component)
    return DetailPlanRouter(
      interactor: interactor,
      viewController: viewController,
      markedMapBuilder: markedMapBuilder
    )
  }
}
