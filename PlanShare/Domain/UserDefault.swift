//
//  UserDefault.swift
//  PlanShare
//
//  Created by JK on 2022/01/19.
//

import Foundation

extension UserDefaults {
  @UserDefault(key: "idList", defaultValue: [])
  static var idList: Set<String>
}

// MARK: - UserDefault

@propertyWrapper
struct UserDefault<T> {
  let key: String
  let defaultValue: T
  var container: UserDefaults = .standard

  var wrappedValue: T {
    get {
      container.object(forKey: key) as? T ?? defaultValue
    }

    set {
      container.set(newValue, forKey: key)
    }
  }
}
