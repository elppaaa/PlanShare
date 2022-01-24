//
//  HomeActionableItem.swift
//  PlanShare
//
//  Created by JK on 2022/01/25.
//

import Foundation
import RxSwift

protocol HomeActionableItem: AnyObject {
  func getAndOpenPlan(id: String) -> Observable<(HomeActionableItem, ())>
}
