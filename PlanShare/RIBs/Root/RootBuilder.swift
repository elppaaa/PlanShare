//
//  RootBuilder.swift
//  PlanShare
//
//  Created by JK on 2022/01/10.
//

import RIBs

// MARK: - RootDependency

protocol RootDependency: Dependency {
  // TODO: Declare the set of dependencies required by this RIB, but cannot be
  // created by this RIB.
}

// MARK: - RootComponent

final class RootComponent: Component<RootDependency> {
  // TODO: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: - RootBuildable

protocol RootBuildable: Buildable {
  func build() -> LaunchRouting
}

// MARK: - RootBuilder

final class RootBuilder: Builder<RootDependency>, RootBuildable {

  // MARK: Lifecycle

  override init(dependency: RootDependency) {
    super.init(dependency: dependency)
  }

  // MARK: Internal

  func build() -> LaunchRouting {
    let component = RootComponent(dependency: dependency)
    let viewController = RootViewController()
    let interactor = RootInteractor(presenter: viewController)

    let homeBuilder = HomeBuilder(dependency: component)

    return RootRouter(
      interactor: interactor,
      viewController: viewController,
      homeBuilder: homeBuilder)
  }
}
