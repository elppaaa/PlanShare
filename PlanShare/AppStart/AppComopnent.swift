//
//  AppComopnent.swift
//  PlanShare
//
//  Created by JK on 2022/01/10.
//

import RIBs

class AppComponent: Component<EmptyDependency>, RootDependency {
  init() {
    super.init(dependency: EmptyComponent())
  }
}
