//
//  RootComponent+Home.swift
//  PlanShare
//
//  Created by JK on 2022/01/10.
//

import RIBs

// MARK: - RootDependencyHome

/// The dependencies needed from the parent scope of Root to provide for the Home scope.
// TODO: Update RootDependency protocol to inherit this protocol.
protocol RootDependencyHome: Dependency {
  // TODO: Declare dependencies needed from the parent scope of Root to provide dependencies
  // for the Home scope.
}

// MARK: - RootComponent + HomeDependency

extension RootComponent: HomeDependency {

  // TODO: Implement properties to provide for Home scope.
}
