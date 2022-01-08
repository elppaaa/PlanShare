//
//  Constraints.swift
//  PlanShare
//
//  Created by JK on 2022/01/07.
//

import Foundation

final class Constraints {

  // MARK: Lifecycle

  private init() { }

  // MARK: Internal

  static let GCP_KEY = Bundle.main.object(forInfoDictionaryKey: "GCP_KEY") as! String
  static let KAKAO_KEY = Bundle.main.object(forInfoDictionaryKey: "KAKAO_KEY") as! String

}
