//
//  SQLiteService.swift
//  PlanShare
//
//  Created by JK on 2022/01/23.
//

import Foundation
import SQLite3

// MARK: - SQLiteService

final class SQLiteService {

  // MARK: Lifecycle

  private init() { }

  // MARK: Internal

  static var shared = SQLiteService()

  var db: OpaquePointer?
  var stmt: OpaquePointer?
  let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

  func openDB(createQuery query: String) {
    if sqlite3_open(Constraints.DB_PATH, &db) != SQLITE_OK {
      let errMsg = String(cString: sqlite3_errmsg(db))
      Log.log(.error, category: .sqlite, errMsg)
    }

    if sqlite3_exec(db, query, nil, nil, nil) != SQLITE_OK {
      let errMsg = String(cString: sqlite3_errmsg(db))
      Log.log(.error, category: .sqlite, errMsg)
      return
    }
  }

  func write(query: String, block: () throws -> Void) -> SQLiteError? {
    var stmt: OpaquePointer?

    if sqlite3_prepare_v2(db, query, -1, &stmt, nil) != SQLITE_OK{
      let errMsg = String(cString: sqlite3_errmsg(db)!)
      Log.log(.error, category: .sqlite, "Preparing insert \(errMsg)")
      return .failedToPrepare
    }

    do {
      try block()
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
      return .failedToBind
    }

    if sqlite3_finalize(stmt) != SQLITE_OK {
      return .unknown
    }
    
    return nil
  }

  func write(query: String, values: [Any]) -> SQLiteError? {

    if sqlite3_prepare_v2(db, query, -1, &stmt, nil) != SQLITE_OK{
      let errMsg = String(cString: sqlite3_errmsg(db)!)
      Log.log(.error, category: .sqlite, "Preparing insert \(errMsg)")
      return .failedToPrepare
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
    if sqlite3_prepare_v2(db, query, -1, &stmt, nil) != SQLITE_OK {
      let errMsg = String(cString: sqlite3_errmsg(db)!)
      Log.log(.error, category: .sqlite, "Preparing insert \(errMsg)")
      return .failure(.failedToPrepare)
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
  
  func delete(query: String, id: Int) -> SQLiteError? {
    if sqlite3_prepare_v2(db, query, -1, &stmt, nil) != SQLITE_OK {
      let errMsg = String(cString: sqlite3_errmsg(db)!)
      Log.log(.error, category: .sqlite, "Preparing insert \(errMsg)")
      return .failedToPrepare
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
  case unknown
}
