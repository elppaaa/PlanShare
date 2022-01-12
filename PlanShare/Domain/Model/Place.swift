//
//  Place.swift
//  PlanShare
//
//  Created by JK on 2022/01/11.
//

import Foundation

// MARK: - Place

struct Place: Codable, Equatable {
  let id: String
  let title: String
  let link: String
  let address: String
}

// MARK: FirestoreDecodable

extension Place: FirestoreDecodable {
  static func parse(from dict: [String: Any]) -> Place? {
    dict.get()
  }
}

// MARK: FirestoreEncodable

extension Place: FirestoreEncodable {
  var dict: [String: Any]? {
    dictionary
  }
}
