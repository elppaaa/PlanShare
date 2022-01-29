//
//  PlaceSelectingBuilder.swift
//  PlanShare
//
//  Created by JK on 2022/01/19.
//

import RIBs

// MARK: - PlaceSelectingDependency

protocol PlaceSelectingDependency: Dependency {
  // TODO: Declare the set of dependencies required by this RIB, but cannot be
  // created by this RIB.
}

// MARK: - PlaceSelectingComponent

final class PlaceSelectingComponent: Component<PlaceSelectingDependency> {

  // TODO: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: - PlaceSelectingBuildable

protocol PlaceSelectingBuildable: Buildable {
  func build(withListener listener: PlaceSelectingListener, isAdditionalPlace: Bool) -> PlaceSelectingRouting
}

// MARK: - PlaceSelectingBuilder

final class PlaceSelectingBuilder: Builder<PlaceSelectingDependency>, PlaceSelectingBuildable {

  // MARK: Lifecycle

  override init(dependency: PlaceSelectingDependency) {
    super.init(dependency: dependency)
  }

  // MARK: Internal

  func build(withListener listener: PlaceSelectingListener, isAdditionalPlace: Bool) -> PlaceSelectingRouting {
    let component = PlaceSelectingComponent(dependency: dependency)
    let viewController = PlaceSelectingViewController()
    let interactor = PlaceSelectingInteractor(presenter: viewController, isAdditionalPlace: isAdditionalPlace)
    interactor.listener = listener

    let markedMapBuilder = MarkedMapBuilder(dependency: component)
    return PlaceSelectingRouter(
      interactor: interactor,
      viewController: viewController,
      markedMapBuilder: markedMapBuilder
    )
  }
}
