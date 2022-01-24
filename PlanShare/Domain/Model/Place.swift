//
//  Place.swift
//  PlanShare
//
//  Created by JK on 2022/01/11.
//

import CoreLocation
import Foundation

// MARK: - Place

struct Place: Codable, Equatable {
  let id: String
  var title: String
  var address: String
  var location: CLLocationCoordinate2D

  var link: URL? {
    GoogleMapLink()
      .query(key: .q, value: title.replacingOccurrences(of: " ", with: "+"))
      .query(key: .center, value: "@\(location.longitude),\(location.latitude)")
      .url
  }
}

// MARK: FirestoreDecodable
//
//extension Place: FirestoreDecodable {
//  static func parse(from dict: [String: Any]) -> Place? {
//    dict.get()
//  }
//}
//
// MARK: FirestoreEncodable
//
//extension Place: FirestoreEncodable {
//  var dict: [String: Any]? {
//    dictionary
//  }
//}
