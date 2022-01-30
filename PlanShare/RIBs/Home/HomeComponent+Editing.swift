//
//  HomeComponent+Editing.swift
//  PlanShare
//
//  Created by JK on 2022/01/19.
//

import RIBs

// MARK: - HomeDependencyEditing

/// The dependencies needed from the parent scope of Home to provide for the Editing scope.
// TODO: Update HomeDependency protocol to inherit this protocol.
protocol HomeDependencyEditing: Dependency {
  // TODO: Declare dependencies needed from the parent scope of Home to provide dependencies
  // for the Editing scope.
}

// MARK: - HomeComponent + EditingDependency

extension HomeComponent: EditingDependency {
  // TODO: Implement properties to provide for Editing scope.
  var cache: GooglePlaceImageCache {
    googlePlaceImageCache
  }
}
