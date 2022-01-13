//
//  Plan.swift
//  PlanShare
//
//  Created by JK on 2022/01/10.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation

// MARK: - Plan

struct Plan: Codable, Identifiable, Equatable {
  @DocumentID var id: String?
  var title: String
  var startAt: Date
  var endAt: Date
  var place: Place
  var memo: String
  var additionalPlaces: [Place] = []
}

extension Plan {
  struct Upload: Codable {
    let title: String
    var startAt: Date
    var endAt: Date
    var place: Place
    var memo: String
    var additionalPlaces: [Place] = []
  }
}

// MARK: FirestoreDecodable

extension Plan: FirestoreDecodable {
  static func parse(from dict: [String: Any]) -> Plan? {
    guard
      let id = dict["id"] as? String,
      let title = dict["title"] as? String,
      let startAt = (dict["startAt"] as? Timestamp)?.dateValue(),
      let endAt = (dict["endAt"] as? Timestamp)?.dateValue(),
      let memo = dict["memo"] as? String,
      let placeDict = (dict["place"] as? [String: Any]),
      let place = Place.parse(from: placeDict),
      let additionalPlaces = dict["additionalPlaces"] as? [[String: Any]]
    else { return nil }

    var placesArray = [Place]()
    for dict in additionalPlaces {
      guard let value = Place.parse(from: dict) else { return nil }
      placesArray.append(value)
    }

    return Plan(id: id, title: title, startAt: startAt, endAt: endAt, place: place, memo: memo, additionalPlaces: placesArray)
  }
}

// MARK: - Plan.Upload + FirestoreEncodable

extension Plan.Upload: FirestoreEncodable {
  var dict: [String: Any]? {
    var dict = [String: Any]()
    dict["title"] = title
    dict["startAt"] = Timestamp(date: startAt)
    dict["endAt"] = Timestamp(date: endAt)
    dict["place"] = place.dict
    dict["memo"] = memo
    dict["additionalPlaces"] = additionalPlaces.map { $0.dict }

    return dict
  }
}
