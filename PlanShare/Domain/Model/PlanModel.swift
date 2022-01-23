//
//  PlanModel.swift
//  PlanShare
//
//  Created by JK on 2022/01/24.
//

import Foundation
import SQLite3

// MARK: - PlanModel

struct PlanModel {
  var id: Int?
  let placeID: String
  let eventIdentifier: String?
}

extension PlanModel: SQLiteEnable {
  var db: String { "Plan" }
  
  var createQuery: String {
    """
    CREATE TABLE IF NOT EXISTS Plan (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    placeID TEXT,
    eventIdentifier TEXT
    )
    """
  }

  var selectAllQuery: String { "SELECT * FROM Plan" }

  var insertQuery: String {
    "INSERT INTO Plan (id, eventIdentifier) Values (?,?)"
  }

  var readingBlock: (OpaquePointer?) -> PlanModel {{
    let id = sqlite3_column_int($0, 0)
    let placeID = String(cString: sqlite3_column_text($0, 1))
    let eventIdentifier = String(cString: sqlite3_column_text($0, 2))

    return PlanModel(id: Int(id), placeID: placeID, eventIdentifier: eventIdentifier == "" ? nil : eventIdentifier)
  }}

  var writingBlock: () throws -> Void {{
    try bind_text(index: 1, value: self.placeID)
    try bind_text(index: 2, value: self.eventIdentifier ?? "")
  }}

//  var values: [Any] {
//    [ id, eventIdentifier ?? "" ]
//  }
}
