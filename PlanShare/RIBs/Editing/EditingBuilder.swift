//
//  EditingBuilder.swift
//  PlanShare
//
//  Created by JK on 2022/01/10.
//

import RIBs

// MARK: - EditingDependency

protocol EditingDependency: Dependency {
  // TODO: Declare the set of dependencies required by this RIB, but cannot be
  // created by this RIB.
  var cache: GooglePlaceImageCache { get }
}

// MARK: - EditingComponent

final class EditingComponent: Component<EditingDependency> {

  // MARK: Lifecycle

  init(dependency: EditingDependency, plan: Plan?) {
    self.plan = plan
    super.init(dependency: dependency)
  }

  // MARK: Fileprivate

  // TODO: Declare 'fileprivate' dependencies that are only used by this RIB.
  fileprivate var plan: Plan?

  fileprivate var cache: GooglePlaceImageCache {
    dependency.cache
  }
}

// MARK: - EditingBuildable

protocol EditingBuildable: Buildable {
  func build(withListener listener: EditingListener, currentPlan: Plan?) async -> EditingRouting
}

// MARK: - EditingBuilder

final class EditingBuilder: Builder<EditingDependency>, EditingBuildable {

  // MARK: Lifecycle

  override init(dependency: EditingDependency) {
    super.init(dependency: dependency)
  }

  // MARK: Internal

  @MainActor
  func build(withListener listener: EditingListener, currentPlan: Plan?) async -> EditingRouting {
    let component = EditingComponent(dependency: dependency, plan: currentPlan)
    let viewController = EditingViewController(imageCache: component.cache)
    let interactor = EditingInteractor(presenter: viewController, plan: component.plan)
    interactor.listener = listener

    let placeSelectingBuilder = PlaceSelectingBuilder(dependency: component)
    return EditingRouter(
      interactor: interactor,
      viewController: viewController,
      placeSelectingBuilder: placeSelectingBuilder
    )
  }
}
