//
//  UpdateModel.swift
//  PlanShare
//
//  Created by JK on 2022/01/14.
//

import Foundation

@dynamicMemberLookup
struct UpdateModel {
  var dict = [String: Any]()

  subscript(dynamicMember key: String) -> Any? {
    get { self.dict[key] }
    set { self.dict[key] = newValue }
  }
}
