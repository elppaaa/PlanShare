//
//  EditingComponent+PlaceSelecting.swift
//  PlanShare
//
//  Created by JK on 2022/01/19.
//

import RIBs

// MARK: - EditingDependencyPlaceSelecting

/// The dependencies needed from the parent scope of Editing to provide for the PlaceSelecting scope.
// TODO: Update EditingDependency protocol to inherit this protocol.
protocol EditingDependencyPlaceSelecting: Dependency {
  // TODO: Declare dependencies needed from the parent scope of Editing to provide dependencies
  // for the PlaceSelecting scope.
}

// MARK: - EditingComponent + PlaceSelectingDependency

extension EditingComponent: PlaceSelectingDependency {

  // TODO: Implement properties to provide for PlaceSelecting scope.
}
