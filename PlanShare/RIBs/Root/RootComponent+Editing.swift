//
//  RootComponent+Editing.swift
//  PlanShare
//
//  Created by JK on 2022/01/10.
//

import RIBs

// MARK: - RootDependencyEditing

/// The dependencies needed from the parent scope of Root to provide for the Editing scope.
// TODO: Update RootDependency protocol to inherit this protocol.
protocol RootDependencyEditing: Dependency {
  // TODO: Declare dependencies needed from the parent scope of Root to provide dependencies
  // for the Editing scope.
}

// MARK: - RootComponent + EditingDependency

extension RootComponent: EditingDependency {

  // TODO: Implement properties to provide for Editing scope.
}
