//
//  DetailPlanComponent+MarkedMap.swift
//  PlanShare
//
//  Created by JK on 2022/01/21.
//

import RIBs

// MARK: - DetailPlanDependencyMarkedMap

/// The dependencies needed from the parent scope of DetailPlan to provide for the MarkedMap scope.
// TODO: Update DetailPlanDependency protocol to inherit this protocol.
protocol DetailPlanDependencyMarkedMap: Dependency {
  // TODO: Declare dependencies needed from the parent scope of DetailPlan to provide dependencies
  // for the MarkedMap scope.
}

// MARK: - DetailPlanComponent + MarkedMapDependency

extension DetailPlanComponent: MarkedMapDependency {

  // TODO: Implement properties to provide for MarkedMap scope.
}
