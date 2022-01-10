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
}

// MARK: - EditingComponent

final class EditingComponent: Component<EditingDependency> {

  // TODO: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: - EditingBuildable

protocol EditingBuildable: Buildable {
  func build(withListener listener: EditingListener) -> EditingRouting
}

// MARK: - EditingBuilder

final class EditingBuilder: Builder<EditingDependency>, EditingBuildable {

  // MARK: Lifecycle

  override init(dependency: EditingDependency) {
    super.init(dependency: dependency)
  }

  // MARK: Internal

  func build(withListener listener: EditingListener) -> EditingRouting {
    let component = EditingComponent(dependency: dependency)
    let viewController = EditingViewController()
    let interactor = EditingInteractor(presenter: viewController)
    interactor.listener = listener
    return EditingRouter(interactor: interactor, viewController: viewController)
  }
}
