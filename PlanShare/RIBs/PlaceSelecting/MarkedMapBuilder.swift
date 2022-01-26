//
//  MarkedMapBuilder.swift
//  PlanShare
//
//  Created by JK on 2022/01/21.
//

import CoreLocation
import RIBs

// MARK: - MarkedMapDependency

protocol MarkedMapDependency: Dependency {
  // TODO: Declare the set of dependencies required by this RIB, but cannot be
  // created by this RIB.
}

// MARK: - MarkedMapComponent

final class MarkedMapComponent: Component<MarkedMapDependency> {

  // TODO: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: - MarkedMapBuildable

protocol MarkedMapBuildable: Buildable {
  func build(withListener listener: MarkedMapListener, location: CLLocationCoordinate2D) -> MarkedMapRouting
}

// MARK: - MarkedMapBuilder

final class MarkedMapBuilder: Builder<MarkedMapDependency>, MarkedMapBuildable {

  // MARK: Lifecycle

  override init(dependency: MarkedMapDependency) {
    super.init(dependency: dependency)
  }

  // MARK: Internal

  func build(withListener listener: MarkedMapListener, location: CLLocationCoordinate2D) -> MarkedMapRouting {
    let _ = MarkedMapComponent(dependency: dependency)
    let viewController = MarkedMapViewController()
    let interactor = MarkedMapInteractor(presenter: viewController, location: location)
    interactor.listener = listener
    return MarkedMapRouter(interactor: interactor, viewController: viewController)
  }
}
