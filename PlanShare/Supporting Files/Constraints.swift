//
//  Constraints.swift
//  PlanShare
//
//  Created by JK on 2022/01/07.
//

import Foundation
import UIKit

// MARK: - Constraints

final class Constraints {

  // MARK: Lifecycle

  private init() {}

  // MARK: Internal

  static let GCP_KEY = Bundle.main.object(forInfoDictionaryKey: "GCP_KEY") as! String
  static let KAKAO_KEY = Bundle.main.object(forInfoDictionaryKey: "KAKAO_KEY") as! String

  static let GOOGLEMAP_BASEURL: String = "maps.google.com"
  static let GOOGLEMAP_DEEPLINK = "comgooglemapsurl"

  static var DB_PATH: String {
    FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).last!
      .appendingPathComponent("Plan.db").path
  }

  static var isGoogleMapInstalled: Bool {
    UIApplication.shared.canOpenURL(URL(string: "\(GOOGLEMAP_DEEPLINK)://")!)
  }
}

