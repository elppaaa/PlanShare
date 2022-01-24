//
//  GetPlanWorkflow.swift
//  PlanShare
//
//  Created by JK on 2022/01/25.
//

import Foundation
import RIBs
import RxSwift

final class GetPlanWorkflow: Workflow<RootActionableItem> {
  public init(url: URL) {
    super.init()

    let id = url.query!

    onStep { $0.routeToHome() }
      .onStep { actionableItem, _ in
        actionableItem.getAndOpenPlan(id: id)
      }
      .commit()

  }

}
