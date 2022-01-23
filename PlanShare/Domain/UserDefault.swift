//
//  UserDefault.swift
//  PlanShare
//
//  Created by JK on 2022/01/19.
//

import Foundation

extension UserDefaults {
  @SetUserDefault(key: "idList", defaultValue: Set<String>())
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

// MARK: - SetUserDefault

@propertyWrapper
struct SetUserDefault<T: Hashable> {
  let key: String
  let defaultValue: Set<T>
  var container: UserDefaults = .standard

  var wrappedValue: Set<T> {
    get {
      guard
        let obj = container.object(forKey: key) as? NSSet,
        let sets = obj.allObjects as? [T] else
      {
        return defaultValue
      }
      return Set(sets)
    }
    set {
      container.set(NSSet(set: newValue), forKey: key)
    }
  }
}
