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

  var writingBlock: (OpaquePointer?) throws -> Void {{
    try bind_text(stmt: $0, index: 1, value: self.planID)
    try bind_text(stmt: $0, index: 2, value: self.eventIdentifier ?? "")
  }}

  @discardableResult
  static func deleteBy(planID: String) -> SQLiteError? {
    Log.log(.debug, category: .sqlite, #function)
    let deletionQuery = "DELETE FROM \(db) WHERE planID = '\(planID)'"

    let service = SQLiteService.shared
    var stmt: OpaquePointer?

    if let error = service.prepare(query: deletionQuery, stmt: &stmt) {
      return error
    }

    if sqlite3_step(stmt) != SQLITE_DONE {
      let errMsg = String(cString: sqlite3_errmsg(service.db)!)
      Log.log(.error, category: .sqlite, "Preparing insert \(errMsg)")
      return .failedToDelete
    }

    if sqlite3_finalize(stmt) != SQLITE_OK {
      return .unknown
    }

    return nil
  }

  static func getEventIDBy(planID id: String) -> Result<String?, SQLiteError> {
    Log.log(.debug, category: .sqlite, #function)

    let service = SQLiteService.shared
    var stmt: OpaquePointer?

    let selectQuery = "SELECT eventIdentifier FROM \(db) WHERE planID = '\(id)'"
    if let error = service.prepare(query: selectQuery, stmt: &stmt) {
      return .failure(error)
    }

    var identifier: String? = nil

    if sqlite3_step(stmt) == SQLITE_ROW {
      let str = String(cString: sqlite3_column_text(stmt, 0))
      identifier = str == "" ? nil : str
    }

    if sqlite3_finalize(stmt) != SQLITE_OK {
      return .failure(.unknown)
    }

    return .success(identifier)
  }

  static func getBy(planID id: String) -> Result<PlanModel, SQLiteError> {
    Log.log(.debug, category: .sqlite, #function)

    let service = SQLiteService.shared
    var stmt: OpaquePointer?

    let selectQuery = "SELECT * FROM \(db) WHERE planID = '\(id)'"
    if let error = service.prepare(query: selectQuery, stmt: &stmt) {
      return .failure(error)
    }

    var model: PlanModel?

    if sqlite3_step(stmt) == SQLITE_ROW {
      let id = Int(sqlite3_column_int(stmt, 0))
      let planID = String(cString: sqlite3_column_text(stmt, 1))
      let eventIdentifier = String(cString: sqlite3_column_text(stmt, 2))
      model = PlanModel(id: id, planID: planID, eventIdentifier: eventIdentifier == "" ? nil : eventIdentifier)
    }

    if sqlite3_finalize(stmt) != SQLITE_OK {
      return .failure(.unknown)
    }

    if let model = model {
      return .success(model)
    } else {
      return .failure(.unknown)
    }
  }

//  @discardableResult
//  static func updateEventID(planID: String, eventIdentifier: String) -> SQLiteError? {
//    Log.log(.debug, category: .sqlite, #function)
//    let service = SQLiteService.shared
//    var stmt: OpaquePointer?
//
//    let updateQuery = "UPDATE \(db) SET eventIdentifier = '\(eventIdentifier)' WHERE planID == '\(planID)'"
//    if let error = service.prepare(query: updateQuery, stmt: &stmt) {
//      return error
//    }
//
//    if sqlite3_step(stmt) != SQLITE_DONE {
//      let errMsg = String(cString: sqlite3_errmsg(service.db)!)
//      Log.log(.error, category: .sqlite, errMsg)
//      return .failedToWrite
//    }
//
//    return nil
//  }

//  var values: [Any] {
//    [ id, eventIdentifier ?? "" ]
//  }

  @discardableResult
  func update() -> SQLiteError? {
    let updateQuery = "UPDATE \(PlanModel.db) SET eventIdentifier = '\(eventIdentifier!)' WHERE id == '\(id!)'; "
    return PlanModel.service.update(query: updateQuery)
  }
}
