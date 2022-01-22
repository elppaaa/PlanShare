//
//  Date+Extension.swift
//  PlanShare
//
//  Created by JK on 2022/01/21.
//

import Foundation
import Then

extension Date {

  // MARK: Internal

  var formattedDateAndTime: String {
    Self.MMddHHmmFormatter.string(from: self)
  }

  // MARK: Fileprivate

  fileprivate static let MMddHHmmFormatter = DateFormatter().then {
    $0.dateFormat = "MM-dd HH:mm"
    $0.timeZone = .current
  }
}
