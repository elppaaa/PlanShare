//
//  FirestoreCodable.swift
//  PlanShare
//
//  Created by JK on 2022/01/12.
//

import Foundation

// MARK: - FirestoreEncodable

protocol FirestoreEncodable {
  var dict: [String: Any]? { get }
}

// MARK: - FirestoreDecodable

protocol FirestoreDecodable {
  static func parse(from: [String: Any]) -> Self?
}

extension Encodable {
  var dictionary: [String: Any]? {
    guard let data = try? JSONEncoder().encode(self) else { return nil }
    return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
  }
}

extension Dictionary where Key == String {
  func get<T: Decodable>() -> T? {
    guard let data = try? JSONSerialization.data(withJSONObject: self, options: [.fragmentsAllowed]) else { return nil }
    return (try? JSONDecoder().decode(T.self, from: data))
  }
}
