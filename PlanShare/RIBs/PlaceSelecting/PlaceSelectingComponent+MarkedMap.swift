//
//  PlaceSelectingComponent+MarkedMap.swift
//  PlanShare
//
//  Created by JK on 2022/01/22.
//

import RIBs

// MARK: - PlaceSelectingDependencyMarkedMap

/// The dependencies needed from the parent scope of PlaceSelecting to provide for the MarkedMap scope.
// TODO: Update PlaceSelectingDependency protocol to inherit this protocol.
protocol PlaceSelectingDependencyMarkedMap: Dependency {
  // TODO: Declare dependencies needed from the parent scope of PlaceSelecting to provide dependencies
  // for the MarkedMap scope.
}

// MARK: - PlaceSelectingComponent + MarkedMapDependency

extension PlaceSelectingComponent: MarkedMapDependency {

  // TODO: Implement properties to provide for MarkedMap scope.
}
