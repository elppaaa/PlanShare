//
//  NSObject+Extension.swift
//  PlanShare
//
//  Created by JK on 2022/01/18.
//

import Foundation

extension NSObject {
  static var describe: String {
    String(describing: Self.self)
  }
}
