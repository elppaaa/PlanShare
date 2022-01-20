//
//  Date+Extension.swift
//  PlanShare
//
//  Created by JK on 2022/01/21.
//

import Foundation

extension Date {
  var formattedDateAndTime: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "MM-dd HH:mm"
    return formatter.string(from: self)
  }
}
