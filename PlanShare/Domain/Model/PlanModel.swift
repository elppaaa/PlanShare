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
  let planID: String
  var eventIdentifier: String?
}

// MARK: SQLiteEnable

extension PlanModel: SQLiteEnable {
  static var db: String { "Plan" }

  static var selectAllQuery: String { "SELECT * FROM \(db)" }

  static var insertQuery: String {
    "INSERT INTO \(db) (planID, eventIdentifier) Values (?, ?)"
  }

  static var readingBlock: (OpaquePointer?) -> PlanModel {{
    let id = sqlite3_column_int($0, 0)
    let planID = String(cString: sqlite3_column_text($0, 1))
    let eventIdentifier = String(cString: sqlite3_column_text($0, 2))

    return PlanModel(id: Int(id), planID: planID, eventIdentifier: eventIdentifier == "" ? nil : eventIdentifier)
  }}

  static var createQuery: String {
    """
    CREATE TABLE IF NOT EXISTS \(db) (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    planID TEXT,
    eventIdentifier TEXT
    )
    """
  }

  var writingBlock: () throws -> Void {{
    try bind_text(index: 1, value: self.planID)
    try bind_text(index: 2, value: self.eventIdentifier ?? "")
  }}

  @discardableResult
  static func deleteBy(planID: String) -> SQLiteError? {
    Log.log(.debug, category: .sqlite, #function)
    let deletionQuery = "DELETE FROM \(db) WHERE planID \(planID)"

    var stmt: OpaquePointer?
    if sqlite3_prepare_v2(SQLiteService.shared.db, deletionQuery, -1, &stmt, nil) != SQLITE_OK {
      let errMsg = String(cString: sqlite3_errmsg(SQLiteService.shared.db)!)
      Log.log(.error, category: .sqlite, "Preparing insert \(errMsg)")
      return .failedToPrepare
    }

    if sqlite3_step(stmt) != SQLITE_DONE {
      let errMsg = String(cString: sqlite3_errmsg(SQLiteService.shared.db)!)
      Log.log(.error, category: .sqlite, "Preparing insert \(errMsg)")
      return .failedToDelete
    }

    if sqlite3_finalize(stmt) != SQLITE_OK {
      return .unknown
    }

    return nil
  }

//  var values: [Any] {
//    [ id, eventIdentifier ?? "" ]
//  }
}
