//
//  SQLiteService.swift
//  PlanShare
//
//  Created by JK on 2022/01/23.
//

import Foundation
import SQLite3

// MARK: - SQLiteService

final actor SQLiteService {

  // MARK: Lifecycle

  init() { }

  // MARK: Internal

  static var shared = SQLiteService()

  var db: OpaquePointer?
  let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

  func openDB(createQuery query: String) async {
    if sqlite3_open(Constraints.DB_PATH, &db) != SQLITE_OK {
      let errMsg = String(cString: sqlite3_errmsg(db))
      Log.log(.error, category: .sqlite, errMsg)
      return
    }

    if sqlite3_exec(db, query, nil, nil, nil) != SQLITE_OK {
      let errMsg = String(cString: sqlite3_errmsg(db))
      Log.log(.error, category: .sqlite, errMsg)
    }
  }

  func prepare(query: String, stmt: inout OpaquePointer?) -> SQLiteError? {
    if sqlite3_prepare_v2(db, query, -1, &stmt, nil) != SQLITE_OK {
      let errMsg = String(cString: sqlite3_errmsg(db)!)
      Log.log(.error, category: .sqlite, errMsg)
      return .failedToPrepare
    }

    return nil
  }

  func write(query: String, block: (OpaquePointer?) throws -> Void) async -> SQLiteError? {
    var stmt: OpaquePointer?

    if let error = prepare(query: query, stmt: &stmt) {
      return error
    }

    do {
      try block(stmt)
    } catch {
      if let error = error as? SQLiteError {
        return error
      } else {
        fatalError("Undefined Error")
      }
    }

    if sqlite3_step(stmt) != SQLITE_DONE {
      let errMsg = String(cString: sqlite3_errmsg(db)!)
      Log.log(.error, category: .sqlite, "Writing error \(errMsg)")
      return .failedToWrite
    }

    if sqlite3_finalize(stmt) != SQLITE_OK {
      return .unknown
    }

    return nil
  }

  func write(query: String, values: [Any]) -> SQLiteError? {
    var stmt: OpaquePointer?

    if let error = prepare(query: query, stmt: &stmt) {
      return error
    }

    for (index, value) in values.enumerated() {
      if !bind(value,stmp: stmt, index: Int32(index), bit: SQLITE_TRANSIENT) {
        let errMsg = String(cString: sqlite3_errmsg(stmt)!)
        Log.log(.error, category: .sqlite, "Bind error \(errMsg)")
        return .failedToBind
      }
    }

    if sqlite3_step(stmt) != SQLITE_DONE {
      let errMsg = String(cString: sqlite3_errmsg(db)!)
      Log.log(.error, category: .sqlite, "Writing error \(errMsg)")
      return .failedToBind
    }

    if sqlite3_finalize(stmt) != SQLITE_OK {
      return .unknown
    }

    return nil
  }

  func readAll<T>(query: String, blocks: (OpaquePointer?) -> T) -> Result<[T], SQLiteError> {
    var stmt: OpaquePointer?
    if let error = prepare(query: query, stmt: &stmt) {
      return .failure(error)
    }

    var array = [T]()
    while sqlite3_step(stmt) == SQLITE_ROW {
      array.append(blocks(stmt))
    }

    if sqlite3_finalize(stmt) != SQLITE_OK {
      return .failure(.unknown)
    }

    return .success(array)
  }

  func update(query: String) -> SQLiteError? {
    var stmt: OpaquePointer?

    if let error = prepare(query: query, stmt: &stmt) {
      return error
    }

    if sqlite3_step(stmt) != SQLITE_DONE {
      let errMsg = String(cString: sqlite3_errmsg(db)!)
      Log.log(.error, category: .sqlite, "Preparing insert \(errMsg)")
      return .failedToUpdate
    }

    if sqlite3_finalize(stmt) != SQLITE_OK {
      return .unknown
    }

    return nil
  }

  func delete(query: String, id: Int) async -> SQLiteError? {
    var stmt: OpaquePointer?

    if let error = prepare(query: query, stmt: &stmt) {
      return error
    }

    if sqlite3_step(stmt) != SQLITE_DONE {
      let errMsg = String(cString: sqlite3_errmsg(db)!)
      Log.log(.error, category: .sqlite, "Preparing insert \(errMsg)")
      return .failedToDelete
    }

    if sqlite3_finalize(stmt) != SQLITE_OK {
      return .unknown
    }

    return nil
  }

  // MARK: Private

  // 적당한 타입이 없으면 에러발생.
  // 다른 구현 방법 고려
  private func bind(_ value: Any, stmp: OpaquePointer?, index: Int32, bit: @escaping sqlite3_destructor_type) -> Bool {
    switch value {
    case let v as Double:
      if sqlite3_bind_double(stmp, index, v) != SQLITE_OK {
        return false
      }
    case let v as String:
      if sqlite3_bind_text(stmp, index, v.trimmingCharacters(in: .whitespacesAndNewlines), -1, bit) != SQLITE_OK {
        return false
      }
    case let v as Int:
      if sqlite3_bind_int(stmp, index, Int32(v)) != SQLITE_OK {
        return false
      }
    default: fatalError("정의되지 않은 타입. \(value)")
    }
    return true
  }
}

// MARK: - SQLiteError

enum SQLiteError: Error {
  case failedToPrepare
  case failedToWrite
  case failedToBind
  case idIsEmpty
  case failedToDelete
  case failedToUpdate
  case unknown
}
