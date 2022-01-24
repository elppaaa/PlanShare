//
//  HomeBuilder.swift
//  PlanShare
//
//  Created by JK on 2022/01/10.
//

import RIBs

// MARK: - HomeDependency

protocol HomeDependency: Dependency {
  // TODO: Declare the set of dependencies required by this RIB, but cannot be
  // created by this RIB.
}

// MARK: - HomeComponent

final class HomeComponent: Component<HomeDependency> {
  // TODO: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: - HomeBuildable

protocol HomeBuildable: Buildable {
  func build(withListener listener: HomeListener) -> (router: HomeRouting, actionableItem: HomeActionableItem)
}

// MARK: - HomeBuilder

final class HomeBuilder: Builder<HomeDependency>, HomeBuildable {

  // MARK: Lifecycle

  override init(dependency: HomeDependency) {
    super.init(dependency: dependency)
  }

  // MARK: Internal

  func build(withListener listener: HomeListener) -> (router: HomeRouting, actionableItem: HomeActionableItem) {
    let component = HomeComponent(dependency: dependency)
    let viewController = HomeViewController()
    let interactor = HomeInteractor(presenter: viewController)
    interactor.listener = listener

    let detailPlanBuilder = DetailPlanBuilder(dependency: component)
    let editingBuilder = EditingBuilder(dependency: component)

    let router = HomeRouter(
      interactor: interactor,
      viewController: viewController,
      detailPlanBuilder: detailPlanBuilder,
      editingBuilder: editingBuilder
    )

    return (router, interactor)
  }
}
