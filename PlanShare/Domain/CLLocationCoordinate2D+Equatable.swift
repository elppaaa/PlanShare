//
//  CLLocationCoordinate2D+Equatable.swift
//  PlanShare
//
//  Created by JK on 2022/01/20.
//

import Foundation
import MapKit

// MARK: - CLLocationCoordinate2D + Equatable

extension CLLocationCoordinate2D: Equatable {
  public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
    lhs.latitude == rhs.latitude && lhs.longitude == rhs.latitude
  }
}

// MARK: - CLLocationCoordinate2D + Decodable, Encodable

extension CLLocationCoordinate2D: Decodable, Encodable {

  // MARK: Lifecycle

  public init(from decoder: Decoder) throws {
    self.init()
    let container = try decoder.container(keyedBy: CodingKeys.self)
    latitude = try container.decode(Double.self, forKey: .latitude)
    longitude = try container.decode(Double.self, forKey: .longitude)
  }

  // MARK: Public

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(latitude, forKey: .latitude)
    try container.encode(longitude, forKey: .longitude)
  }

  // MARK: Internal

  enum CodingKeys: String, CodingKey {
    case latitude
    case longitude
  }

}
