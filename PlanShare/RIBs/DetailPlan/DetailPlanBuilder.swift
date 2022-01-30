//
//  DetailPlanBuilder.swift
//  PlanShare
//
//  Created by JK on 2022/01/19.
//

import Foundation
import RIBs

// MARK: - DetailPlanDependency

protocol DetailPlanDependency: Dependency {
  // TODO: Declare the set of dependencies required by this RIB, but cannot be
  // created by this RIB.
  var cache: GooglePlaceImageCache { get }
}

// MARK: - DetailPlanComponent

final class DetailPlanComponent: Component<DetailPlanDependency> {

  // TODO: Declare 'fileprivate' dependencies that are only used by this RIB.
  fileprivate var cache: GooglePlaceImageCache {
    dependency.cache
  }
}

// MARK: - DetailPlanBuildable

protocol DetailPlanBuildable: Buildable {
  func build(withListener listener: DetailPlanListener, currentPlan: Plan, model: PlanModel) async -> DetailPlanRouting
}

// MARK: - DetailPlanBuilder

final class DetailPlanBuilder: Builder<DetailPlanDependency>, DetailPlanBuildable {

  // MARK: Lifecycle

  override init(dependency: DetailPlanDependency) {
    super.init(dependency: dependency)
  }

  // MARK: Internal

  @MainActor
  func build(withListener listener: DetailPlanListener, currentPlan plan: Plan, model: PlanModel) async -> DetailPlanRouting {
    let component = DetailPlanComponent(dependency: dependency)
    let viewController = DetailPlanViewController(imageCache: component.cache)

    let interactor = DetailPlanInteractor(
      presenter: viewController,
      currentPlan: plan,
      planModel: model
    )
    interactor.listener = listener

    return DetailPlanRouter(
      interactor: interactor,
      viewController: viewController
    )
  }
}
