//
//  HomeComponent+DetailPlan.swift
//  PlanShare
//
//  Created by JK on 2022/01/19.
//

import RIBs

// MARK: - HomeDependencyDetailPlan

/// The dependencies needed from the parent scope of Home to provide for the DetailPlan scope.
// TODO: Update HomeDependency protocol to inherit this protocol.
protocol HomeDependencyDetailPlan: Dependency {
  // TODO: Declare dependencies needed from the parent scope of Home to provide dependencies
  // for the DetailPlan scope.
}

// MARK: - HomeComponent + DetailPlanDependency

extension HomeComponent: DetailPlanDependency {
//  var cache: GooglePlaceImageCache {
//    googlePlaceImageCache
//  }
}
