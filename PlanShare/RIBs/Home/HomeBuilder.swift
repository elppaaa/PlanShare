//
//  HomeBuilder.swift
//  PlanShare
//
//  Created by JK on 2022/01/10.
//

import Foundation
import RIBs

// MARK: - HomeDependency

protocol HomeDependency: Dependency {
  // TODO: Declare the set of dependencies required by this RIB, but cannot be
  // created by this RIB.
}

// MARK: - HomeComponent

final class HomeComponent: Component<HomeDependency> {

  // MARK: Lifecycle

  // TODO: Declare 'fileprivate' dependencies that are only used by this RIB.
  init(dependency: HomeDependency, googlePlaceImageCache: GooglePlaceImageCache) {
    self.googlePlaceImageCache = googlePlaceImageCache
    super.init(dependency: dependency)
  }

  // MARK: Internal

  let googlePlaceImageCache: GooglePlaceImageCache
}

// MARK: - HomeBuildable

protocol HomeBuildable: Buildable {
  func build(withListener listener: HomeListener) -> (router: HomeRouting, actionableItem: HomeActionableItem)
}

// MARK: - HomeBuilder

final class HomeBuilder: Builder<HomeDependency>, HomeBuildable {

  func build(withListener listener: HomeListener) -> (router: HomeRouting, actionableItem: HomeActionableItem) {
    let component = HomeComponent(dependency: dependency, googlePlaceImageCache: GooglePlaceImageCache())
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
