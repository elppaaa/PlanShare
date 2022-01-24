//
//  RootActionableItem.swift
//  PlanShare
//
//  Created by JK on 2022/01/25.
//

import Foundation
import RxSwift

protocol RootActionableItem: AnyObject {
  func routeToHome() -> Observable<(HomeActionableItem, ())>
}
