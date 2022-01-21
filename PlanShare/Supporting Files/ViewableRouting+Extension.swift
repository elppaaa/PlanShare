//
//  ViewableRouting+Extension.swift
//  PlanShare
//
//  Created by JK on 2022/01/21.
//

import Foundation
import RIBs

extension ViewableRouting {
  func detachCurrentChild() {
    if let child = children.last {
      detachChild(child)
    }
  }
}
